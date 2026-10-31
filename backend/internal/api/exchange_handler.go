package api

import (
	"net/http"
)

func (h *APIHandler) handleGetExchangeRates(w http.ResponseWriter, r *http.Request) {
	base := r.URL.Query().Get("base")
	if base == "" {
		base = "USD"
	}

	rates, err := h.svc.GetExchangeRates(base)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	respondJSON(w, http.StatusOK, rates)
}

