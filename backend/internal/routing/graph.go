package routing

import (
	"container/heap"
	"crypto/sha256"
	"fmt"
	"math"
	"strings"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type transitPoint struct {
	id, name string
	lat, lng float64
	station  *model.MetroStation
}
type transitEdge struct {
	to                        int
	route                     string
	kind                      model.LegType
	lineID, name, color, fare string
	minutes, meters, wait     int
	accessible                bool
}
type transitGraph struct {
	points []transitPoint
	edges  [][]transitEdge
}
type routeState struct {
	node    int
	route   string
	onboard bool
}
type routeCost struct{ minutes, walk, transfers int }
type pathLabel struct {
	state              routeState
	cost               routeCost
	previous           *pathLabel
	edge               transitEdge
	boarding, transfer int
	sequence           int
}
type pathQueue struct {
	labels     []*pathLabel
	preference string
}

func (q pathQueue) Len() int { return len(q.labels) }
func (q pathQueue) Less(i, j int) bool {
	a, b := q.labels[i], q.labels[j]
	if a.cost == b.cost {
		return a.sequence < b.sequence
	}
	return costLess(a.cost, b.cost, q.preference)
}
func (q pathQueue) Swap(i, j int)   { q.labels[i], q.labels[j] = q.labels[j], q.labels[i] }
func (q *pathQueue) Push(value any) { q.labels = append(q.labels, value.(*pathLabel)) }
func (q *pathQueue) Pop() any {
	last := q.labels[len(q.labels)-1]
	q.labels = q.labels[:len(q.labels)-1]
	return last
}
func costLess(a, b routeCost, preference string) bool {
	if preference == "least_walking" && a.walk != b.walk {
		return a.walk < b.walk
	}
	if preference == "min_transfers" && a.transfers != b.transfers {
		return a.transfers < b.transfers
	}
	if a.minutes != b.minutes {
		return a.minutes < b.minutes
	}
	if a.transfers != b.transfers {
		return a.transfers < b.transfers
	}
	return a.walk < b.walk
}
func walkingMinutes(km float64) int { return int(math.Ceil(km / 4.5 * 60)) }
func (p transitPoint) boardable() bool {
	return p.station == nil || (p.station.ElevatorAccessible && p.station.WheelchairBoarding)
}

func (e *Engine) buildGraph(city string) transitGraph {
	g := transitGraph{}
	index := map[string]int{}
	for i := range e.store.MetroStations[city] {
		station := &e.store.MetroStations[city][i]
		index["m:"+station.ID] = len(g.points)
		g.points = append(g.points, transitPoint{id: station.ID, name: station.Name, lat: station.Latitude, lng: station.Longitude, station: station})
	}
	for _, stop := range e.store.BusStops[city] {
		index["b:"+stop.ID] = len(g.points)
		g.points = append(g.points, transitPoint{id: stop.ID, name: stop.Name, lat: stop.Latitude, lng: stop.Longitude})
	}
	g.edges = make([][]transitEdge, len(g.points))
	for _, line := range e.store.MetroLines[city] {
		ids := line.StationIDs
		if len(ids) > 1 && ids[0] == ids[len(ids)-1] {
			ids = ids[:len(ids)-1]
		}
		for i := 0; i < len(ids); i++ {
			j := i + 1
			if j == len(ids) {
				if !line.IsCircular || len(ids) < 2 {
					break
				}
				j = 0
			}
			a, aOK := index["m:"+ids[i]]
			b, bOK := index["m:"+ids[j]]
			if !aOK || !bOK || a == b {
				continue
			}
			meters := int(haversineDistance(g.points[a].lat, g.points[a].lng, g.points[b].lat, g.points[b].lng) * 1000)
			edge := transitEdge{to: b, route: "m:" + line.ID, kind: model.LegMetro, lineID: line.ID, name: line.Name, color: line.ColorHex, fare: getEstimatedFare(city), minutes: 3, meters: meters, wait: 2, accessible: true}
			g.edges[a] = append(g.edges[a], edge)
			edge.to = a
			g.edges[b] = append(g.edges[b], edge)
		}
	}
	for _, bus := range e.store.BusRoutes[city] {
		for i := 0; i+1 < len(bus.StopIDs); i++ {
			a, aOK := index["b:"+bus.StopIDs[i]]
			b, bOK := index["b:"+bus.StopIDs[i+1]]
			if !aOK || !bOK || a == b {
				continue
			}
			km := haversineDistance(g.points[a].lat, g.points[a].lng, g.points[b].lat, g.points[b].lng)
			wait := max(0, int(math.Ceil(float64(bus.IntervalMin)/2)))
			g.edges[a] = append(g.edges[a], transitEdge{to: b, route: "b:" + bus.ID, kind: model.LegBus, lineID: bus.ID, name: bus.Name, color: bus.ColorHex, fare: bus.Fare, minutes: int(math.Ceil(km/20*60)) + 1, meters: int(km * 1000), wait: wait, accessible: bus.LowFloor})
		}
	}
	// Short inter-stop walks connect services. These distances are estimates,
	// not verified pedestrian paths or evidence of sidewalk accessibility.
	for a := 0; a < len(g.points); a++ {
		for b := a + 1; b < len(g.points); b++ {
			km := haversineDistance(g.points[a].lat, g.points[a].lng, g.points[b].lat, g.points[b].lng)
			if km > .3 {
				continue
			}
			edge := transitEdge{to: b, kind: model.LegWalk, minutes: max(1, walkingMinutes(km)), meters: int(km * 1000), accessible: g.points[a].boardable() && g.points[b].boardable()}
			g.edges[a] = append(g.edges[a], edge)
			edge.to = a
			g.edges[b] = append(g.edges[b], edge)
		}
	}
	return g
}

func (g *transitGraph) shortest(req model.TransitPlanRequest, mode model.LegType) *model.RouteOption {
	best := map[routeState]*pathLabel{}
	queue := &pathQueue{preference: req.Preference}
	sequence := 0
	push := func(label *pathLabel) {
		if old := best[label.state]; old != nil && !costLess(label.cost, old.cost, req.Preference) {
			return
		}
		sequence++
		label.sequence = sequence
		best[label.state] = label
		heap.Push(queue, label)
	}
	for node, p := range g.points {
		km := haversineDistance(req.OriginLat, req.OriginLng, p.lat, p.lng)
		if km > 1.5 || (req.Preference == "accessible" && !p.boardable()) {
			continue
		}
		minutes := walkingMinutes(km)
		push(&pathLabel{state: routeState{node: node}, cost: routeCost{minutes: minutes, walk: minutes}, edge: transitEdge{to: node, kind: model.LegWalk, minutes: minutes, meters: int(km * 1000)}})
	}
	var winner *pathLabel
	var winnerCost routeCost
	for queue.Len() > 0 {
		current := heap.Pop(queue).(*pathLabel)
		if best[current.state] != current {
			continue
		}
		p := g.points[current.state.node]
		km := haversineDistance(req.DestLat, req.DestLng, p.lat, p.lng)
		if km <= 1.5 && current.state.route != "" && (req.Preference != "accessible" || p.boardable()) {
			cost := current.cost
			cost.minutes += walkingMinutes(km)
			cost.walk += walkingMinutes(km)
			if winner == nil || costLess(cost, winnerCost, req.Preference) {
				winner, winnerCost = current, cost
			}
		}
		for _, edge := range g.edges[current.state.node] {
			if edge.kind != model.LegWalk && mode != "" && edge.kind != mode {
				continue
			}
			state := routeState{node: edge.to, route: current.state.route}
			cost := current.cost
			wait, transfer := 0, 0
			if edge.kind == model.LegWalk {
				if req.Preference == "accessible" && !edge.accessible {
					continue
				}
				cost.walk += edge.minutes
			} else {
				state.route, state.onboard = edge.route, true
				boarding := !current.state.onboard || current.state.route != edge.route
				if req.Preference == "accessible" && (!edge.accessible || (boarding && !p.boardable())) {
					continue
				}
				if boarding {
					wait = edge.wait
					if current.state.route != "" {
						transfer = 4
						cost.transfers++
						cost.walk += transfer
					}
				}
			}
			cost.minutes += edge.minutes + wait + transfer
			push(&pathLabel{state: state, cost: cost, previous: current, edge: edge, boarding: wait, transfer: transfer})
		}
	}
	if winner == nil {
		return nil
	}
	return g.option(req, winner, winnerCost)
}

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
			legs = append(legs, model.TransitLeg{Type: model.LegWalk, FromStationID: from.id, ToStationID: from.id, FromStationName: from.name, ToStationName: from.name, DurationMinutes: label.transfer, Instruction: "Allow 4 min to transfer (estimated)"})
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
		legs = append(legs, model.TransitLeg{Type: edge.kind, LineID: edge.lineID, LineName: edge.name, LineColorHex: edge.color, FromStationID: from.id, ToStationID: to.id, FromStationName: from.name, ToStationName: to.name, DurationMinutes: edge.minutes + label.boarding, DistanceMeters: edge.meters})
	}
	end := g.points[winner.state.node]
	accessible = accessible && end.boardable()
	km := haversineDistance(end.lat, end.lng, req.DestLat, req.DestLng)
	legs = append(legs, model.TransitLeg{Type: model.LegWalk, FromStationID: end.id, FromStationName: end.name, ToStationName: req.DestName, DurationMinutes: walkingMinutes(km), DistanceMeters: int(km * 1000)})
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
	return &model.RouteOption{ID: fmt.Sprintf("graph_%x", id[:8]), Summary: fmt.Sprintf("%s (estimated) • %d min", strings.Join(names, " → "), cost.minutes), TotalMinutes: cost.minutes, WalkMinutes: cost.walk, Transfers: cost.transfers, EstimatedFare: strings.Join(fares, " + "), Accessible: accessible, AccessibilityNote: "Transit boarding and transfer facilities only; walking paths and elevator outages are unverified.", Legs: legs}
}
