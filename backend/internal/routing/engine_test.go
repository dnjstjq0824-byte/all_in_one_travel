package routing

import (
	"math"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestBusFollowsRouteOrderAndCoordinates(t *testing.T) {
	e := NewEngine(&data.SeedStore{})
	// Storage order differs from the route's directional stop sequence.
	stops := []model.BusStop{{ID: "c", Longitude: .04}, {ID: "unrelated", Longitude: .01}, {ID: "a"}, {ID: "b", Longitude: .02}}
	buses := []model.BusRoute{{ID: "route", StopIDs: []string{"a", "b", "c"}, IntervalMin: 10}}
	e = testEngine(nil, nil, stops, buses)
	graph := e.buildGraph("test")
	option := graph.shortest(model.TransitPlanRequest{DestLng: .04}, model.LegBus)
	if option == nil {
		t.Fatal("expected forward route")
	}
	leg := option.Legs[1]
	if leg.FromStationID != "a" || leg.ToStationID != "c" {
		t.Fatalf("wrong endpoints: %+v", leg)
	}
	if len(leg.IntermediateStops) != 1 || leg.IntermediateStops[0] != "b" {
		t.Fatalf("wrong intermediate stops: %v", leg.IntermediateStops)
	}
	total := 0
	for _, l := range option.Legs {
		total += l.DurationMinutes
	}
	if total != option.TotalMinutes {
		t.Fatalf("leg total %d != %d", total, option.TotalMinutes)
	}
	if graph.shortest(model.TransitPlanRequest{OriginLng: .04}, model.LegBus) != nil {
		t.Fatal("invented reverse service")
	}
	if graph.shortest(model.TransitPlanRequest{OriginLat: 50, DestLat: 50}, model.LegBus) != nil {
		t.Fatal("unrelated distant route")
	}
}

func TestInvalidRoutingRequest(t *testing.T) {
	for _, req := range []model.TransitPlanRequest{{OriginLat: 91}, {DestLng: 181}, {OriginLat: math.NaN()}, {DestLat: math.Inf(1)}, {Preference: "invalid"}} {
		if _, err := NewEngine(&data.SeedStore{}).Plan(req); err == nil {
			t.Fatalf("accepted invalid request: %+v", req)
		}
	}
}

func TestBoardingDoorMatchesRideAndConnection(t *testing.T) {
	station := &model.MetroStation{BoardingGuidance: []model.BoardingGuidance{
		{LineID: "a", FromStationID: "origin", NextLineID: "b", Door: "3-2"},
	}}
	if got := boardingDoor(station, "a", "origin", "b"); got != "3-2" {
		t.Fatalf("door = %q", got)
	}
	if got := boardingDoor(station, "a", "opposite", "b"); got != "" {
		t.Fatal("guidance leaked to opposite ride")
	}
	if got := boardingDoor(station, "a", "origin", ""); got != "" {
		t.Fatal("transfer guidance used for exit")
	}
}

func TestAccessibleBusSkipsHighFloorVehicles(t *testing.T) {
	e := NewEngine(&data.SeedStore{})
	buses := []model.BusRoute{{ID: "high", StopIDs: []string{"first", "last"}}, {ID: "low", LowFloor: true, StopIDs: []string{"first", "last"}}}
	stops := []model.BusStop{{ID: "first"}, {ID: "last", Longitude: 0.02}}
	req := model.TransitPlanRequest{Preference: "accessible", DestLng: 0.02}
	e = testEngine(nil, nil, stops, buses)
	graph := e.buildGraph("test")
	option := graph.shortest(req, model.LegBus)
	if option == nil || option.Legs[1].LineID != "low" || !option.Accessible {
		t.Fatal("expected low-floor route")
	}
	e = testEngine(nil, nil, stops, buses[:1])
	graph = e.buildGraph("test")
	if graph.shortest(req, model.LegBus) != nil {
		t.Fatal("high-floor route offered for accessible preference")
	}
}
