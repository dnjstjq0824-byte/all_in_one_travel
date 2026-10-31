package service

import (
	"fmt"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (s *ServiceContainer) GetMetroLines(cityID string) []model.MetroLine {
	return s.Store.MetroLines[cityID]
}

func (s *ServiceContainer) GetMetroStations(cityID string) []model.MetroStation {
	return s.Store.MetroStations[cityID]
}

func (s *ServiceContainer) GetMetroStation(cityID, stationID string) (*model.MetroStation, error) {
	stations := s.Store.MetroStations[cityID]
	for _, stn := range stations {
		if stn.ID == stationID {
			return &stn, nil
		}
	}
	return nil, fmt.Errorf("station not found: %s in %s", stationID, cityID)
}

func (s *ServiceContainer) GetBusRoutes(cityID string) []model.BusRoute {
	return s.Store.BusRoutes[cityID]
}

func (s *ServiceContainer) GetBusStops(cityID string) []model.BusStop {
	return s.Store.BusStops[cityID]
}

func (s *ServiceContainer) GetRealtimeArrivals(stopID string) []model.RealtimeArrival {
	return s.Store.RealtimeArrivals[stopID]
}

func (s *ServiceContainer) PlanTransit(req model.TransitPlanRequest) (*model.TransitPlanResponse, error) {
	return s.RoutingEngine.Plan(req)
}
