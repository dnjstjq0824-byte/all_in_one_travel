package service

import (
	"errors"
	"strings"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestTripDatesForecastAndCompletion(t *testing.T) {
	store := data.NewSeedStore()
	store.WeatherReports["seoul"] = model.WeatherReport{Daily: []model.DailyForecast{
		{Date: "2026-11-02", Condition: "Rain", TempMinC: 10, TempMaxC: 15, PrecipProb: 80},
	}}
	s := NewServiceContainer(store)
	trip, err := s.CreateTrip(model.Trip{Title: "Weekend", CityID: "seoul", StartDate: "2026-11-01", EndDate: "2026-11-03"})
	if err != nil {
		t.Fatal(err)
	}
	if len(trip.Days) != 3 || trip.Days[2].DateStr != "2026-11-03" {
		t.Fatalf("incorrect date range: %+v", trip.Days)
	}
	if trip.Days[0].DayWeather != nil {
		t.Fatal("forecast must match the date")
	}
	weather := trip.Days[1].DayWeather
	if weather == nil || !weather.RainAlert || weather.IndoorTip == "" {
		t.Fatal("expected date-specific rain warning")
	}
	if _, err := s.AddItineraryItem(trip.ID, 4, model.ItineraryItem{Title: "Invalid"}); !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("invalid day: %v", err)
	}
	first, err := s.AddItineraryItem(trip.ID, 2, model.ItineraryItem{Title: "First", Latitude: 37.57, Longitude: 126.98})
	if err != nil {
		t.Fatal(err)
	}
	itemID := first.Days[1].Items[0].ID
	second, err := s.AddItineraryItem(trip.ID, 2, model.ItineraryItem{Title: "Second", Latitude: 37.571, Longitude: 126.981})
	if err != nil {
		t.Fatal(err)
	}
	if second.Days[1].Items[1].RouteFromPrevious == nil {
		t.Fatal("missing automatic transit route")
	}
	if len(first.Days[1].Items) != 1 {
		t.Fatal("earlier response mutated")
	}
	updated, err := s.CompleteItineraryItem(trip.ID, itemID, true)
	if err != nil || !updated.Days[1].Items[0].IsCompleted {
		t.Fatalf("completion failed: %v", err)
	}
	if first.Days[1].Items[0].IsCompleted {
		t.Fatal("response shares mutable item storage")
	}
	reloaded, err := s.GetTrip(trip.ID)
	if err != nil || !reloaded.Days[1].Items[0].IsCompleted {
		t.Fatal("completion was not saved")
	}
	if _, err := s.CompleteItineraryItem(trip.ID, "missing", true); !errors.Is(err, ErrNotFound) {
		t.Fatalf("missing item: %v", err)
	}
}

func TestTripRejectsInvalidDatesAndCreatesUniqueIDs(t *testing.T) {
	s := NewServiceContainer(data.NewSeedStore())
	for _, dates := range [][2]string{{"invalid", "2026-11-03"}, {"2026-11-03", "2026-11-01"}, {"2026-11-01", "2028-11-01"}} {
		if _, err := s.CreateTrip(model.Trip{Title: "Trip", CityID: "seoul", StartDate: dates[0], EndDate: dates[1]}); !errors.Is(err, ErrInvalidInput) {
			t.Fatalf("expected invalid input: %v", err)
		}
	}
	request := model.Trip{Title: "Trip", CityID: "seoul", StartDate: "2026-11-01", EndDate: "2026-11-01"}
	a, _ := s.CreateTrip(request)
	b, _ := s.CreateTrip(request)
	if a.ID == b.ID {
		t.Fatal("trip IDs collided")
	}
}

func TestWeatherHandlesPartialProviderArrays(t *testing.T) {
	input := `{"current":{"temperature_2m":18},"hourly":{"time":["2026-11-01T00:00"],"temperature_2m":[],"precipitation_probability":[10]},"daily":{"time":["2026-11-01"],"weather_code":[61]}}`
	report, err := decodeOpenMeteoWeather(strings.NewReader(input), 0, 0, "test", "Test")
	if err != nil {
		t.Fatal(err)
	}
	if len(report.Hourly) != 0 || len(report.Daily) != 0 {
		t.Fatal("partial records must be skipped")
	}
}
