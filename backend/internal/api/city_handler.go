package api

import (
	"net/http"
)

func (h *APIHandler) handleGetCountries(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.GetCountries())
}

func (h *APIHandler) handleGetCities(w http.ResponseWriter, r *http.Request) {
	country := r.URL.Query().Get("country")
	respondJSON(w, http.StatusOK, h.svc.GetCities(country))
}

func (h *APIHandler) handleGetCity(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	city, err := h.svc.GetCity(id)
	if err != nil {
		respondError(w, http.StatusNotFound, "city_not_found", err.Error())
		return
	}
	respondJSON(w, http.StatusOK, city)
}

func (h *APIHandler) handleGetCityCoverage(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	coverage, err := h.svc.GetCoverage(id)
	if err != nil {
		respondError(w, http.StatusNotFound, "coverage_not_found", err.Error())
		return
	}
	respondJSON(w, http.StatusOK, coverage)
}

func (h *APIHandler) handleListCoverage(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.ListCoverage())
}

