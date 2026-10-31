package routing

import (
	"math"

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

func walkingMinutes(km float64) int {
	return int(math.Ceil(km / 4.5 * 60))
}

func (p transitPoint) boardable() bool {
	return p.station == nil || (p.station.ElevatorAccessible && p.station.WheelchairBoarding)
}

func (e *Engine) buildGraph(city string) transitGraph {
	g := transitGraph{}
	index := map[string]int{}
	for i := range e.store.MetroStations[city] {
		station := &e.store.MetroStations[city][i]
		index["m:"+station.ID] = len(g.points)
		g.points = append(g.points, transitPoint{
			id: station.ID, name: station.Name,
			lat: station.Latitude, lng: station.Longitude, station: station,
		})
	}
	for _, stop := range e.store.BusStops[city] {
		index["b:"+stop.ID] = len(g.points)
		g.points = append(g.points, transitPoint{
			id: stop.ID, name: stop.Name, lat: stop.Latitude, lng: stop.Longitude,
		})
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
			edge := transitEdge{
				to: b, route: "m:" + line.ID, kind: model.LegMetro,
				lineID: line.ID, name: line.Name, color: line.ColorHex,
				fare: getEstimatedFare(city), minutes: 3, meters: meters, wait: 2, accessible: true,
			}
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
			g.edges[a] = append(g.edges[a], transitEdge{
				to: b, route: "b:" + bus.ID, kind: model.LegBus,
				lineID: bus.ID, name: bus.Name, color: bus.ColorHex,
				fare: bus.Fare, minutes: int(math.Ceil(km/20*60)) + 1, meters: int(km * 1000), wait: wait, accessible: bus.LowFloor,
			})
		}
	}
	// Short inter-stop walks connect services.
	for a := 0; a < len(g.points); a++ {
		for b := a + 1; b < len(g.points); b++ {
			km := haversineDistance(g.points[a].lat, g.points[a].lng, g.points[b].lat, g.points[b].lng)
			if km > .3 {
				continue
			}
			edge := transitEdge{
				to: b, kind: model.LegWalk, minutes: max(1, walkingMinutes(km)),
				meters: int(km * 1000), accessible: g.points[a].boardable() && g.points[b].boardable(),
			}
			g.edges[a] = append(g.edges[a], edge)
			edge.to = a
			g.edges[b] = append(g.edges[b], edge)
		}
	}
	return g
}

