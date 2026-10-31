package service

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

var (
	ErrExchangeProviderNotConfigured = errors.New("exchange_provider_not_configured")
	ErrExchangeProviderFailed        = errors.New("exchange_provider_failed")
)

type exchangeCacheEntry struct {
	report    model.ExchangeRateReport
	fetchedAt time.Time
}

var (
	exchangeCache      = make(map[string]exchangeCacheEntry)
	exchangeCacheMutex = &syncMutex{}
)

type syncMutex struct{}

func (s *ServiceContainer) GetExchangeRates(base string) (*model.ExchangeRateReport, error) {
	if base == "" {
		base = "USD"
	}
	base = strings.ToUpper(base)

	s.mu.RLock()
	cached, exists := exchangeCache[base]
	s.mu.RUnlock()

	if exists && time.Since(cached.fetchedAt) < 1*time.Hour {
		return &cached.report, nil
	}

	apiURL := os.Getenv("EXCHANGE_API_URL")
	if apiURL == "" {
		// G-2 Fail-Closed: Never return fake or dummy exchange rates
		return nil, ErrExchangeProviderNotConfigured
	}

	targetURL := fmt.Sprintf(apiURL, base)
	if !strings.Contains(apiURL, "%s") {
		targetURL = apiURL
	}

	client := s.HTTPClient
	if client == nil {
		client = &http.Client{Timeout: 5 * time.Second}
	}

	req, err := http.NewRequest(http.MethodGet, targetURL, nil)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrExchangeProviderFailed, err)
	}
	if apiKey := os.Getenv("EXCHANGE_API_KEY"); apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+apiKey)
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%w: %v", ErrExchangeProviderFailed, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w: HTTP status %d", ErrExchangeProviderFailed, resp.StatusCode)
	}

	var raw struct {
		Result string             `json:"result"`
		Base   string             `json:"base_code"`
		Rates  map[string]float64 `json:"rates"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("%w: parse response: %v", ErrExchangeProviderFailed, err)
	}

	report := model.ExchangeRateReport{
		Base:       base,
		Rates:      raw.Rates,
		UpdatedAt:  time.Now(),
		Provider:   "Open Exchange Rates API",
		Disclaimer: "Exchange rates are for informational purposes only.",
	}

	s.mu.Lock()
	exchangeCache[base] = exchangeCacheEntry{report: report, fetchedAt: time.Now()}
	s.mu.Unlock()

	return &report, nil
}

