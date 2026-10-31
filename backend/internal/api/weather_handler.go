package api

import (
	"net/http"
)

func (h *APIHandler) handleGetWeather(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}

	weather, err := h.svc.GetWeather(cityID)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, weather)
}

