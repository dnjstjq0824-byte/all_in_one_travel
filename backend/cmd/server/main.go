package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/api"
	"github.com/bookingnetwork/global-travel-app/backend/internal/data"
	"github.com/bookingnetwork/global-travel-app/backend/internal/service"
)

func main() {
	defaultPort := 8080
	if envPort := os.Getenv("PORT"); envPort != "" {
		if p, err := strconv.Atoi(envPort); err == nil && p > 0 {
			defaultPort = p
		}
	}
	port := flag.Int("port", defaultPort, "HTTP server port")
	stateFile := flag.String("data-file", "var/travel-state.json", "Persistent state file (one server process per file)")
	flag.Parse()

	log.Println("==================================================================")
	log.Println("🌍 BOOKING NETWORK — GLOBAL ALL-IN-ONE TRAVEL ESSENTIAL BACKEND API")
	log.Println("   Directive: BN-GLOBAL-TRAVEL-APP-001 | Order P0")
	log.Println("==================================================================")

	// Initialize verified seed data
	store := data.NewSeedStore()
	log.Printf("[DATA] Loaded %d verified countries and %d global cities", len(store.Countries), len(store.Cities))
	for _, c := range store.Cities {
		lines := len(store.MetroLines[c.ID])
		stations := len(store.MetroStations[c.ID])
		places := len(store.Places[c.ID])
		log.Printf("  • City: %-14s [%s] - %d Metro Lines, %d Stations, %d Attractions", c.Name, c.CoverageLevel, lines, stations, places)
	}

	// Initialize business services
	services, err := service.NewPersistentServiceContainer(store, *stateFile)
	if err != nil {
		log.Fatalf("[DATA] Cannot open persistent storage: %v", err)
	}

	// Set up router and API handlers
	mux := http.NewServeMux()
	handler := api.NewAPIHandler(services)
	handler.RegisterRoutes(mux)

	wrappedMux := api.MiddlewareChain(mux)

	addr := fmt.Sprintf(":%d", *port)
	srv := &http.Server{
		Addr:         addr,
		Handler:      wrappedMux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Graceful shutdown handling
	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, os.Interrupt, syscall.SIGTERM)

	go func() {
		log.Printf("[HTTP] Server listening on http://localhost%s", addr)
		log.Printf("[HTTP] Health endpoint ready at http://localhost%s/api/v1/health", addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("[FATAL] HTTP server error: %v", err)
		}
	}()

	<-stopChan
	log.Println("[SHUTDOWN] Signal received, shutting down gracefully...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("[SHUTDOWN] Server forced shutdown: %v", err)
	}

	log.Println("[SHUTDOWN] Server exiting cleanly.")
}
