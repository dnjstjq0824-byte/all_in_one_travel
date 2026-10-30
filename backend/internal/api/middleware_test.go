package api

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRequestBodyLimit(t *testing.T) {
	called := false
	handler := MiddlewareChain(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { called = true }))
	req := httptest.NewRequest("POST", "/api/v1/trips", strings.NewReader(strings.Repeat("x", (1<<20)+1)))
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, req)
	if w.Code != http.StatusRequestEntityTooLarge || called {
		t.Fatalf("oversized request passed through: %d", w.Code)
	}
}
