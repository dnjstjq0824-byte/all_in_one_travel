package service

import (
	"fmt"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func (s *ServiceContainer) GetReviews(placeID string) []model.Review {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.Store.Reviews[placeID]
}

func (s *ServiceContainer) AddReview(review model.Review) (*model.Review, error) {
	if review.PlaceID == "" {
		return nil, fmt.Errorf("place_id is required")
	}
	if review.Rating < 1 || review.Rating > 5 {
		return nil, fmt.Errorf("rating must be between 1 and 5")
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	review.ID = fmt.Sprintf("rev_%d", time.Now().UnixNano())
	review.CreatedAt = time.Now()
	review.VerifiedVisit = true

	currentReviews := s.Store.Reviews[review.PlaceID]
	updatedReviews := append([]model.Review{review}, currentReviews...)

	trips := s.Store.Trips
	allReviews := make(map[string][]model.Review, len(s.Store.Reviews))
	for k, v := range s.Store.Reviews {
		allReviews[k] = v
	}
	allReviews[review.PlaceID] = updatedReviews

	if s.statePath != "" {
		if err := s.writeState(trips, allReviews); err != nil {
			return nil, fmt.Errorf("persist review: %w", err)
		}
	} else if s.database != nil {
		if err := s.writeDatabase(trips, allReviews); err != nil {
			return nil, fmt.Errorf("persist review: %w", err)
		}
	}

	s.Store.Reviews[review.PlaceID] = updatedReviews

	// Update the place review count in memory
	for cityID, places := range s.Store.Places {
		for i := range places {
			if places[i].ID == review.PlaceID {
				places[i].ReviewCount = len(updatedReviews)
			}
		}
		s.Store.Places[cityID] = places
	}

	return &review, nil
}

