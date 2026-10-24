package api

import (
	"log"
	"net/http"
	"time"
)

func MiddlewareChain(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")

		// Security headers
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("X-XSS-Protection", "1; mode=block")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		defer func() {
			if rec := recover(); rec != nil {
				log.Printf("[PANIC RECOVERED] %v", rec)
				respondError(w, http.StatusInternalServerError, "Internal Server Error")
			}
		}()

		next.ServeHTTP(w, r)

		log.Printf("[%s] %s %s - %v", r.Method, r.URL.Path, r.RemoteAddr, time.Since(start))
	})
}
