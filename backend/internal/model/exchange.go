package model

import "time"

type ExchangeRateReport struct {
	Base       string             `json:"base"`
	Rates      map[string]float64 `json:"rates"`
	UpdatedAt  time.Time          `json:"updated_at"`
	Provider   string             `json:"provider"`
	Disclaimer string             `json:"disclaimer"`
}

