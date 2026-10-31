package api

import (
	"net/http"
)

func (h *APIHandler) handleGetEmergency(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		respondError(w, http.StatusBadRequest, "missing_parameter", "city_id parameter is required")
		return
	}

	info, err := h.svc.GetEmergencyInfo(cityID)
	if err != nil {
		respondError(w, http.StatusNotFound, "city_not_found", "Emergency info not found for city: "+cityID)
		return
	}
	respondJSON(w, http.StatusOK, info)
}

