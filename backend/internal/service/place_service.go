package service

import (
	"fmt"
	"strings"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (s *ServiceContainer) SearchPlaces(cityID, query, category string) []model.Place {
	places := s.Store.Places[cityID]
	var results []model.Place
	q := strings.ToLower(query)
	cat := strings.ToLower(category)

	for _, p := range places {
		matchQuery := q == "" ||
			strings.Contains(strings.ToLower(p.Name), q) ||
			strings.Contains(strings.ToLower(p.EnglishName), q) ||
			strings.Contains(strings.ToLower(p.Description), q)

		matchCat := cat == "" || strings.ToLower(string(p.Category)) == cat

		if matchQuery && matchCat {
			results = append(results, p)
		}
	}
	return results
}

func (s *ServiceContainer) GetPlace(cityID, placeID string) (*model.Place, error) {
	places := s.Store.Places[cityID]
	for _, p := range places {
		if p.ID == placeID {
			return &p, nil
		}
	}
	return nil, fmt.Errorf("place not found: %s in %s", placeID, cityID)
}

