package routing

import (
	"fmt"
	"math"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type Engine struct {
	store *data.SeedStore
}

func NewEngine(store *data.SeedStore) *Engine {
	return &Engine{store: store}
}

// Plan calculates multi-modal transit options between coordinates or named POIs
func (e *Engine) Plan(req model.TransitPlanRequest) (*model.TransitPlanResponse, error) {
	resp := &model.TransitPlanResponse{
		OriginName: req.OriginName,
		DestName:   req.DestName,
		Options:    make([]model.RouteOption, 0),
	}

	cityStations := e.store.MetroStations[req.CityID]
	cityLines := e.store.MetroLines[req.CityID]
	cityBuses := e.store.BusRoutes[req.CityID]
	cityStops := e.store.BusStops[req.CityID]

	// Distance from origin to dest directly
	directDistKm := haversineDistance(req.OriginLat, req.OriginLng, req.DestLat, req.DestLng)
	if directDistKm < 0.8 {
		// Pure walking route
		walkMin := int(math.Ceil(directDistKm / 4.5 * 60))
		resp.Options = append(resp.Options, model.RouteOption{
			ID:            "walk_direct",
			Summary:       fmt.Sprintf("Direct Walk (%d min)", walkMin),
			TotalMinutes:  walkMin,
			WalkMinutes:   walkMin,
			Transfers:     0,
			EstimatedFare: "Free",
			Accessible:    true,
			Legs: []model.TransitLeg{
				{
					Type:            model.LegWalk,
					FromStationName: req.OriginName,
					ToStationName:   req.DestName,
					DurationMinutes: walkMin,
					DistanceMeters:  int(directDistKm * 1000),
					Instruction:     fmt.Sprintf("Walk %.1f km directly to %s", directDistKm, req.DestName),
				},
			},
		})
		return resp, nil
	}

	// Find nearest stations
	var nearestOriginStation *model.MetroStation
	minOriginDist := 999999.0
	for i := range cityStations {
		stn := &cityStations[i]
		if req.Preference == "accessible" && !stn.ElevatorAccessible {
			continue
		}
		d := haversineDistance(req.OriginLat, req.OriginLng, stn.Latitude, stn.Longitude)
		if d < minOriginDist {
			minOriginDist = d
			nearestOriginStation = stn
		}
	}

	var nearestDestStation *model.MetroStation
	minDestDist := 999999.0
	for i := range cityStations {
		stn := &cityStations[i]
		if req.Preference == "accessible" && !stn.ElevatorAccessible {
			continue
		}
		d := haversineDistance(req.DestLat, req.DestLng, stn.Latitude, stn.Longitude)
		if d < minDestDist {
			minDestDist = d
			nearestDestStation = stn
		}
	}

	if nearestOriginStation != nil && nearestDestStation != nil {
		// Try finding direct line connecting them
		var directLine *model.MetroLine
		for _, l := range cityLines {
			hasOrigin := containsString(l.StationIDs, nearestOriginStation.ID)
			hasDest := containsString(l.StationIDs, nearestDestStation.ID)
			if hasOrigin && hasDest {
				directLine = &l
				break
			}
		}

		walkToStationMin := int(math.Ceil(minOriginDist / 4.5 * 60))
		walkFromStationMin := int(math.Ceil(minDestDist / 4.5 * 60))

		if directLine != nil {
			metroMin := calculateMetroRideMin(directLine, nearestOriginStation.ID, nearestDestStation.ID)
			totalMin := walkToStationMin + metroMin + walkFromStationMin

			resp.Options = append(resp.Options, model.RouteOption{
				ID:            fmt.Sprintf("metro_direct_%s", directLine.ID),
				Summary:       fmt.Sprintf("%s Direct • %d min", directLine.Name, totalMin),
				TotalMinutes:  totalMin,
				WalkMinutes:   walkToStationMin + walkFromStationMin,
				Transfers:     0,
				EstimatedFare: getEstimatedFare(req.CityID),
				Accessible:    nearestOriginStation.ElevatorAccessible && nearestDestStation.ElevatorAccessible,
				Legs: []model.TransitLeg{
					{
						Type:            model.LegWalk,
						FromStationName: req.OriginName,
						ToStationName:   nearestOriginStation.Name,
						DurationMinutes: walkToStationMin,
						DistanceMeters:  int(minOriginDist * 1000),
						Instruction:     fmt.Sprintf("Walk to %s (approx. %d min)", nearestOriginStation.Name, walkToStationMin),
					},
					{
						Type:            model.LegMetro,
						LineID:          directLine.ID,
						LineName:        directLine.Name,
						LineColorHex:    directLine.ColorHex,
						FromStationID:   nearestOriginStation.ID,
						FromStationName: nearestOriginStation.Name,
						ToStationID:     nearestDestStation.ID,
						ToStationName:   nearestDestStation.Name,
						DurationMinutes: metroMin,
						DistanceMeters:  int(metroMin * 450),
						Instruction:     fmt.Sprintf("Board %s at %s, ride to %s", directLine.Name, nearestOriginStation.Name, nearestDestStation.Name),
					},
					{
						Type:            model.LegWalk,
						FromStationName: nearestDestStation.Name,
						ToStationName:   req.DestName,
						DurationMinutes: walkFromStationMin,
						DistanceMeters:  int(minDestDist * 1000),
						Instruction:     fmt.Sprintf("Exit station towards %s (approx. %d min)", req.DestName, walkFromStationMin),
					},
				},
			})
		} else {
			// Find transfer route
			transferOption := e.find1TransferRoute(cityLines, nearestOriginStation, nearestDestStation, walkToStationMin, walkFromStationMin, req.CityID, req.OriginName, req.DestName)
			if transferOption != nil {
				resp.Options = append(resp.Options, *transferOption)
			}
		}
	}

	// Try finding Multi-Modal (Metro + Bus or Bus-only)
	if len(cityBuses) > 0 && len(cityStops) > 0 {
		busOption := e.findBusOrMultiModalOption(cityBuses, cityStops, req)
		if busOption != nil {
			resp.Options = append(resp.Options, *busOption)
		}
	}

	// If no transit found, provide walking/general fallback
	if len(resp.Options) == 0 {
		walkMin := int(math.Ceil(directDistKm / 4.2 * 60))
		resp.Options = append(resp.Options, model.RouteOption{
			ID:            "walk_fallback",
			Summary:       fmt.Sprintf("Walking / Cab Route (%d min)", walkMin),
			TotalMinutes:  walkMin,
			WalkMinutes:   walkMin,
			Transfers:     0,
			EstimatedFare: "Free / Local Taxi",
			Accessible:    true,
			Legs: []model.TransitLeg{
				{
					Type:            model.LegWalk,
					FromStationName: req.OriginName,
					ToStationName:   req.DestName,
					DurationMinutes: walkMin,
					DistanceMeters:  int(directDistKm * 1000),
					Instruction:     fmt.Sprintf("Travel %.1f km from %s to %s", directDistKm, req.OriginName, req.DestName),
				},
			},
		})
	}

	return resp, nil
}

func (e *Engine) find1TransferRoute(lines []model.MetroLine, originStn, destStn *model.MetroStation, walkInMin, walkOutMin int, cityID, origName, destName string) *model.RouteOption {
	for _, l1 := range lines {
		if !containsString(l1.StationIDs, originStn.ID) {
			continue
		}
		for _, l2 := range lines {
			if l1.ID == l2.ID || !containsString(l2.StationIDs, destStn.ID) {
				continue
			}
			// Find common station between l1 and l2
			for _, transferStnID := range l1.StationIDs {
				if containsString(l2.StationIDs, transferStnID) {
					var transferStnName = transferStnID
					for _, s := range e.store.MetroStations[cityID] {
						if s.ID == transferStnID {
							transferStnName = s.Name
							break
						}
					}

					ride1 := calculateMetroRideMin(&l1, originStn.ID, transferStnID)
					ride2 := calculateMetroRideMin(&l2, transferStnID, destStn.ID)
					transferWalk := 4
					totalMin := walkInMin + ride1 + transferWalk + ride2 + walkOutMin

					return &model.RouteOption{
						ID:            fmt.Sprintf("transfer_%s_%s", l1.ID, l2.ID),
						Summary:       fmt.Sprintf("%s ➔ %s (1 Transfer) • %d min", l1.Name, l2.Name, totalMin),
						TotalMinutes:  totalMin,
						WalkMinutes:   walkInMin + transferWalk + walkOutMin,
						Transfers:     1,
						EstimatedFare: getEstimatedFare(cityID),
						Accessible:    originStn.ElevatorAccessible && destStn.ElevatorAccessible,
						Legs: []model.TransitLeg{
							{
								Type:            model.LegWalk,
								FromStationName: origName,
								ToStationName:   originStn.Name,
								DurationMinutes: walkInMin,
								DistanceMeters:  walkInMin * 75,
								Instruction:     fmt.Sprintf("Walk to %s", originStn.Name),
							},
							{
								Type:            model.LegMetro,
								LineID:          l1.ID,
								LineName:        l1.Name,
								LineColorHex:    l1.ColorHex,
								FromStationID:   originStn.ID,
								FromStationName: originStn.Name,
								ToStationID:     transferStnID,
								ToStationName:   transferStnName,
								DurationMinutes: ride1,
								Instruction:     fmt.Sprintf("Take %s to %s", l1.Name, transferStnName),
							},
							{
								Type:            model.LegWalk,
								FromStationName: transferStnName,
								ToStationName:   transferStnName,
								DurationMinutes: transferWalk,
								Instruction:     fmt.Sprintf("Transfer to %s inside station (approx. %d min)", l2.Name, transferWalk),
							},
							{
								Type:            model.LegMetro,
								LineID:          l2.ID,
								LineName:        l2.Name,
								LineColorHex:    l2.ColorHex,
								FromStationID:   transferStnID,
								FromStationName: transferStnName,
								ToStationID:     destStn.ID,
								ToStationName:   destStn.Name,
								DurationMinutes: ride2,
								Instruction:     fmt.Sprintf("Take %s to %s", l2.Name, destStn.Name),
							},
							{
								Type:            model.LegWalk,
								FromStationName: destStn.Name,
								ToStationName:   destName,
								DurationMinutes: walkOutMin,
								DistanceMeters:  walkOutMin * 75,
								Instruction:     fmt.Sprintf("Exit station towards %s", destName),
							},
						},
					}
				}
			}
		}
	}
	return nil
}

func (e *Engine) findBusOrMultiModalOption(buses []model.BusRoute, stops []model.BusStop, req model.TransitPlanRequest) *model.RouteOption {
	bus := buses[0]
	busRideMin := 14
	walkMin := 6
	totalMin := walkMin + busRideMin

	return &model.RouteOption{
		ID:            fmt.Sprintf("bus_route_%s", bus.ID),
		Summary:       fmt.Sprintf("Bus %s • %d min", bus.RouteNumber, totalMin),
		TotalMinutes:  totalMin,
		WalkMinutes:   walkMin,
		Transfers:     0,
		EstimatedFare: bus.Fare,
		Accessible:    bus.LowFloor,
		Legs: []model.TransitLeg{
			{
				Type:            model.LegWalk,
				FromStationName: req.OriginName,
				ToStationName:   stops[0].Name,
				DurationMinutes: 3,
				DistanceMeters:  200,
				Instruction:     fmt.Sprintf("Walk 3 min to %s", stops[0].Name),
			},
			{
				Type:            model.LegBus,
				LineID:          bus.ID,
				LineName:        bus.Name,
				LineColorHex:    bus.ColorHex,
				FromStationID:   stops[0].ID,
				FromStationName: stops[0].Name,
				ToStationID:     stops[len(stops)-1].ID,
				ToStationName:   stops[len(stops)-1].Name,
				DurationMinutes: busRideMin,
				DistanceMeters:  3200,
				Instruction:     fmt.Sprintf("Board Bus %s (%s)", bus.RouteNumber, bus.Name),
			},
			{
				Type:            model.LegWalk,
				FromStationName: stops[len(stops)-1].Name,
				ToStationName:   req.DestName,
				DurationMinutes: 3,
				DistanceMeters:  220,
				Instruction:     fmt.Sprintf("Alight and walk to %s", req.DestName),
			},
		},
	}
}

func calculateMetroRideMin(line *model.MetroLine, fromID, toID string) int {
	idx1, idx2 := -1, -1
	for i, sid := range line.StationIDs {
		if sid == fromID {
			idx1 = i
		}
		if sid == toID {
			idx2 = i
		}
	}
	if idx1 == -1 || idx2 == -1 {
		return 10
	}
	diff := int(math.Abs(float64(idx2 - idx1)))
	if diff == 0 {
		return 3
	}
	// Average 2.5 minutes between metro stations
	return int(float64(diff)*2.5) + 2
}

func getEstimatedFare(cityID string) string {
	switch cityID {
	case "seoul":
		return "₩1,400"
	case "tokyo":
		return "¥210"
	case "london":
		return "£2.80"
	case "paris":
		return "€2.15"
	case "newyork":
		return "$2.90"
	case "singapore":
		return "S$1.45"
	default:
		return "Standard Transit Fare"
	}
}

func haversineDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const earthRadiusKm = 6371.0
	dLat := (lat2 - lat1) * (math.Pi / 180.0)
	dLon := (lon2 - lon1) * (math.Pi / 180.0)

	rLat1 := lat1 * (math.Pi / 180.0)
	rLat2 := lat2 * (math.Pi / 180.0)

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Sin(dLon/2)*math.Sin(dLon/2)*math.Cos(rLat1)*math.Cos(rLat2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadiusKm * c
}

func containsString(list []string, item string) bool {
	for _, s := range list {
		if s == item {
			return true
		}
	}
	return false
}

