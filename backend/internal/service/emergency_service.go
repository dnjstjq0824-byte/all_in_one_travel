package service

import (
	"fmt"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (s *ServiceContainer) GetEmergencyInfo(cityID string) (*model.EmergencyInfo, error) {
	if cityID == "" {
		return nil, fmt.Errorf("city_id parameter is required")
	}

	info, exists := s.Store.Emergencies[cityID]
	if !exists {
		return nil, fmt.Errorf("emergency info not found for city: %s", cityID)
	}

	return &info, nil
}

