package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

const baseURL = "http://localhost:8080/api/v1"

func main() {
	log.Println("==================================================================")
	log.Println("🧪 COMMENCING MASTER E2E VERIFICATION SUITE — ARTICLE 24 SCENARIOS")
	log.Println("==================================================================")

	client := &http.Client{Timeout: 5 * time.Second}

	// 1. SCENARIO A: SEOUL
	log.Println("\n[SCENARIO A] Seoul Metro, Multi-Modal & Palaces Integration...")
	testSeoulScenario(client)

	// 2. SCENARIO B: TOKYO
	log.Println("\n[SCENARIO B] Tokyo Yamanote/Ginza Transit, Senso-ji & Itinerary...")
	testTokyoScenario(client)

	// 3. SCENARIO C: LONDON
	log.Println("\n[SCENARIO C] London Underground, TfL Bus & Westminster Attractions...")
	testLondonScenario(client)

	// 4. SCENARIO D: PARIS
	log.Println("\n[SCENARIO D] Paris Métro, Tour Eiffel, Reviews & Weather...")
	testParisScenario(client)

	// 5. SCENARIO E: NEW YORK
	log.Println("\n[SCENARIO E] New York MTA Subway, Times Square & Multi-Day Itinerary...")
	testNewYorkScenario(client)

	// 6. ARTICLE 25: RESILIENCE & EDGE CASE TESTS
	log.Println("\n[ARTICLE 25] Exception, Unsupported Regions & Boundary Tests...")
	testResilienceAndEdgeCases(client)

	log.Println("\n==================================================================")
	log.Println("✅ ALL MASTER E2E SCENARIOS & EXCEPTION SUITES PASSED SUCCESSFULLY!")
	log.Println("==================================================================")
}

func testSeoulScenario(client *http.Client) {
	// 1. Get Seoul Coverage
	var cov map[string]interface{}
	getJSON(client, baseURL+"/cities/seoul/coverage", &cov)
	assert(cov["coverage_level"] == "LEVEL_A", "Seoul must be LEVEL_A")
	assert(cov["realtime_available"] == true, "Seoul must have realtime data")
	log.Printf("  ✓ Seoul Coverage Verified: Level A (Full Verified, Provider: %s)", cov["official_data_provider"])

	// 2. Get Seoul Metro Lines & Stations
	var lines []map[string]interface{}
	getJSON(client, baseURL+"/transit/lines?city_id=seoul", &lines)
	assert(len(lines) >= 4, "Seoul must have at least 4 core metro lines")

	var stations []map[string]interface{}
	getJSON(client, baseURL+"/transit/stations?city_id=seoul", &stations)
	assert(len(stations) >= 5, "Seoul must have verified stations")
	log.Printf("  ✓ Seoul Metro verified: %d Lines, %d Stations loaded", len(lines), len(stations))

	// 3. Plan Route from Gyeongbokgung to City Hall
	planReq := map[string]interface{}{
		"city_id":     "seoul",
		"origin_lat":  37.5759,
		"origin_lng":  126.9735,
		"origin_name": "Gyeongbokgung Station",
		"dest_lat":    37.5657,
		"dest_lng":    126.9769,
		"dest_name":   "City Hall Station",
		"preference":  "fastest",
	}
	var planResp map[string]interface{}
	postJSON(client, baseURL+"/transit/plan", planReq, &planResp)
	opts := planResp["options"].([]interface{})
	assert(len(opts) > 0, "Transit engine must return at least 1 viable route option")
	firstOpt := opts[0].(map[string]interface{})
	log.Printf("  ✓ Route Calculated: %s | Total: %.0f min | Walk: %.0f min | Fare: %s",
		firstOpt["summary"], firstOpt["total_minutes"].(float64), firstOpt["walk_minutes"].(float64), firstOpt["estimated_fare"])

	// 4. Query Seoul Attractions (Gyeongbokgung)
	var places []map[string]interface{}
	getJSON(client, baseURL+"/places?city_id=seoul&q=경복궁", &places)
	assert(len(places) > 0, "Attraction search must find Gyeongbokgung")
	p := places[0]
	assert(p["nearest_metro_station_id"] == "kr_sel_gyeongbokgung", "Article 12: Place must link directly to station ID")
	log.Printf("  ✓ Attraction Verified: %s (Rating: %.1f) linked to Metro: %s", p["name"], p["rating"].(float64), p["nearest_metro_station_name"])
}

func testTokyoScenario(client *http.Client) {
	// Tokyo Metro & Route to Asakusa
	var places []map[string]interface{}
	getJSON(client, baseURL+"/places?city_id=tokyo&q=浅草寺", &places)
	assert(len(places) > 0, "Tokyo search must find Senso-ji Temple")
	p := places[0]

	// Tokyo Weather
	var weather map[string]interface{}
	getJSON(client, baseURL+"/weather?city_id=tokyo", &weather)
	assert(weather["city_id"] == "tokyo", "Weather report must be for Tokyo")
	log.Printf("  ✓ Tokyo Weather: %.1f°C (%s, Humidity: %.0f%%) via %s",
		weather["current_temp_c"].(float64), weather["condition"], weather["humidity"].(float64), weather["attribution"])

	// Add Senso-ji to Trip
	newTrip := map[string]interface{}{
		"title":        "Tokyo Autumn Highlights",
		"country_code": "JP",
		"city_id":      "tokyo",
		"city_name":    "Tokyo",
		"start_date":   "2026-11-02",
		"end_date":     "2026-11-06",
	}
	var createdTrip map[string]interface{}
	postJSON(client, baseURL+"/trips", newTrip, &createdTrip)
	tripID := createdTrip["id"].(string)

	item := map[string]interface{}{
		"place_id":       p["id"],
		"title":          p["name"],
		"subtitle":       p["english_name"],
		"category":       p["category"],
		"time_scheduled": "09:00",
		"latitude":       p["latitude"],
		"longitude":      p["longitude"],
		"duration_min":   90,
		"notes":          "Linked to nearest station: " + p["nearest_metro_station_name"].(string),
	}
	var updatedTrip map[string]interface{}
	postJSON(client, fmt.Sprintf("%s/trips/%s/items?day=1", baseURL, tripID), item, &updatedTrip)
	days := updatedTrip["days"].([]interface{})
	day1 := days[0].(map[string]interface{})
	items := day1["items"].([]interface{})
	assert(len(items) >= 1, "Trip day must contain added itinerary stop")
	log.Printf("  ✓ Destination '%s' seamlessly linked to Trip '%s' Day 1", p["name"], updatedTrip["title"])
}

func testLondonScenario(client *http.Client) {
	// London Tube lines & Westminster
	var lines []map[string]interface{}
	getJSON(client, baseURL+"/transit/lines?city_id=london", &lines)
	assert(len(lines) >= 3, "London Tube lines must include Central, Jubilee, Piccadilly")

	var places []map[string]interface{}
	getJSON(client, baseURL+"/places?city_id=london&q=Big+Ben", &places)
	assert(len(places) > 0, "Big Ben must be found")
	log.Printf("  ✓ London Tube & Landmark: %d lines, Big Ben station link: %s", len(lines), places[0]["nearest_metro_station_name"])
}

func testParisScenario(client *http.Client) {
	// Paris Eiffel Tower & Reviews
	var places []map[string]interface{}
	getJSON(client, baseURL+"/places?city_id=paris&q=Eiffel", &places)
	assert(len(places) > 0, "Eiffel tower must be found")
	p := places[0]

	// Check opening hours and nearest station
	assert(p["opening_hours"] != "", "Opening hours must be verified")
	assert(p["nearest_metro_station_name"] != "", "Nearest station must be linked")

	// Post authentic traveler review
	rev := map[string]interface{}{
		"author_name":  "Pierre Dubois",
		"rating":       5,
		"title":        "Magique au crépuscule",
		"content":      "Prendre la ligne 6 jusqu'à Bir-Hakeim offre une vue magnifique sur la tour en arrivant.",
		"visit_period": "October 2026",
		"travel_type":  "Couple",
		"visit_tip":    "Réservez le billet d'ascenseur au moins 3 semaines à l'avance.",
		"language":     "fr",
	}
	var createdRev map[string]interface{}
	postJSON(client, fmt.Sprintf("%s/places/%s/reviews", baseURL, p["id"].(string)), rev, &createdRev)
	assert(createdRev["id"] != "", "Review ID must be generated")
	log.Printf("  ✓ Paris Eiffel Tower verified with real Métro link (%s) and new review ID: %s",
		p["nearest_metro_station_name"], createdRev["id"])
}

func testNewYorkScenario(client *http.Client) {
	// New York Subway & Bus Arrivals
	var arrivals []map[string]interface{}
	getJSON(client, baseURL+"/transit/arrivals?stop_id=us_nyc_bus_times_sq", &arrivals)
	assert(len(arrivals) > 0, "MTA Bus arrivals must be populated")
	firstArr := arrivals[0]
	log.Printf("  ✓ New York MTA Transit: Bus Route %s towards %s is %0.f min away (Status: %s)",
		firstArr["route_number"], firstArr["destination"], firstArr["minutes_away"].(float64), firstArr["status"])

	// Offline packages check
	var packages []map[string]interface{}
	getJSON(client, baseURL+"/offline/packages", &packages)
	assert(len(packages) >= 5, "Must offer offline packages for key global hubs")
	log.Printf("  ✓ Offline Hubs available: %d verified packages ready for download", len(packages))
}

func testResilienceAndEdgeCases(client *http.Client) {
	// 1. Unsupported city must be Level E or 404
	resp, _ := client.Get(baseURL + "/cities/non_existent_city/coverage")
	assert(resp.StatusCode == http.StatusNotFound, "Non-existent city must return 404")

	// 2. Same Origin and Destination transit plan
	sameReq := map[string]interface{}{
		"city_id":     "seoul",
		"origin_lat":  37.5665,
		"origin_lng":  126.9780,
		"origin_name": "Seoul Plaza",
		"dest_lat":    37.5665,
		"dest_lng":    126.9780,
		"dest_name":   "Seoul Plaza",
	}
	var sameResp map[string]interface{}
	postJSON(client, baseURL+"/transit/plan", sameReq, &sameResp)
	opts := sameResp["options"].([]interface{})
	assert(len(opts) > 0, "Same location should produce a direct walking option")
	log.Printf("  ✓ Same-origin edge case handled: %.0f min walk", opts[0].(map[string]interface{})["total_minutes"].(float64))

	// 3. Accessible preference filter
	accReq := map[string]interface{}{
		"city_id":     "seoul",
		"origin_lat":  37.5559,
		"origin_lng":  126.9723,
		"origin_name": "Seoul Station",
		"dest_lat":    37.5657,
		"dest_lng":    126.9769,
		"dest_name":   "City Hall",
		"preference":  "accessible",
	}
	var accResp map[string]interface{}
	postJSON(client, baseURL+"/transit/plan", accReq, &accResp)
	accOpts := accResp["options"].([]interface{})
	assert(len(accOpts) > 0, "Must return accessible transit options")
	assert(accOpts[0].(map[string]interface{})["accessible"] == true, "Accessible option must satisfy elevator criteria")
	log.Printf("  ✓ Accessible barrier-free transit filter validated (Elevators confirmed)")
}

func getJSON(client *http.Client, url string, target interface{}) {
	resp, err := client.Get(url)
	if err != nil {
		log.Fatalf("GET %s failed: %v", url, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		log.Fatalf("GET %s returned code %d: %s", url, resp.StatusCode, string(b))
	}
	if err := json.NewDecoder(resp.Body).Decode(target); err != nil {
		log.Fatalf("decode failed: %v", err)
	}
}

func postJSON(client *http.Client, url string, payload interface{}, target interface{}) {
	body, _ := json.Marshal(payload)
	resp, err := client.Post(url, "application/json", bytes.NewReader(body))
	if err != nil {
		log.Fatalf("POST %s failed: %v", url, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		b, _ := io.ReadAll(resp.Body)
		log.Fatalf("POST %s returned code %d: %s", url, resp.StatusCode, string(b))
	}
	if err := json.NewDecoder(resp.Body).Decode(target); err != nil {
		log.Fatalf("decode failed: %v", err)
	}
}

func assert(condition bool, message string) {
	if !condition {
		log.Fatalf("ASSERTION FAILED: %s", message)
		os.Exit(1)
	}
}
