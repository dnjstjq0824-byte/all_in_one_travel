package service

import (
	"crypto/rand"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
	"github.com/bookingnetwork/global-travel-app/backend/internal/routing"
)

type ServiceContainer struct {
	Store         *data.SeedStore
	RoutingEngine *routing.Engine
	mu            sync.RWMutex
	statePath     string
	database      *sql.DB
	stateRevision int64
}

func NewServiceContainer(store *data.SeedStore) *ServiceContainer {
	return &ServiceContainer{
		Store:         store,
		RoutingEngine: routing.NewEngine(store),
	}
}

// Country & City Services
func (s *ServiceContainer) GetCountries() []model.Country {
	return s.Store.Countries
}

func (s *ServiceContainer) GetCities(countryCode string) []model.City {
	if countryCode == "" {
		return s.Store.Cities
	}
	res := make([]model.City, 0)
	for _, c := range s.Store.Cities {
		if strings.EqualFold(c.CountryCode, countryCode) {
			res = append(res, c)
		}
	}
	return res
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
		return nil, fmt.Errorf("coverage registry not found for: %s", cityID)
	}
	return &cov, nil
}

func (s *ServiceContainer) ListCoverage() []model.CoverageRegistry {
	res := make([]model.CoverageRegistry, 0, len(s.Store.Coverage))
	for _, cov := range s.Store.Coverage {
		res = append(res, cov)
	}
	return res
}

// Transit Services
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
	return nil, fmt.Errorf("station not found: %s", stationID)
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

// Places & Reviews
func (s *ServiceContainer) SearchPlaces(cityID, query, category string) []model.Place {
	places := s.Store.Places[cityID]
	if query == "" && category == "" {
		return places
	}

	q := strings.ToLower(query)
	res := make([]model.Place, 0)
	for _, p := range places {
		matchCategory := category == "" || strings.EqualFold(string(p.Category), category)
		matchQuery := query == "" ||
			strings.Contains(strings.ToLower(p.Name), q) ||
			strings.Contains(strings.ToLower(p.EnglishName), q) ||
			strings.Contains(strings.ToLower(p.Description), q)

		if matchCategory && matchQuery {
			res = append(res, p)
		}
	}
	return res
}

func (s *ServiceContainer) GetPlace(cityID, placeID string) (*model.Place, error) {
	for _, p := range s.Store.Places[cityID] {
		if p.ID == placeID {
			return &p, nil
		}
	}
	return nil, fmt.Errorf("place not found: %s", placeID)
}

func (s *ServiceContainer) GetReviews(placeID string) []model.Review {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.Store.Reviews[placeID]
}

func (s *ServiceContainer) AddReview(review model.Review) (*model.Review, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	review.ID = "rev_" + rand.Text()
	review.CreatedAt = time.Now()
	review.VerifiedVisit = false // Unverified until receipt/booking proof

	reviews := make(map[string][]model.Review, len(s.Store.Reviews)+1)
	for id, existing := range s.Store.Reviews {
		reviews[id] = existing
	}
	reviews[review.PlaceID] = append([]model.Review{review}, reviews[review.PlaceID]...)
	if err := s.writeState(s.Store.Trips, reviews); err != nil {
		return nil, err
	}
	s.Store.Reviews = reviews
	return &review, nil
}

// Weather Service with Open-Meteo Fallback
func (s *ServiceContainer) GetWeather(cityID string) (*model.WeatherReport, error) {
	s.mu.RLock()
	report, exists := s.Store.WeatherReports[cityID]
	s.mu.RUnlock()
	if exists && time.Since(report.ObservedAt) < 30*time.Minute {
		return &report, nil
	}

	city, err := s.GetCity(cityID)
	if err != nil {
		return nil, err
	}

	// Fetch live forecast from Open-Meteo (Compliant open meteorological service)
	goLive, err := fetchOpenMeteoWeather(city.Latitude, city.Longitude, city.ID, city.Name)
	if err == nil && goLive != nil {
		s.mu.Lock()
		s.Store.WeatherReports[cityID] = *goLive
		s.mu.Unlock()
		return goLive, nil
	}

	// Fallback to verified seed if offline/error
	if exists {
		return &report, nil
	}

	return nil, fmt.Errorf("no weather available for city: %s", cityID)
}

func fetchOpenMeteoWeather(lat, lng float64, cityID, cityName string) (*model.WeatherReport, error) {
	client := &http.Client{Timeout: 4 * time.Second}
	url := fmt.Sprintf("https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto", lat, lng)

	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("open-meteo returned code: %d", resp.StatusCode)
	}
	return decodeOpenMeteoWeather(resp.Body, lat, lng, cityID, cityName)
}

func decodeOpenMeteoWeather(body io.Reader, lat, lng float64, cityID, cityName string) (*model.WeatherReport, error) {
	var raw struct {
		Current struct {
			Temperature2m       float64 `json:"temperature_2m"`
			ApparentTemperature float64 `json:"apparent_temperature"`
			RelativeHumidity2m  int     `json:"relative_humidity_2m"`
			WindSpeed10m        float64 `json:"wind_speed_10m"`
			WeatherCode         int     `json:"weather_code"`
		} `json:"current"`
		Hourly struct {
			Time          []string  `json:"time"`
			Temperature2m []float64 `json:"temperature_2m"`
			PrecipProb    []int     `json:"precipitation_probability"`
			WeatherCode   []int     `json:"weather_code"`
		} `json:"hourly"`
		Daily struct {
			Time             []string  `json:"time"`
			Temperature2mMax []float64 `json:"temperature_2m_max"`
			Temperature2mMin []float64 `json:"temperature_2m_min"`
			PrecipProbMax    []int     `json:"precipitation_probability_max"`
			WeatherCode      []int     `json:"weather_code"`
		} `json:"daily"`
	}

	if err := json.NewDecoder(body).Decode(&raw); err != nil {
		return nil, err
	}

	condition, conditionKo := weatherCodeToString(raw.Current.WeatherCode)

	hourly := make([]model.HourlyForecast, 0)
	for i := 0; i < min(len(raw.Hourly.Time), len(raw.Hourly.Temperature2m), len(raw.Hourly.PrecipProb), 12); i++ {
		timePart := raw.Hourly.Time[i]
		if len(timePart) >= 16 {
			timePart = timePart[11:16]
		}
		hourCondition := condition
		if i < len(raw.Hourly.WeatherCode) {
			hourCondition, _ = weatherCodeToString(raw.Hourly.WeatherCode[i])
		}
		hourly = append(hourly, model.HourlyForecast{
			Hour:       timePart,
			TempC:      raw.Hourly.Temperature2m[i],
			Condition:  hourCondition,
			PrecipProb: raw.Hourly.PrecipProb[i],
			Icon:       "partly_cloudy",
		})
	}

	daily := make([]model.DailyForecast, 0)
	for i := 0; i < min(len(raw.Daily.Time), len(raw.Daily.WeatherCode), len(raw.Daily.Temperature2mMax), len(raw.Daily.Temperature2mMin), len(raw.Daily.PrecipProbMax), 5); i++ {
		cName, _ := weatherCodeToString(raw.Daily.WeatherCode[i])
		daily = append(daily, model.DailyForecast{
			Date:       raw.Daily.Time[i],
			DayOfWeek:  "Day",
			TempMinC:   raw.Daily.Temperature2mMin[i],
			TempMaxC:   raw.Daily.Temperature2mMax[i],
			Condition:  cName,
			PrecipProb: raw.Daily.PrecipProbMax[i],
			Icon:       "sunny",
		})
	}

	return &model.WeatherReport{
		CityID:          cityID,
		CityName:        cityName,
		Latitude:        lat,
		Longitude:       lng,
		CurrentTempC:    raw.Current.Temperature2m,
		FeelsLikeC:      raw.Current.ApparentTemperature,
		Condition:       condition,
		ConditionKorean: conditionKo,
		Humidity:        raw.Current.RelativeHumidity2m,
		WindSpeedKmH:    raw.Current.WindSpeed10m,
		UVIndex:         4,
		PrecipProb:      10,
		AirQualityIndex: "Good (AQI 30)",
		Sunrise:         "06:30",
		Sunset:          "18:00",
		Hourly:          hourly,
		Daily:           daily,
		Attribution:     "Weather data by Open-Meteo.com (CC-BY 4.0)",
		ObservedAt:      time.Now(),
	}, nil
}

func weatherCodeToString(code int) (string, string) {
	switch {
	case code == 0:
		return "Clear", "맑음"
	case code >= 1 && code <= 3:
		return "Partly Cloudy", "구름 조금"
	case code >= 45 && code <= 48:
		return "Foggy", "안개"
	case code >= 51 && code <= 67:
		return "Rain", "비"
	case code >= 71 && code <= 77:
		return "Snow", "눈"
	case code >= 80 && code <= 82:
		return "Showers", "소나기"
	case code >= 95:
		return "Thunderstorm", "뇌우"
	default:
		return "Clear", "맑음"
	}
}

// Trips Service
func (s *ServiceContainer) ListTrips() []model.Trip {
	s.mu.RLock()
	defer s.mu.RUnlock()
	res := make([]model.Trip, 0, len(s.Store.Trips))
	for _, t := range s.Store.Trips {
		res = append(res, s.enrichTrip(t))
	}
	sort.Slice(res, func(i, j int) bool {
		if res[i].CreatedAt.Equal(res[j].CreatedAt) {
			return res[i].ID < res[j].ID
		}
		return res[i].CreatedAt.After(res[j].CreatedAt)
	})
	return res
}

func (s *ServiceContainer) GetTrip(tripID string) (*model.Trip, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	t, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("trip not found: %s", tripID)
	}
	t = s.enrichTrip(t)
	return &t, nil
}

func (s *ServiceContainer) CreateTrip(trip model.Trip) (*model.Trip, error) {
	start, err := time.Parse("2006-01-02", trip.StartDate)
	if err != nil {
		return nil, fmt.Errorf("%w: invalid start date", ErrInvalidInput)
	}
	end, err := time.Parse("2006-01-02", trip.EndDate)
	if err != nil || end.Before(start) || end.Sub(start) > 365*24*time.Hour {
		return nil, fmt.Errorf("%w: end date must be within 365 days of start date", ErrInvalidInput)
	}
	if strings.TrimSpace(trip.Title) == "" || len(trip.Title) > 200 {
		return nil, fmt.Errorf("%w: trip title is required", ErrInvalidInput)
	}
	city, err := s.GetCity(trip.CityID)
	if err != nil {
		return nil, fmt.Errorf("%w: city not found", ErrInvalidInput)
	}
	trip.CityName, trip.CountryCode = city.Name, city.CountryCode
	s.mu.Lock()
	defer s.mu.Unlock()

	trip.ID = "trip_" + rand.Text()
	trip.CreatedAt = time.Now()
	trip.UpdatedAt = time.Now()

	// Days are derived from the date range; clients add activities through the item endpoint.
	trip.Days = make([]model.TripDay, 0)
	for date := start; !date.After(end); date = date.AddDate(0, 0, 1) {
		trip.Days = append(trip.Days, model.TripDay{DayNumber: len(trip.Days) + 1, DateStr: date.Format("2006-01-02"), CityID: trip.CityID, CityName: trip.CityName, Items: []model.ItineraryItem{}})
	}

	if err := s.commitTrip(trip); err != nil {
		return nil, err
	}
	result := s.enrichTrip(trip)
	return &result, nil
}

func (s *ServiceContainer) AddItineraryItem(tripID string, dayNumber int, item model.ItineraryItem) (*model.Trip, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	trip, ok := s.Store.Trips[tripID]
	if !ok {
		return nil, fmt.Errorf("%w: trip %s", ErrNotFound, tripID)
	}
	if dayNumber < 1 || dayNumber > len(trip.Days) || strings.TrimSpace(item.Title) == "" {
		return nil, fmt.Errorf("%w: valid day and item title are required", ErrInvalidInput)
	}
	if err := validateItem(item); err != nil {
		return nil, err
	}
	item.RouteFromPrevious = nil
	trip = cloneTrip(trip)

	item.ID = "item_" + rand.Text()
	dayFound := false
	for i := range trip.Days {
		if trip.Days[i].DayNumber == dayNumber {
			item.Order = len(trip.Days[i].Items) + 1
			trip.Days[i].Items = append(trip.Days[i].Items, item)
			dayFound = true
			break
		}
	}

	if !dayFound {
		return nil, fmt.Errorf("%w: day not found", ErrInvalidInput)
	}

	trip.UpdatedAt = time.Now()
	if err := s.commitTrip(trip); err != nil {
		return nil, err
	}
	result := s.enrichTrip(trip)
	return &result, nil
}

// Offline Packages
func (s *ServiceContainer) GetOfflinePackages() []model.OfflinePackage {
	return s.Store.OfflinePackages
}
