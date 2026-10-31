package api

import (
	"net/http"

	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

type APIHandler struct {
	svc *service.ServiceContainer
}

func NewAPIHandler(svc *service.ServiceContainer) *APIHandler {
	return &APIHandler{svc: svc}
}

func (h *APIHandler) RegisterRoutes(mux *http.ServeMux) {
	// Health check
	mux.HandleFunc("GET /api/v1/health", h.handleHealth)

	// Countries & Cities
	mux.HandleFunc("GET /api/v1/countries", h.handleGetCountries)
	mux.HandleFunc("GET /api/v1/cities", h.handleGetCities)
	mux.HandleFunc("GET /api/v1/cities/{id}", h.handleGetCity)
	mux.HandleFunc("GET /api/v1/cities/{id}/coverage", h.handleGetCityCoverage)
	mux.HandleFunc("GET /api/v1/coverage", h.handleListCoverage)

	// Transit (Metro & Bus)
	mux.HandleFunc("GET /api/v1/transit/lines", h.handleGetTransitLines)
	mux.HandleFunc("GET /api/v1/transit/stations", h.handleGetTransitStations)
	mux.HandleFunc("GET /api/v1/transit/stations/{id}", h.handleGetTransitStation)
	mux.HandleFunc("GET /api/v1/transit/bus/routes", h.handleGetBusRoutes)
	mux.HandleFunc("GET /api/v1/transit/bus/stops", h.handleGetBusStops)
	mux.HandleFunc("GET /api/v1/transit/arrivals", h.handleGetRealtimeArrivals)
	mux.HandleFunc("POST /api/v1/transit/plan", h.handlePlanTransit)

	// Places & Reviews (L-03 solved: supports both nested and query routes)
	mux.HandleFunc("GET /api/v1/places", h.handleSearchPlaces)
	mux.HandleFunc("GET /api/v1/places/{id}", h.handleGetPlace)
	mux.HandleFunc("GET /api/v1/places/{id}/reviews", h.handleGetReviews)
	mux.HandleFunc("POST /api/v1/places/{id}/reviews", h.handleAddReview)
	mux.HandleFunc("GET /api/v1/reviews", h.handleGetReviews)
	mux.HandleFunc("POST /api/v1/reviews", h.handleAddReview)

	// Weather (L-05 solved)
	mux.HandleFunc("GET /api/v1/weather", h.handleGetWeather)

	// Exchange Rates (L-01 solved)
	mux.HandleFunc("GET /api/v1/exchange-rates", h.handleGetExchangeRates)

	// Emergency Contacts (L-02 solved)
	mux.HandleFunc("GET /api/v1/emergency", h.handleGetEmergency)

	// Trips & Itinerary
	mux.HandleFunc("GET /api/v1/trips", h.handleListTrips)
	mux.HandleFunc("POST /api/v1/trips", h.handleCreateTrip)
	mux.HandleFunc("GET /api/v1/trips/{id}", h.handleGetTrip)
	mux.HandleFunc("PATCH /api/v1/trips/{id}", h.handleUpdateTrip)
	mux.HandleFunc("DELETE /api/v1/trips/{id}", h.handleDeleteTrip)
	mux.HandleFunc("POST /api/v1/trips/{id}/items", h.handleAddItineraryItem)
	mux.HandleFunc("PATCH /api/v1/trips/{id}/items/{itemID}", h.handleCompleteItineraryItem)
	mux.HandleFunc("DELETE /api/v1/trips/{id}/items/{itemID}", h.handleDeleteItineraryItem)
	mux.HandleFunc("PUT /api/v1/trips/{id}/days/{day}/order", h.handleReorderItineraryItems)

	// Offline Packages
	mux.HandleFunc("GET /api/v1/offline/packages", h.handleGetOfflinePackages)
	mux.HandleFunc("GET /api/v1/offline/packages/{city}", h.handleDownloadOfflinePackage)

	// Article 2 Mandatory Portal & Download URLs
	mux.HandleFunc("GET /download/android", h.handleAndroidDownload)
	mux.HandleFunc("GET /download", h.handleDownloadPage)
	mux.HandleFunc("GET /download/", h.handleDownloadPage)
	mux.HandleFunc("GET /privacy", h.handlePrivacy)
	mux.HandleFunc("GET /terms", h.handleTerms)
	mux.HandleFunc("GET /support", h.handleSupport)

	// Static Web Portal & SPA Fallback (L-04: /api/ prefix excluded)
	mux.HandleFunc("GET /", h.handleRootAndStatic)
}

