package routing

import (
	"fmt"
	"math"
	"sort"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type Engine struct {
	store *data.SeedStore
}

func NewEngine(store *data.SeedStore) *Engine {
	return &Engine{store: store}
}

// Plan searches the supplied transit graph. Travel and walk times are estimates.
func (e *Engine) Plan(req model.TransitPlanRequest) (*model.TransitPlanResponse, error) {
	if err := ValidateRequest(req); err != nil {
		return nil, err
	}
	resp := &model.TransitPlanResponse{OriginName: req.OriginName, DestName: req.DestName, Options: []model.RouteOption{}}
	graph := e.buildGraph(req.CityID)
	seen := map[string]bool{}
	for _, mode := range []model.LegType{"", model.LegMetro, model.LegBus} {
		option := graph.shortest(req, mode)
		if option != nil && !seen[option.ID] {
			seen[option.ID] = true
			resp.Options = append(resp.Options, *option)
		}
	}
	km := haversineDistance(req.OriginLat, req.OriginLng, req.DestLat, req.DestLng)
	if km < .8 || len(resp.Options) == 0 {
		minutes := walkingMinutes(km)
		id := "walk_direct"
		if km >= .8 {
			id = "walk_fallback"
		}
		resp.Options = append(resp.Options, model.RouteOption{ID: id, Summary: fmt.Sprintf("Straight-line walking estimate • %d min", minutes), TotalMinutes: minutes, WalkMinutes: minutes, EstimatedFare: "Free", Accessible: false, Legs: []model.TransitLeg{
			{Type: model.LegWalk, FromStationName: req.OriginName, ToStationName: req.DestName, DurationMinutes: minutes, DistanceMeters: int(km * 1000), Instruction: "Estimated straight-line distance; pedestrian route and accessibility are unverified"},
		}})
	}
	sort.SliceStable(resp.Options, func(i, j int) bool { return routeLess(resp.Options[i], resp.Options[j], req.Preference) })
	return resp, nil
}
func boardingDoor(station *model.MetroStation, lineID, fromStationID, nextLineID string) string {
	for _, guide := range station.BoardingGuidance {
		if guide.LineID == lineID && guide.FromStationID == fromStationID && guide.NextLineID == nextLineID {
			return guide.Door
		}
	}
	return ""
}

// ValidateRequest rejects invalid coordinates before distance calculations.
func ValidateRequest(req model.TransitPlanRequest) error {
	for _, point := range [][2]float64{{req.OriginLat, req.OriginLng}, {req.DestLat, req.DestLng}} {
		if math.IsNaN(point[0]) || math.IsInf(point[0], 0) || math.Abs(point[0]) > 90 || math.IsNaN(point[1]) || math.IsInf(point[1], 0) || math.Abs(point[1]) > 180 {
			return fmt.Errorf("coordinates must have latitude in [-90, 90] and longitude in [-180, 180]")
		}
	}
	switch req.Preference {
	case "", "fastest", "min_transfers", "least_walking", "accessible":
		return nil
	default:
		return fmt.Errorf("unsupported route preference: %s", req.Preference)
	}
}

func routeLess(a, b model.RouteOption, preference string) bool {
	switch preference {
	case "least_walking":
		if a.WalkMinutes != b.WalkMinutes {
			return a.WalkMinutes < b.WalkMinutes
		}
	case "min_transfers":
		if a.Transfers != b.Transfers {
			return a.Transfers < b.Transfers
		}
	}
	return a.TotalMinutes < b.TotalMinutes
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
	a = math.Max(0, math.Min(1, a))
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadiusKm * c
}
