package api

import (
	"net/http"
)

func (h *APIHandler) handleSearchPlaces(w http.ResponseWriter, r *http.Request) {
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		cityID = "seoul"
	}
	query := r.URL.Query().Get("q")
	category := r.URL.Query().Get("category")

	places := h.svc.SearchPlaces(cityID, query, category)
	respondJSON(w, http.StatusOK, places)
}

func (h *APIHandler) handleGetPlace(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	cityID := r.URL.Query().Get("city_id")
	if cityID == "" {
		for cID, places := range h.svc.Store.Places {
			for _, p := range places {
				if p.ID == id {
					cityID = cID
					break
				}
			}
			if cityID != "" {
				break
			}
		}
	}

	place, err := h.svc.GetPlace(cityID, id)
	if err != nil {
		respondError(w, http.StatusNotFound, "place_not_found", "Place not found: "+id)
		return
	}
	respondJSON(w, http.StatusOK, place)
}

