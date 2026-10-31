package service

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

var ErrWeatherProviderUnavailable = errors.New("weather provider unavailable")

func (s *ServiceContainer) GetWeather(cityID string) (*model.WeatherReport, error) {
	city, err := s.GetCity(cityID)
	if err != nil {
		return nil, err
	}

	todayStr := time.Now().Format("2006-01-02")

	s.mu.RLock()
	cached, exists := s.Store.WeatherReports[cityID]
	s.mu.RUnlock()

	// Only return cache if it was observed within 30m AND the daily forecast matches today
	if exists && time.Since(cached.ObservedAt) < 30*time.Minute && len(cached.Daily) > 0 && cached.Daily[0].Date == todayStr {
		return &cached, nil
	}

	// Fetch live forecast from Open-Meteo
	liveReport, err := s.fetchOpenMeteoWeather(city.Latitude, city.Longitude, city.ID, city.Name)
	if err == nil && liveReport != nil {
		s.mu.Lock()
		s.Store.WeatherReports[cityID] = *liveReport
		s.mu.Unlock()
		return liveReport, nil
	}

	// If fetch failed but we have fresh cache today, return it
	if exists && len(cached.Daily) > 0 && cached.Daily[0].Date == todayStr {
		return &cached, nil
	}

	// G-2 / G-4 Fail-Closed: Never mask provider failure with past date data
	return nil, fmt.Errorf("%w: live weather service unavailable for %s", ErrWeatherProviderUnavailable, cityID)
}

func (s *ServiceContainer) fetchOpenMeteoWeather(lat, lng float64, cityID, cityName string) (*model.WeatherReport, error) {
	client := s.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: 5 * time.Second}
	}
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
	hLimit := min(len(raw.Hourly.Time), len(raw.Hourly.Temperature2m), len(raw.Hourly.PrecipProb), 12)
	for i := 0; i < hLimit; i++ {
		timePart := raw.Hourly.Time[i]
		if len(timePart) >= 16 {
			timePart = timePart[11:16]
		}
		hCond := condition
		if i < len(raw.Hourly.WeatherCode) {
			hCond, _ = weatherCodeToString(raw.Hourly.WeatherCode[i])
		}
		hourly = append(hourly, model.HourlyForecast{
			Hour:       timePart,
			TempC:      raw.Hourly.Temperature2m[i],
			Condition:  hCond,
			PrecipProb: raw.Hourly.PrecipProb[i],
			Icon:       "partly_cloudy",
		})
	}

	daily := make([]model.DailyForecast, 0)
	dLimit := min(len(raw.Daily.Time), len(raw.Daily.WeatherCode), len(raw.Daily.Temperature2mMax), len(raw.Daily.Temperature2mMin), len(raw.Daily.PrecipProbMax), 5)
	for i := 0; i < dLimit; i++ {
		cName, _ := weatherCodeToString(raw.Daily.WeatherCode[i])
		t, _ := time.Parse("2006-01-02", raw.Daily.Time[i])
		daily = append(daily, model.DailyForecast{
			Date:       raw.Daily.Time[i],
			DayOfWeek:  t.Format("Mon"),
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
		AirQualityIndex: "Moderate",
		Hourly:          hourly,
		Daily:           daily,
		Attribution:     "Weather data by Open-Meteo.com",
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
