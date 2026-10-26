package api

import (
	"compress/gzip"
	"io"
	"log"
	"net/http"
	"strings"
	"time"
)

type gzipResponseWriter struct {
	io.Writer
	http.ResponseWriter
}

func (w gzipResponseWriter) Write(b []byte) (int, error) {
	return w.Writer.Write(b)
}

func MiddlewareChain(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")

		// Security headers
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "SAMEORIGIN")
		w.Header().Set("X-XSS-Protection", "1; mode=block")
		w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")

		// Cache policy for static vs dynamic
		if r.URL.Path == "/" || r.URL.Path == "/index.html" || r.URL.Path == "/web/" || r.URL.Path == "/web/index.html" {
			w.Header().Set("Cache-Control", "no-cache, no-store, must-revalidate")
		} else if strings.Contains(r.URL.Path, ".") {
			w.Header().Set("Cache-Control", "public, max-age=86400")
		}

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

		// Transparent GZIP Compression for text, js, wasm, json, html (excluding apk/aab downloads)
		shouldGzip := strings.Contains(r.Header.Get("Accept-Encoding"), "gzip") &&
			!strings.HasPrefix(r.URL.Path, "/download/android") &&
			!strings.HasPrefix(r.URL.Path, "/apk/") &&
			!strings.HasSuffix(r.URL.Path, ".apk") &&
			!strings.HasSuffix(r.URL.Path, ".aab")

		if shouldGzip {
			w.Header().Set("Content-Encoding", "gzip")
			gz := gzip.NewWriter(w)
			defer gz.Close()
			gzw := gzipResponseWriter{Writer: gz, ResponseWriter: w}
			next.ServeHTTP(gzw, r)
		} else {
			next.ServeHTTP(w, r)
		}

		log.Printf("[%s] %s %s - %v", r.Method, r.URL.Path, r.RemoteAddr, time.Since(start))
	})
}

