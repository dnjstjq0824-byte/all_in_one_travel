package api

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

type APIError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

type ErrorResponse struct {
	Error APIError `json:"error"`
}

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

func respondError(w http.ResponseWriter, status int, code, message string) {
	respondJSON(w, status, ErrorResponse{
		Error: APIError{
			Code:    code,
			Message: message,
		},
	})
}

func respondServiceError(w http.ResponseWriter, err error) {
	if errors.Is(err, service.ErrNotFound) {
		respondError(w, http.StatusNotFound, "resource_not_found", err.Error())
		return
	}
	if errors.Is(err, service.ErrInvalidInput) {
		respondError(w, http.StatusBadRequest, "invalid_input", err.Error())
		return
	}
	if errors.Is(err, service.ErrConflict) {
		respondError(w, http.StatusConflict, "conflict", err.Error())
		return
	}
	if errors.Is(err, service.ErrWeatherProviderUnavailable) {
		respondError(w, http.StatusServiceUnavailable, "weather_provider_unavailable", err.Error())
		return
	}
	if errors.Is(err, service.ErrExchangeProviderNotConfigured) {
		respondError(w, http.StatusServiceUnavailable, "exchange_provider_not_configured", "Exchange rate provider is not configured. Set EXCHANGE_API_URL or EXCHANGE_API_KEY.")
		return
	}
	if errors.Is(err, service.ErrExchangeProviderFailed) {
		respondError(w, http.StatusServiceUnavailable, "exchange_provider_failed", err.Error())
		return
	}
	respondError(w, http.StatusInternalServerError, "internal_error", err.Error())
}

