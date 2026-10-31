package routing

import (
	"container/heap"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type routeState struct {
	node    int
	route   string
	onboard bool
}

type routeCost struct {
	minutes, walk, transfers int
}

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
		push(&pathLabel{
			state: routeState{node: node}, cost: routeCost{minutes: minutes, walk: minutes},
			edge: transitEdge{to: node, kind: model.LegWalk, minutes: minutes, meters: int(km * 1000)},
		})
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

