package routing

import (
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func testStation(id string, lng float64) model.MetroStation {
	return model.MetroStation{ID: id, Name: id, Longitude: lng, ElevatorAccessible: true, WheelchairBoarding: true}
}
func testEngine(stations []model.MetroStation, lines []model.MetroLine, stops []model.BusStop, buses []model.BusRoute) *Engine {
	return NewEngine(&data.SeedStore{MetroStations: map[string][]model.MetroStation{"test": stations}, MetroLines: map[string][]model.MetroLine{"test": lines}, BusStops: map[string][]model.BusStop{"test": stops}, BusRoutes: map[string][]model.BusRoute{"test": buses}})
}
func assertLegTotals(t *testing.T, option *model.RouteOption) {
	t.Helper()
	total, walk := 0, 0
	for _, leg := range option.Legs {
		total += leg.DurationMinutes
		if leg.Type == model.LegWalk {
			walk += leg.DurationMinutes
		}
	}
	if total != option.TotalMinutes || walk != option.WalkMinutes {
		t.Fatalf("inconsistent totals: %+v", option)
	}
}

func TestGraphMultipleMetroTransfersAndAccessibility(t *testing.T) {
	stations := []model.MetroStation{testStation("o", 0), testStation("x", .02), testStation("y", .04), testStation("d", .06)}
	lines := []model.MetroLine{{ID: "a", StationIDs: []string{"o", "x"}}, {ID: "b", StationIDs: []string{"x", "y"}}, {ID: "c", StationIDs: []string{"y", "d"}}}
	e := testEngine(stations, lines, nil, nil)
	plan, err := e.Plan(model.TransitPlanRequest{CityID: "test", DestLng: .06, Preference: "accessible"})
	if err != nil || len(plan.Options) != 1 || plan.Options[0].Transfers != 2 || !plan.Options[0].Accessible {
		t.Fatalf("expected accessible two-transfer route: %+v %v", plan, err)
	}
	assertLegTotals(t, &plan.Options[0])
	stations[2].WheelchairBoarding = false
	plan, err = e.Plan(model.TransitPlanRequest{CityID: "test", DestLng: .06, Preference: "accessible"})
	if err != nil || len(plan.Options) != 1 || plan.Options[0].ID != "walk_fallback" || plan.Options[0].Accessible {
		t.Fatal("inaccessible interchange must not be claimed accessible")
	}
}

func TestGraphMetroBusAndBusTransfers(t *testing.T) {
	e := testEngine([]model.MetroStation{testStation("o", 0), testStation("x", .02)}, []model.MetroLine{{ID: "metro", StationIDs: []string{"o", "x"}}},
		[]model.BusStop{{ID: "b1", Longitude: .0201}, {ID: "b2", Longitude: .04}, {ID: "b3", Longitude: .06}},
		[]model.BusRoute{{ID: "bus1", StopIDs: []string{"b1", "b2"}, LowFloor: true}, {ID: "bus2", StopIDs: []string{"b2", "b3"}, LowFloor: true}})
	plan, err := e.Plan(model.TransitPlanRequest{CityID: "test", DestLng: .06})
	if err != nil || len(plan.Options) == 0 {
		t.Fatal(err)
	}
	option := plan.Options[0]
	if option.Transfers != 2 {
		t.Fatalf("expected metro + two buses, got %+v", option)
	}
	modes := []model.LegType{}
	for _, leg := range option.Legs {
		if leg.Type != model.LegWalk {
			modes = append(modes, leg.Type)
		}
	}
	if len(modes) != 3 || modes[0] != model.LegMetro || modes[1] != model.LegBus || modes[2] != model.LegBus {
		t.Fatalf("modes: %v", modes)
	}
	assertLegTotals(t, &option)
}

func TestGraphPreferencesAndAlternativeAccessStation(t *testing.T) {
	stations := []model.MetroStation{testStation("isolated", 0), testStation("o", .001), testStation("x", .04), testStation("d", .08)}
	long := []string{"o"}
	for i, id := range []string{"a", "b", "c", "e", "f", "g", "h", "i", "j"} {
		stations = append(stations, testStation(id, 1+float64(i)*.02))
		long = append(long, id)
	}
	long = append(long, "d")
	e := testEngine(stations, []model.MetroLine{{ID: "long", StationIDs: long}, {ID: "first", StationIDs: []string{"o", "x"}}, {ID: "second", StationIDs: []string{"x", "d"}}}, nil, nil)
	graph := e.buildGraph("test")
	fast := graph.shortest(model.TransitPlanRequest{DestLng: .08, Preference: "fastest"}, model.LegMetro)
	few := graph.shortest(model.TransitPlanRequest{DestLng: .08, Preference: "min_transfers"}, model.LegMetro)
	if fast == nil || few == nil || fast.Transfers != 1 || few.Transfers != 0 || fast.TotalMinutes >= few.TotalMinutes {
		t.Fatalf("preference selection failed: fast=%+v few=%+v", fast, few)
	}
	assertLegTotals(t, fast)
	assertLegTotals(t, few)
}

func TestGraphCircularLineWrapsAndBusStaysDirectional(t *testing.T) {
	stations := []model.MetroStation{testStation("a", 0), testStation("b", .02), testStation("c", .04), testStation("d", .06), testStation("e", .08)}
	e := testEngine(stations, []model.MetroLine{{ID: "circle", IsCircular: true, StationIDs: []string{"a", "b", "c", "d", "e", "a"}}}, nil, nil)
	graph := e.buildGraph("test")
	option := graph.shortest(model.TransitPlanRequest{DestLng: .08}, model.LegMetro)
	if option == nil || option.TotalMinutes != 5 {
		t.Fatalf("expected wrap edge plus wait: %+v", option)
	}
	e = testEngine(nil, nil, []model.BusStop{{ID: "a"}, {ID: "b", Longitude: .04}}, []model.BusRoute{{ID: "bus", StopIDs: []string{"a", "b"}}})
	graph = e.buildGraph("test")
	if graph.shortest(model.TransitPlanRequest{OriginLng: .04}, model.LegBus) != nil {
		t.Fatal("invented reverse bus route")
	}
}
