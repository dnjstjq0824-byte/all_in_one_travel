package api

import (
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

func (h *APIHandler) handleAndroidDownload(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Disposition", "attachment; filename=\"app-release.apk\"")
	w.Header().Set("Content-Type", "application/vnd.android.package-archive")
	http.ServeFile(w, r, "release/apk/app-release.apk")
}

func (h *APIHandler) handleDownloadPage(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "release/portal/download.html")
}

func (h *APIHandler) handlePrivacy(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "release/portal/privacy.html")
}

func (h *APIHandler) handleTerms(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "release/portal/terms.html")
}

func (h *APIHandler) handleSupport(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "release/portal/support.html")
}

func (h *APIHandler) handleRootAndStatic(w http.ResponseWriter, r *http.Request) {
	// G-4 / L-04: Never serve portal HTML for unmatched /api/ requests!
	if strings.HasPrefix(r.URL.Path, "/api/") {
		respondError(w, http.StatusNotFound, "endpoint_not_found", "API endpoint not found: "+r.URL.Path)
		return
	}

	if r.URL.Path == "/" || r.URL.Path == "/index.html" {
		http.ServeFile(w, r, "release/portal/index.html")
		return
	}
	if strings.HasPrefix(r.URL.Path, "/apk/") {
		http.StripPrefix("/apk/", http.FileServer(http.Dir("release/apk"))).ServeHTTP(w, r)
		return
	}
	if strings.HasPrefix(r.URL.Path, "/web/") || r.URL.Path == "/web" {
		subPath := strings.TrimPrefix(r.URL.Path, "/web")
		if subPath == "" || subPath == "/" {
			http.ServeFile(w, r, "release/web/index.html")
			return
		}
		targetFile := filepath.Join("release/web", filepath.Clean(subPath))
		if fi, err := os.Stat(targetFile); err == nil && !fi.IsDir() {
			http.ServeFile(w, r, targetFile)
			return
		}
		// SPA fallback
		http.ServeFile(w, r, "release/web/index.html")
		return
	}

	// Default portal fallback for legal/static page URLs
	http.ServeFile(w, r, "release/portal/index.html")
}

