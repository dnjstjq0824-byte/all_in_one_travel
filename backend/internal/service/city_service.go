package service

import (
	"fmt"
	"strings"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (s *ServiceContainer) GetCountries() []model.Country {
	return s.Store.Countries
}

func (s *ServiceContainer) GetCities(countryCode string) []model.City {
	if countryCode == "" {
		return s.Store.Cities
	}
	var filtered []model.City
	for _, c := range s.Store.Cities {
		if strings.EqualFold(c.CountryCode, countryCode) {
			filtered = append(filtered, c)
		}
	}
	return filtered
}

func (s *ServiceContainer) GetCity(cityID string) (*model.City, error) {
	for _, c := range s.Store.Cities {
		if c.ID == cityID {
			return &c, nil
		}
	}
	return nil, fmt.Errorf("city not found: %s", cityID)
}

func (s *ServiceContainer) GetCoverage(cityID string) (*model.CoverageRegistry, error) {
	cov, exists := s.Store.Coverage[cityID]
	if !exists {
		return nil, fmt.Errorf("coverage not found for city: %s", cityID)
	}
	return &cov, nil
}

func (s *ServiceContainer) ListCoverage() []model.CoverageRegistry {
	list := make([]model.CoverageRegistry, 0, len(s.Store.Coverage))
	for _, cov := range s.Store.Coverage {
		list = append(list, cov)
	}
	return list
}

