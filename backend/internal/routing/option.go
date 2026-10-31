package routing

import (
	"crypto/sha256"
	"fmt"
	"strings"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (g *transitGraph) option(req model.TransitPlanRequest, winner *pathLabel, cost routeCost) *model.RouteOption {
	path := []*pathLabel{}
	for label := winner; label != nil; label = label.previous {
		path = append(path, label)
	}
	legs := []model.TransitLeg{}
	accessible := true
	names, fares := []string{}, []string{}
	seenFare := map[string]bool{}
	for i := len(path) - 1; i >= 0; i-- {
		label := path[i]
		edge := label.edge
		to := g.points[label.state.node]
		from := transitPoint{name: req.OriginName}
		if label.previous != nil {
			from = g.points[label.previous.state.node]
		}
		if label.transfer > 0 {
			legs = append(legs, model.TransitLeg{
				Type: model.LegWalk, FromStationID: from.id, ToStationID: from.id,
				FromStationName: from.name, ToStationName: from.name,
				DurationMinutes: label.transfer, Instruction: "Allow 4 min to transfer (estimated)",
			})
		}
		if edge.kind == model.LegWalk && label.previous != nil && label.previous.state.onboard {
			accessible = accessible && from.boardable()
		}
		if edge.kind != model.LegWalk {
			if !edge.accessible {
				accessible = false
			}
			if label.previous == nil || !label.previous.state.onboard || label.previous.state.route != edge.route {
				accessible = accessible && from.boardable()
				names = append(names, edge.name)
			}
			if !seenFare[edge.fare] && edge.fare != "" {
				seenFare[edge.fare] = true
				fares = append(fares, edge.fare)
			}
			if len(legs) > 0 {
				last := &legs[len(legs)-1]
				if last.Type == edge.kind && last.LineID == edge.lineID && last.ToStationID == from.id {
					last.IntermediateStops = append(last.IntermediateStops, from.id)
					last.ToStationID, last.ToStationName = to.id, to.name
					last.DurationMinutes += edge.minutes + label.boarding
					last.DistanceMeters += edge.meters
					continue
				}
			}
		}
		legs = append(legs, model.TransitLeg{
			Type: edge.kind, LineID: edge.lineID, LineName: edge.name, LineColorHex: edge.color,
			FromStationID: from.id, ToStationID: to.id, FromStationName: from.name, ToStationName: to.name,
			DurationMinutes: edge.minutes + label.boarding, DistanceMeters: edge.meters,
		})
	}
	end := g.points[winner.state.node]
	accessible = accessible && end.boardable()
	km := haversineDistance(end.lat, end.lng, req.DestLat, req.DestLng)
	legs = append(legs, model.TransitLeg{
		Type: model.LegWalk, FromStationID: end.id, FromStationName: end.name,
		ToStationName: req.DestName, DurationMinutes: walkingMinutes(km), DistanceMeters: int(km * 1000),
	})
	for i := range legs {
		leg := &legs[i]
		if leg.Type == model.LegWalk {
			if leg.Instruction == "" {
				leg.Instruction = fmt.Sprintf("Walk to %s (straight-line estimate)", leg.ToStationName)
			}
			continue
		}
		leg.Instruction = fmt.Sprintf("Take %s from %s to %s (estimated, including boarding wait)", leg.LineName, leg.FromStationName, leg.ToStationName)
		if leg.Type == model.LegMetro {
			for _, p := range g.points {
				if p.station == nil || p.id != leg.ToStationID {
					continue
				}
				nextLine := ""
				for j := i + 1; j < len(legs); j++ {
					if legs[j].Type != model.LegWalk {
						nextLine = legs[j].LineID
						break
					}
				}
				leg.FastTransferDoor = boardingDoor(p.station, leg.LineID, leg.FromStationID, nextLine)
			}
		}
	}
	signature := ""
	for _, leg := range legs {
		signature += string(leg.Type) + ":" + leg.LineID + ":" + leg.FromStationID + ":" + leg.ToStationID + ";"
	}
	id := sha256.Sum256([]byte(signature))
	return &model.RouteOption{
		ID: fmt.Sprintf("graph_%x", id[:8]), Summary: fmt.Sprintf("%s (estimated) • %d min", strings.Join(names, " → "), cost.minutes),
		TotalMinutes: cost.minutes, WalkMinutes: cost.walk, Transfers: cost.transfers, EstimatedFare: strings.Join(fares, " + "),
		Accessible: accessible, AccessibilityNote: "Transit boarding and transfer facilities only; walking paths and elevator outages are unverified.",
		Legs: legs,
	}
}

