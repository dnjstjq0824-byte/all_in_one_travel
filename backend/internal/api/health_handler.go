package api

import (
	"net/http"
)

func (h *APIHandler) handleHealth(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, map[string]interface{}{
		"status":  "healthy",
		"service": "Global Travel Essential API",
		"version": "1.0.0",
		"cities":  len(h.svc.Store.Cities),
	})
}

