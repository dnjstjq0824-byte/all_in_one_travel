package test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

func TestItineraryCompletionAPI(t *testing.T) {
	mux := setupTestServer()
	request := func(method, path, body string, status int) *httptest.ResponseRecorder {
		t.Helper()
		w := httptest.NewRecorder()
		mux.ServeHTTP(w, httptest.NewRequest(method, path, bytes.NewBufferString(body)))
		if w.Code != status {
			t.Fatalf("%s %s: status %d, want %d: %s", method, path, w.Code, status, w.Body.String())
		}
		return w
	}
	created := request("POST", "/api/v1/trips", `{"title":"Test trip","city_id":"seoul","start_date":"2026-11-01","end_date":"2026-11-02"}`, http.StatusCreated)
	var trip model.Trip
	if err := json.Unmarshal(created.Body.Bytes(), &trip); err != nil {
		t.Fatal(err)
	}
	if len(trip.Days) != 2 {
		t.Fatal("date range missing")
	}
	added := request("POST", "/api/v1/trips/"+trip.ID+"/items?day=2", `{"title":"Museum","latitude":37.57,"longitude":126.98}`, http.StatusOK)
	if err := json.Unmarshal(added.Body.Bytes(), &trip); err != nil {
		t.Fatal(err)
	}
	path := "/api/v1/trips/" + trip.ID + "/items/" + trip.Days[1].Items[0].ID
	request("PATCH", path, `{}`, http.StatusBadRequest)
	request("PATCH", path, `{"is_completed":true}`, http.StatusOK)
	reloaded := request("GET", "/api/v1/trips/"+trip.ID, "", http.StatusOK)
	if err := json.Unmarshal(reloaded.Body.Bytes(), &trip); err != nil {
		t.Fatal(err)
	}
	if !trip.Days[1].Items[0].IsCompleted {
		t.Fatal("completion missing after reloading")
	}
	request("PATCH", "/api/v1/trips/missing/items/missing", `{"is_completed":true}`, http.StatusNotFound)
	request("POST", "/api/v1/trips/"+trip.ID+"/items?day=3", `{"title":"Outside range"}`, http.StatusBadRequest)
	request("POST", "/api/v1/trips", `{"title":"Invalid","city_id":"seoul","start_date":"2026-11-03","end_date":"2026-11-02"}`, http.StatusBadRequest)
	request("POST", "/api/v1/transit/plan", `{"city_id":"seoul","origin_lat":91}`, http.StatusBadRequest)
	request("POST", "/api/v1/transit/plan", `{"city_id":"missing"}`, http.StatusNotFound)
	added = request("POST", "/api/v1/trips/"+trip.ID+"/items?day=2", `{"title":"Second stop"}`, http.StatusOK)
	if err := json.Unmarshal(added.Body.Bytes(), &trip); err != nil {
		t.Fatal(err)
	}
	firstID, secondID := trip.Days[1].Items[0].ID, trip.Days[1].Items[1].ID
	order, _ := json.Marshal(map[string]any{"item_ids": []string{secondID, firstID}})
	request("PUT", "/api/v1/trips/"+trip.ID+"/days/2/order", string(order), http.StatusOK)
	request("PATCH", "/api/v1/trips/"+trip.ID+"/items/"+secondID, `{"title":"Edited stop","time_scheduled":"12:00"}`, http.StatusOK)
	request("PATCH", "/api/v1/trips/"+trip.ID, `{"title":"Edited trip"}`, http.StatusOK)
	request("DELETE", "/api/v1/trips/"+trip.ID+"/items/"+firstID, "", http.StatusOK)
	request("DELETE", "/api/v1/trips/"+trip.ID, "", http.StatusNoContent)
	request("GET", "/api/v1/trips/"+trip.ID, "", http.StatusNotFound)
}
