package api

import (
	"fmt"
	"net/http"
)

func (h *APIHandler) handleGetOfflinePackages(w http.ResponseWriter, r *http.Request) {
	respondJSON(w, http.StatusOK, h.svc.ListOfflinePackages())
}

func (h *APIHandler) handleDownloadOfflinePackage(w http.ResponseWriter, r *http.Request) {
	cityID := r.PathValue("city")
	raw, checksum, err := h.svc.OfflineCityData(cityID)
	if err != nil {
		respondServiceError(w, err)
		return
	}
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("X-Content-SHA256", checksum)
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s_offline.json\"", cityID))
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(raw)
}
