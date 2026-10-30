package service

import (
	"errors"
	"fmt"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

var ErrInvalidInput = errors.New("invalid input")
var ErrNotFound = errors.New("not found")

func cloneTrip(trip model.Trip) model.Trip {
	trip.Collaborators = append([]string{}, trip.Collaborators...)
	days := make([]model.TripDay, len(trip.Days))
	for i, day := range trip.Days {
		days[i] = day
		days[i].Items = append([]model.ItineraryItem{}, day.Items...)
	}
	trip.Days = days
	return trip
}

// enrichTrip uses cached forecasts only, so listing trips never blocks on a provider.
// The caller holds s.mu for reading or writing.
func (s *ServiceContainer) enrichTrip(trip model.Trip) model.Trip {
	trip = cloneTrip(trip)
	for d := range trip.Days {
		day := &trip.Days[d]
		day.DayWeather = nil
		day.WeatherNote = "Forecast unavailable for this date"
		if report, ok := s.Store.WeatherReports[day.CityID]; ok {
			for _, forecast := range report.Daily {
				if forecast.Date != day.DateStr {
					continue
				}
				day.DayWeather = &model.DayWeatherInfo{
					Condition: forecast.Condition, TempMaxC: forecast.TempMaxC, TempMinC: forecast.TempMinC,
					PrecipProb: forecast.PrecipProb, RainAlert: forecast.PrecipProb >= 50,
				}
				if day.DayWeather.RainAlert {
					day.DayWeather.IndoorTip = "Rain is likely. Consider a museum, gallery, or another indoor stop."
				}
				day.WeatherNote = fmt.Sprintf("%s · %.0f–%.0f°C · Rain %d%%", forecast.Condition, forecast.TempMinC, forecast.TempMaxC, forecast.PrecipProb)
				break
			}
		}
		for i := range day.Items {
			day.Items[i].RouteFromPrevious = nil
			if i == 0 {
				continue
			}
			from, to := day.Items[i-1], day.Items[i]
			plan, err := s.RoutingEngine.Plan(model.TransitPlanRequest{
				CityID: day.CityID, OriginLat: from.Latitude, OriginLng: from.Longitude, OriginName: from.Title,
				DestLat: to.Latitude, DestLng: to.Longitude, DestName: to.Title, Preference: "fastest",
			})
			if err == nil && len(plan.Options) > 0 {
				day.Items[i].RouteFromPrevious = &plan.Options[0]
			}
		}
	}
	return trip
}

func (s *ServiceContainer) CompleteItineraryItem(tripID, itemID string, completed bool) (*model.Trip, error) {
	return s.UpdateItineraryItem(tripID, itemID, ItemPatch{IsCompleted: &completed})
}
