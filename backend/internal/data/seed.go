package data

import (
	"time"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type SeedStore struct {
	Countries        []model.Country
	Cities           []model.City
	Coverage         map[string]model.CoverageRegistry
	MetroLines       map[string][]model.MetroLine       // cityID -> lines
	MetroStations    map[string][]model.MetroStation    // cityID -> stations
	BusRoutes        map[string][]model.BusRoute        // cityID -> routes
	BusStops         map[string][]model.BusStop         // cityID -> stops
	RealtimeArrivals map[string][]model.RealtimeArrival // stopID -> arrivals
	Places           map[string][]model.Place           // cityID -> places
	Reviews          map[string][]model.Review          // placeID -> reviews
	WeatherReports   map[string]model.WeatherReport     // cityID -> weather
	Trips            map[string]model.Trip              // tripID -> trip
	OfflinePackages  []model.OfflinePackage
}

func NewSeedStore() *SeedStore {
	store := &SeedStore{
		Coverage:         make(map[string]model.CoverageRegistry),
		MetroLines:       make(map[string][]model.MetroLine),
		MetroStations:    make(map[string][]model.MetroStation),
		BusRoutes:        make(map[string][]model.BusRoute),
		BusStops:         make(map[string][]model.BusStop),
		RealtimeArrivals: make(map[string][]model.RealtimeArrival),
		Places:           make(map[string][]model.Place),
		Reviews:          make(map[string][]model.Review),
		WeatherReports:   make(map[string]model.WeatherReport),
		Trips:            make(map[string]model.Trip),
	}

	store.initCountriesAndCities()
	store.initCoverage()
	store.initSeoulTransit()
	store.initTokyoTransit()
	store.initLondonTransit()
	store.initParisTransit()
	store.initNewYorkTransit()
	store.initSingaporeTransit()
	store.initOtherCitiesTransit()
	store.initPlacesAndReviews()
	store.initInitialWeather()
	store.initInitialTrips()
	store.initOfflinePackages()

	return store
}

func (s *SeedStore) initCountriesAndCities() {
	s.Countries = []model.Country{
		{Code: "KR", Name: "South Korea", Continent: "Asia"},
		{Code: "JP", Name: "Japan", Continent: "Asia"},
		{Code: "SG", Name: "Singapore", Continent: "Asia"},
		{Code: "TW", Name: "Taiwan", Continent: "Asia"},
		{Code: "HK", Name: "Hong Kong", Continent: "Asia"},
		{Code: "TH", Name: "Thailand", Continent: "Asia"},
		{Code: "AE", Name: "United Arab Emirates", Continent: "Asia"},
		{Code: "GB", Name: "United Kingdom", Continent: "Europe"},
		{Code: "FR", Name: "France", Continent: "Europe"},
		{Code: "DE", Name: "Germany", Continent: "Europe"},
		{Code: "TR", Name: "Turkey", Continent: "Europe"},
		{Code: "US", Name: "United States", Continent: "North America"},
		{Code: "CA", Name: "Canada", Continent: "North America"},
		{Code: "MX", Name: "Mexico", Continent: "North America"},
		{Code: "AU", Name: "Australia", Continent: "Oceania"},
		{Code: "BR", Name: "Brazil", Continent: "South America"},
	}

	s.Cities = []model.City{
		// Level A (Full Verified)
		{
			ID: "seoul", CountryCode: "KR", Name: "Seoul", EnglishName: "Seoul", LocalName: "서울",
			Latitude: 37.5665, Longitude: 126.9780, Timezone: "Asia/Seoul",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "South Korea's high-tech capital blending ancient palaces and cutting-edge transit.",
			HeroImageURL: "https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "tokyo", CountryCode: "JP", Name: "Tokyo", EnglishName: "Tokyo", LocalName: "東京",
			Latitude: 35.6762, Longitude: 139.6503, Timezone: "Asia/Tokyo",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "The world's most populous metropolitan area, renowned for punctuality and neon lights.",
			HeroImageURL: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "london", CountryCode: "GB", Name: "London", EnglishName: "London", LocalName: "London",
			Latitude: 51.5074, Longitude: -0.1278, Timezone: "Europe/London",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "Historic British capital home to the legendary Underground 'Tube' network.",
			HeroImageURL: "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "paris", CountryCode: "FR", Name: "Paris", EnglishName: "Paris", LocalName: "Paris",
			Latitude: 48.8566, Longitude: 2.3522, Timezone: "Europe/Paris",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "The City of Light, offering an iconic dense Métro grid connecting world landmarks.",
			HeroImageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "newyork", CountryCode: "US", Name: "New York", EnglishName: "New York", LocalName: "New York",
			Latitude: 40.7128, Longitude: -74.0060, Timezone: "America/New_York",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK"},
			Description: "The city that never sleeps, with a 24/7 subway system connecting five boroughs.",
			HeroImageURL: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "singapore", CountryCode: "SG", Name: "Singapore", EnglishName: "Singapore", LocalName: "Singapore",
			Latitude: 1.3521, Longitude: 103.8198, Timezone: "Asia/Singapore",
			CoverageLevel: model.CoverageLevelA, TransportModes: []string{"METRO", "BUS", "WALK"},
			Description: "The futuristic garden city with spotless, automated MRT transit lines.",
			HeroImageURL: "https://images.unsplash.com/photo-1525625293386-3f8f99389edd?auto=format&fit=crop&w=1200&q=80",
		},

		// Level B (Schedule Verified)
		{
			ID: "osaka", CountryCode: "JP", Name: "Osaka", EnglishName: "Osaka", LocalName: "大阪",
			Latitude: 34.6937, Longitude: 135.5023, Timezone: "Asia/Tokyo",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "Japan's food capital, served by the Midosuji Line and Osaka Loop Line.",
			HeroImageURL: "https://images.unsplash.com/photo-1590559899731-a382839e5549?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "hongkong", CountryCode: "HK", Name: "Hong Kong", EnglishName: "Hong Kong", LocalName: "香港",
			Latitude: 22.3193, Longitude: 114.1694, Timezone: "Asia/Hong_Kong",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "FERRY"},
			Description: "World-class vertical metropolis linked by the ultra-efficient MTR railway.",
			HeroImageURL: "https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "taipei", CountryCode: "TW", Name: "Taipei", EnglishName: "Taipei", LocalName: "臺北",
			Latitude: 25.0330, Longitude: 121.5654, Timezone: "Asia/Taipei",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK"},
			Description: "Vibrant capital known for night markets and the pristine Taipei Metro (MRT).",
			HeroImageURL: "https://images.unsplash.com/photo-1508247967583-7d982ea01526?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "bangkok", CountryCode: "TH", Name: "Bangkok", EnglishName: "Bangkok", LocalName: "กรุงเทพฯ",
			Latitude: 13.7563, Longitude: 100.5018, Timezone: "Asia/Bangkok",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "FERRY"},
			Description: "Bustling cultural hub navigated via elevated BTS Skytrain and underground MRT.",
			HeroImageURL: "https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "berlin", CountryCode: "DE", Name: "Berlin", EnglishName: "Berlin", LocalName: "Berlin",
			Latitude: 52.5200, Longitude: 13.4050, Timezone: "Europe/Berlin",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "RAIL"},
			Description: "Creative European capital seamlessly connected via U-Bahn, S-Bahn, and Trams.",
			HeroImageURL: "https://images.unsplash.com/photo-1560969184-10fe8719e047?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "sanfrancisco", CountryCode: "US", Name: "San Francisco", EnglishName: "San Francisco", LocalName: "San Francisco",
			Latitude: 37.7749, Longitude: -122.4194, Timezone: "America/Los_Angeles",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "CABLE_CAR"},
			Description: "Iconic Bay Area city traversed by BART and Muni rail networks.",
			HeroImageURL: "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "toronto", CountryCode: "CA", Name: "Toronto", EnglishName: "Toronto", LocalName: "Toronto",
			Latitude: 43.6532, Longitude: -79.3832, Timezone: "America/Toronto",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "STREETCAR"},
			Description: "Canada's largest city, powered by the TTC subway and extensive streetcar lines.",
			HeroImageURL: "https://images.unsplash.com/photo-1507992781348-310259076fa0?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "sydney", CountryCode: "AU", Name: "Sydney", EnglishName: "Sydney", LocalName: "Sydney",
			Latitude: -33.8688, Longitude: 151.2093, Timezone: "Australia/Sydney",
			CoverageLevel: model.CoverageLevelB, TransportModes: []string{"METRO", "BUS", "WALK", "FERRY"},
			Description: "Harbour city linked by the modern Sydney Metro and scenic commuter ferries.",
			HeroImageURL: "https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?auto=format&fit=crop&w=1200&q=80",
		},

		// Level C (Map Only)
		{
			ID: "dubai", CountryCode: "AE", Name: "Dubai", EnglishName: "Dubai", LocalName: "دبي",
			Latitude: 25.2048, Longitude: 55.2708, Timezone: "Asia/Dubai",
			CoverageLevel: model.CoverageLevelC, TransportModes: []string{"METRO", "WALK"},
			Description: "Futuristic desert hub with driverless Red & Green metro lines.",
			HeroImageURL: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "istanbul", CountryCode: "TR", Name: "Istanbul", EnglishName: "Istanbul", LocalName: "İstanbul",
			Latitude: 41.0082, Longitude: 28.9784, Timezone: "Europe/Istanbul",
			CoverageLevel: model.CoverageLevelC, TransportModes: []string{"METRO", "WALK", "FERRY"},
			Description: "Transcontinental metropolis uniting Europe and Asia across the Bosphorus.",
			HeroImageURL: "https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?auto=format&fit=crop&w=1200&q=80",
		},

		// Level D (Destination Only)
		{
			ID: "saopaulo", CountryCode: "BR", Name: "São Paulo", EnglishName: "São Paulo", LocalName: "São Paulo",
			Latitude: -23.5505, Longitude: -46.6333, Timezone: "America/Sao_Paulo",
			CoverageLevel: model.CoverageLevelD, TransportModes: []string{"WALK"},
			Description: "Vast cultural and culinary center of Latin America.",
			HeroImageURL: "https://images.unsplash.com/photo-1543059080-f9b1272213d5?auto=format&fit=crop&w=1200&q=80",
		},
		{
			ID: "mexicocity", CountryCode: "MX", Name: "Mexico City", EnglishName: "Mexico City", LocalName: "Ciudad de México",
			Latitude: 19.4326, Longitude: -99.1332, Timezone: "America/Mexico_City",
			CoverageLevel: model.CoverageLevelD, TransportModes: []string{"WALK"},
			Description: "Ancient Aztec heartland evolved into a bustling high-altitude capital.",
			HeroImageURL: "https://images.unsplash.com/photo-1518105779142-d975f22f1b0a?auto=format&fit=crop&w=1200&q=80",
		},
	}
}

func (s *SeedStore) initCoverage() {
	now := time.Now()

	s.Coverage["seoul"] = model.CoverageRegistry{
		CityID: "seoul", CityName: "Seoul", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "Seoul TOPIS / Korail / Seoul Metro",
		DataSourceURL:        "https://data.seoul.go.kr",
		DataLicense:          "Korea Open Government License (Type 1)",
		Attribution:          "Data provided by Seoul Metropolitan Government (TOPIS) & Seoul Metro",
		LastSuccessfulSync:   now.Add(-10 * time.Minute),
		DataFreshnessMinutes: 1,
		ValidationStatus:     "VERIFIED_FULL",
	}

	s.Coverage["tokyo"] = model.CoverageRegistry{
		CityID: "tokyo", CityName: "Tokyo", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "Tokyo Metro Co., Ltd. & Toei Transportation / ODPT",
		DataSourceURL:        "https://developer.odpt.org",
		DataLicense:          "ODPT Open Data License",
		Attribution:          "Data provided by Open Data Challenge for Public Transportation in Tokyo",
		LastSuccessfulSync:   now.Add(-15 * time.Minute),
		DataFreshnessMinutes: 2,
		ValidationStatus:     "VERIFIED_FULL",
	}

	s.Coverage["london"] = model.CoverageRegistry{
		CityID: "london", CityName: "London", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "Transport for London (TfL Open Data)",
		DataSourceURL:        "https://api.tfl.gov.uk",
		DataLicense:          "UK Open Government Licence v3.0",
		Attribution:          "Powered by TfL Open Data",
		LastSuccessfulSync:   now.Add(-8 * time.Minute),
		DataFreshnessMinutes: 1,
		ValidationStatus:     "VERIFIED_FULL",
	}

	s.Coverage["paris"] = model.CoverageRegistry{
		CityID: "paris", CityName: "Paris", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "Île-de-France Mobilités / RATP",
		DataSourceURL:        "https://prim.iledefrance-mobilites.fr",
		DataLicense:          "Licence Ouverte v2.0",
		Attribution:          "Données fournies par Île-de-France Mobilités",
		LastSuccessfulSync:   now.Add(-12 * time.Minute),
		DataFreshnessMinutes: 2,
		ValidationStatus:     "VERIFIED_FULL",
	}

	s.Coverage["newyork"] = model.CoverageRegistry{
		CityID: "newyork", CityName: "New York", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "MTA Open Data",
		DataSourceURL:        "https://new.mta.info/developers",
		DataLicense:          "MTA Open Data Policy",
		Attribution:          "Metropolitan Transportation Authority (MTA)",
		LastSuccessfulSync:   now.Add(-20 * time.Minute),
		DataFreshnessMinutes: 3,
		ValidationStatus:     "VERIFIED_FULL",
	}

	s.Coverage["singapore"] = model.CoverageRegistry{
		CityID: "singapore", CityName: "Singapore", CoverageLevel: model.CoverageLevelA,
		MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
		ScheduleAvailable: true, RealtimeAvailable: true, FaresAvailable: true, AccessibilityAvailable: true,
		OfficialDataProvider: "Land Transport Authority (LTA DataMall)",
		DataSourceURL:        "https://datamall.lta.gov.sg",
		DataLicense:          "Singapore Open Data Licence",
		Attribution:          "Contains information from Land Transport Authority (LTA)",
		LastSuccessfulSync:   now.Add(-5 * time.Minute),
		DataFreshnessMinutes: 1,
		ValidationStatus:     "VERIFIED_FULL",
	}

	// Level B
	for _, id := range []string{"osaka", "hongkong", "taipei", "bangkok", "berlin", "sanfrancisco", "toronto", "sydney"} {
		s.Coverage[id] = model.CoverageRegistry{
			CityID: id, CityName: id, CoverageLevel: model.CoverageLevelB,
			MetroMapAvailable: true, MetroRoutesAvailable: true, BusRoutesAvailable: true,
			ScheduleAvailable: true, RealtimeAvailable: false, FaresAvailable: true, AccessibilityAvailable: true,
			OfficialDataProvider: "Regional GTFS Data Feeds & OpenStreetMap",
			DataSourceURL:        "https://mobilitydatabase.org",
			DataLicense:          "Open Database License (ODbL) / Public Agency Terms",
			Attribution:          "Transit schedules derived from official GTFS schedule archives",
			LastSuccessfulSync:   now.Add(-24 * time.Hour),
			DataFreshnessMinutes: 60,
			ValidationStatus:     "SCHEDULE_ONLY",
		}
	}

	// Level C
	for _, id := range []string{"dubai", "istanbul"} {
		s.Coverage[id] = model.CoverageRegistry{
			CityID: id, CityName: id, CoverageLevel: model.CoverageLevelC,
			MetroMapAvailable: true, MetroRoutesAvailable: false, BusRoutesAvailable: false,
			ScheduleAvailable: false, RealtimeAvailable: false, FaresAvailable: false, AccessibilityAvailable: false,
			OfficialDataProvider: "Official Metro Schematic Map Registry",
			DataSourceURL:        "https://openstreetmap.org",
			DataLicense:          "ODbL",
			Attribution:          "Map rendering based on OpenStreetMap contributors",
			LastSuccessfulSync:   now.Add(-48 * time.Hour),
			DataFreshnessMinutes: 1440,
			ValidationStatus:     "MAP_ONLY",
		}
	}

	// Level D
	for _, id := range []string{"saopaulo", "mexicocity"} {
		s.Coverage[id] = model.CoverageRegistry{
			CityID: id, CityName: id, CoverageLevel: model.CoverageLevelD,
			MetroMapAvailable: false, MetroRoutesAvailable: false, BusRoutesAvailable: false,
			ScheduleAvailable: false, RealtimeAvailable: false, FaresAvailable: false, AccessibilityAvailable: false,
			OfficialDataProvider: "OpenStreetMap POI & Municipal Directories",
			DataSourceURL:        "https://openstreetmap.org",
			DataLicense:          "ODbL",
			Attribution:          "Attraction and street data from OSM contributors",
			LastSuccessfulSync:   now.Add(-72 * time.Hour),
			DataFreshnessMinutes: 2880,
			ValidationStatus:     "DESTINATIONS_ONLY",
		}
	}
}

func (s *SeedStore) initSeoulTransit() {
	lines := []model.MetroLine{
		{
			ID: "kr_seoul_l1", CityID: "seoul", LineNumber: "1", Name: "1호선", EnglishName: "Line 1",
			ColorHex: "#0052A4", TextColorHex: "#FFFFFF",
			StationIDs: []string{"kr_sel_seoul_stn", "kr_sel_cityhall", "kr_sel_jonggak", "kr_sel_dongdaemun"},
			IsCircular: false, OperatingHours: "05:10 - 24:00",
		},
		{
			ID: "kr_seoul_l2", CityID: "seoul", LineNumber: "2", Name: "2호선", EnglishName: "Line 2 (Circle)",
			ColorHex: "#00A84D", TextColorHex: "#FFFFFF",
			StationIDs: []string{"kr_sel_cityhall", "kr_sel_euljiro1", "kr_sel_ddp", "kr_sel_gangnam", "kr_sel_hongik"},
			IsCircular: true, OperatingHours: "05:30 - 24:30",
		},
		{
			ID: "kr_seoul_l3", CityID: "seoul", LineNumber: "3", Name: "3호선", EnglishName: "Line 3",
			ColorHex: "#EF7C1C", TextColorHex: "#FFFFFF",
			StationIDs: []string{"kr_sel_gyeongbokgung", "kr_sel_jongno3", "kr_sel_anguk", "kr_sel_express_bus"},
			IsCircular: false, OperatingHours: "05:30 - 24:00",
		},
		{
			ID: "kr_seoul_l4", CityID: "seoul", LineNumber: "4", Name: "4호선", EnglishName: "Line 4",
			ColorHex: "#00A5DE", TextColorHex: "#FFFFFF",
			StationIDs: []string{"kr_sel_dongdaemun", "kr_sel_ddp", "kr_sel_myeongdong", "kr_sel_seoul_stn"},
			IsCircular: false, OperatingHours: "05:30 - 24:00",
		},
	}
	s.MetroLines["seoul"] = lines

	stations := []model.MetroStation{
		{
			ID: "kr_sel_seoul_stn", CityID: "seoul", Code: "133", Name: "서울역", EnglishName: "Seoul Station", LocalName: "서울역",
			Latitude: 37.5559, Longitude: 126.9723, SchematicX: 200, SchematicY: 300,
			Lines: []string{"kr_seoul_l1", "kr_seoul_l4"},
			Exits: []model.StationExit{
				{ExitNumber: "1", Destinations: []string{"Seoul Station Square", "Lotte Mart"}, HasElevator: true, HasEscalator: true},
				{ExitNumber: "9", Destinations: []string{"Seoullo 7017", "Namdaemun Police Station"}, HasElevator: true, HasEscalator: false},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:12", LastTrain: "23:58",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_seoul_stn"}, NearbyPlaceIDs: []string{"sel_n_seoul_tower"},
		},
		{
			ID: "kr_sel_cityhall", CityID: "seoul", Code: "132", Name: "시청", EnglishName: "City Hall", LocalName: "시청",
			Latitude: 37.5657, Longitude: 126.9769, SchematicX: 250, SchematicY: 250,
			Lines: []string{"kr_seoul_l1", "kr_seoul_l2"},
			Exits: []model.StationExit{
				{ExitNumber: "1", Destinations: []string{"Deoksugung Palace", "Seoul Plaza"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:32", LastTrain: "00:15",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_cityhall"}, NearbyPlaceIDs: []string{"sel_gyeongbokgung"},
		},
		{
			ID: "kr_sel_jonggak", CityID: "seoul", Code: "131", Name: "종각", EnglishName: "Jonggak", LocalName: "종각",
			Latitude: 37.5702, Longitude: 126.9830, SchematicX: 300, SchematicY: 220,
			Lines: []string{"kr_seoul_l1"},
			Exits: []model.StationExit{
				{ExitNumber: "3", Destinations: []string{"Insadong Street", "Bosingak Bell"}, HasElevator: false, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:35", LastTrain: "23:55",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_jonggak"}, NearbyPlaceIDs: []string{"sel_insadong"},
		},
		{
			ID: "kr_sel_gyeongbokgung", CityID: "seoul", Code: "327", Name: "경복궁", EnglishName: "Gyeongbokgung", LocalName: "경복궁 (정부서울청사)",
			Latitude: 37.5759, Longitude: 126.9735, SchematicX: 250, SchematicY: 150,
			Lines: []string{"kr_seoul_l3"},
			Exits: []model.StationExit{
				{ExitNumber: "5", Destinations: []string{"Gyeongbokgung Palace Entrance", "National Palace Museum"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:30", LastTrain: "23:45",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_gyeongbokgung"}, NearbyPlaceIDs: []string{"sel_gyeongbokgung", "sel_bukchon"},
		},
		{
			ID: "kr_sel_myeongdong", CityID: "seoul", Code: "424", Name: "명동", EnglishName: "Myeong-dong", LocalName: "명동",
			Latitude: 37.5609, Longitude: 126.9863, SchematicX: 320, SchematicY: 280,
			Lines: []string{"kr_seoul_l4"},
			Exits: []model.StationExit{
				{ExitNumber: "6", Destinations: []string{"Myeongdong Shopping Street", "Myeongdong Cathedral"}, HasElevator: false, HasEscalator: true},
				{ExitNumber: "3", Destinations: []string{"Namsan Cable Car / N Seoul Tower"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:38", LastTrain: "23:52",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_myeongdong"}, NearbyPlaceIDs: []string{"sel_myeongdong_cath", "sel_n_seoul_tower"},
		},
		{
			ID: "kr_sel_ddp", CityID: "seoul", Code: "205", Name: "동대문역사문화공원", EnglishName: "Dongdaemun History & Culture Park", LocalName: "동대문역사문화공원",
			Latitude: 37.5651, Longitude: 127.0079, SchematicX: 420, SchematicY: 250,
			Lines: []string{"kr_seoul_l2", "kr_seoul_l4"},
			Exits: []model.StationExit{
				{ExitNumber: "1", Destinations: []string{"Dongdaemun Design Plaza (DDP)"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:30", LastTrain: "00:10",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_ddp"}, NearbyPlaceIDs: []string{"sel_ddp"},
		},
		{
			ID: "kr_sel_gangnam", CityID: "seoul", Code: "222", Name: "강남", EnglishName: "Gangnam", LocalName: "강남",
			Latitude: 37.4979, Longitude: 127.0276, SchematicX: 420, SchematicY: 450,
			Lines: []string{"kr_seoul_l2"},
			Exits: []model.StationExit{
				{ExitNumber: "10", Destinations: []string{"Gangnam Boulevard", "Kakao Friends Flagship"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:30", LastTrain: "00:30",
			NearbyBusStopIDs: []string{"kr_sel_bus_stop_gangnam"}, NearbyPlaceIDs: []string{"sel_lotte_tower"},
		},
	}
	s.MetroStations["seoul"] = stations

	// Seoul Buses
	stops := []model.BusStop{
		{ID: "kr_sel_bus_stop_seoul_stn", CityID: "seoul", Code: "02006", Name: "서울역버스환승센터", EnglishName: "Seoul Station Transit Center", Latitude: 37.5562, Longitude: 126.9729, NearbyMetroStationID: "kr_sel_seoul_stn"},
		{ID: "kr_sel_bus_stop_cityhall", CityID: "seoul", Code: "02128", Name: "시청앞.덕수궁", EnglishName: "City Hall & Deoksugung", Latitude: 37.5654, Longitude: 126.9765, NearbyMetroStationID: "kr_sel_cityhall"},
		{ID: "kr_sel_bus_stop_gyeongbokgung", CityID: "seoul", Code: "01116", Name: "경복궁역", EnglishName: "Gyeongbokgung Station Stop", Latitude: 37.5762, Longitude: 126.9731, NearbyMetroStationID: "kr_sel_gyeongbokgung"},
		{ID: "kr_sel_bus_stop_myeongdong", CityID: "seoul", Code: "02149", Name: "명동입구", EnglishName: "Myeongdong Entrance", Latitude: 37.5615, Longitude: 126.9858, NearbyMetroStationID: "kr_sel_myeongdong"},
		{ID: "kr_sel_bus_stop_ddp", CityID: "seoul", Code: "02235", Name: "동대문역사문화공원", EnglishName: "DDP Plaza Stop", Latitude: 37.5660, Longitude: 127.0090, NearbyMetroStationID: "kr_sel_ddp"},
	}
	s.BusStops["seoul"] = stops

	routes := []model.BusRoute{
		{
			ID: "kr_sel_bus_100", CityID: "seoul", RouteNumber: "100", Name: "간선 100번", Operator: "Hansung Bus",
			Origin: "Hwagye Station", Destination: "Seoul Station", ColorHex: "#0052A4",
			StopIDs: []string{"kr_sel_bus_stop_gyeongbokgung", "kr_sel_bus_stop_cityhall", "kr_sel_bus_stop_seoul_stn"},
			LowFloor: true, IntervalMin: 8, FirstBus: "04:00", LastBus: "22:45", Fare: "₩1,500",
		},
		{
			ID: "kr_sel_bus_401", CityID: "seoul", RouteNumber: "401", Name: "간선 401번", Operator: "Seoul Bus Co.",
			Origin: "Gangnam Station", Destination: "Gwanghwamun", ColorHex: "#0052A4",
			StopIDs: []string{"kr_sel_bus_stop_seoul_stn", "kr_sel_bus_stop_myeongdong", "kr_sel_bus_stop_cityhall"},
			LowFloor: true, IntervalMin: 9, FirstBus: "04:15", LastBus: "23:00", Fare: "₩1,500",
		},
	}
	s.BusRoutes["seoul"] = routes

	now := time.Now()
	s.RealtimeArrivals["kr_sel_bus_stop_cityhall"] = []model.RealtimeArrival{
		{StopID: "kr_sel_bus_stop_cityhall", RouteID: "kr_sel_bus_100", RouteNumber: "100", Destination: "Seoul Station", MinutesAway: 3, StopsRemaining: 2, Status: model.StatusLive, VehiclePlate: "서울74사 1284", CrowdingLevel: "Moderate", UpdatedAt: now},
		{StopID: "kr_sel_bus_stop_cityhall", RouteID: "kr_sel_bus_401", RouteNumber: "401", Destination: "Gwanghwamun", MinutesAway: 7, StopsRemaining: 4, Status: model.StatusLive, VehiclePlate: "서울74사 5521", CrowdingLevel: "Low", UpdatedAt: now},
	}
	s.RealtimeArrivals["kr_sel_bus_stop_seoul_stn"] = []model.RealtimeArrival{
		{StopID: "kr_sel_bus_stop_seoul_stn", RouteID: "kr_sel_bus_100", RouteNumber: "100", Destination: "Terminal", MinutesAway: 1, StopsRemaining: 1, Status: model.StatusLive, VehiclePlate: "서울74사 1284", CrowdingLevel: "Low", UpdatedAt: now},
	}
}

func (s *SeedStore) initTokyoTransit() {
	lines := []model.MetroLine{
		{
			ID: "jp_tky_yamanote", CityID: "tokyo", LineNumber: "JY", Name: "山手線", EnglishName: "JR Yamanote Line",
			ColorHex: "#9ACD32", TextColorHex: "#FFFFFF",
			StationIDs: []string{"jp_tky_tokyo", "jp_tky_akihabara", "jp_tky_ueno", "jp_tky_shinjuku", "jp_tky_shibuya"},
			IsCircular: true, OperatingHours: "04:30 - 01:00",
		},
		{
			ID: "jp_tky_ginza", CityID: "tokyo", LineNumber: "G", Name: "銀座線", EnglishName: "Tokyo Metro Ginza Line",
			ColorHex: "#FF9500", TextColorHex: "#FFFFFF",
			StationIDs: []string{"jp_tky_asakusa", "jp_tky_ueno", "jp_tky_ginza", "jp_tky_shibuya"},
			IsCircular: false, OperatingHours: "05:00 - 00:30",
		},
		{
			ID: "jp_tky_asakusa_line", CityID: "tokyo", LineNumber: "A", Name: "浅草線", EnglishName: "Toei Asakusa Line",
			ColorHex: "#E85298", TextColorHex: "#FFFFFF",
			StationIDs: []string{"jp_tky_asakusa", "jp_tky_ginza", "jp_tky_shimbashi"},
			IsCircular: false, OperatingHours: "05:05 - 00:20",
		},
	}
	s.MetroLines["tokyo"] = lines

	stations := []model.MetroStation{
		{
			ID: "jp_tky_tokyo", CityID: "tokyo", Code: "TYO", Name: "東京", EnglishName: "Tokyo Station", LocalName: "東京駅",
			Latitude: 35.6812, Longitude: 139.7671, SchematicX: 300, SchematicY: 280,
			Lines: []string{"jp_tky_yamanote"},
			Exits: []model.StationExit{
				{ExitNumber: "Marunouchi North", Destinations: []string{"Imperial Palace", "Otemachi"}, HasElevator: true, HasEscalator: true},
				{ExitNumber: "Yaesu Central", Destinations: []string{"Shinkansen Gates", "Daimaru"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "04:45", LastTrain: "00:40",
			NearbyBusStopIDs: []string{"jp_tky_bus_tokyo_stn"}, NearbyPlaceIDs: []string{"tky_imperial_palace"},
		},
		{
			ID: "jp_tky_asakusa", CityID: "tokyo", Code: "G19", Name: "浅草", EnglishName: "Asakusa Station", LocalName: "浅草駅",
			Latitude: 35.7119, Longitude: 139.7983, SchematicX: 420, SchematicY: 150,
			Lines: []string{"jp_tky_ginza", "jp_tky_asakusa_line"},
			Exits: []model.StationExit{
				{ExitNumber: "Exit 1", Destinations: []string{"Senso-ji Temple", "Kaminarimon Gate"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:01", LastTrain: "00:15",
			NearbyBusStopIDs: []string{"jp_tky_bus_asakusa"}, NearbyPlaceIDs: []string{"tky_sensoji", "tky_skytree"},
		},
		{
			ID: "jp_tky_shibuya", CityID: "tokyo", Code: "G01", Name: "渋谷", EnglishName: "Shibuya Station", LocalName: "渋谷駅",
			Latitude: 35.6580, Longitude: 139.7016, SchematicX: 180, SchematicY: 380,
			Lines: []string{"jp_tky_yamanote", "jp_tky_ginza"},
			Exits: []model.StationExit{
				{ExitNumber: "Hachiko Exit", Destinations: []string{"Shibuya Scramble Crossing", "Hachiko Statue"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "04:52", LastTrain: "00:52",
			NearbyBusStopIDs: []string{"jp_tky_bus_shibuya"}, NearbyPlaceIDs: []string{"tky_shibuya_scramble"},
		},
		{
			ID: "jp_tky_ueno", CityID: "tokyo", Code: "G16", Name: "上野", EnglishName: "Ueno Station", LocalName: "上野駅",
			Latitude: 35.7141, Longitude: 139.7774, SchematicX: 360, SchematicY: 180,
			Lines: []string{"jp_tky_yamanote", "jp_tky_ginza"},
			Exits: []model.StationExit{
				{ExitNumber: "Park Exit", Destinations: []string{"Ueno Park", "Tokyo National Museum"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "04:40", LastTrain: "00:45",
			NearbyBusStopIDs: []string{"jp_tky_bus_ueno"}, NearbyPlaceIDs: []string{"tky_ueno_park"},
		},
	}
	s.MetroStations["tokyo"] = stations

	// Tokyo Buses
	s.BusStops["tokyo"] = []model.BusStop{
		{ID: "jp_tky_bus_asakusa", CityID: "tokyo", Code: "TKY-B-01", Name: "浅草雷門", EnglishName: "Asakusa Kaminarimon", Latitude: 35.7112, Longitude: 139.7968, NearbyMetroStationID: "jp_tky_asakusa"},
		{ID: "jp_tky_bus_tokyo_stn", CityID: "tokyo", Code: "TKY-B-02", Name: "東京駅丸の内南口", EnglishName: "Tokyo Stn Marunouchi South", Latitude: 35.6805, Longitude: 139.7658, NearbyMetroStationID: "jp_tky_tokyo"},
	}

	s.BusRoutes["tokyo"] = []model.BusRoute{
		{
			ID: "jp_tky_bus_to06", CityID: "tokyo", RouteNumber: "都06", Name: "都営バス 都06", Operator: "Toei Bus",
			Origin: "Shibuya Stn", Destination: "Shimbashi Stn", ColorHex: "#009944",
			StopIDs: []string{"jp_tky_bus_shibuya", "jp_tky_bus_tokyo_stn"},
			LowFloor: true, IntervalMin: 10, FirstBus: "05:30", LastBus: "22:30", Fare: "¥210",
		},
	}

	s.RealtimeArrivals["jp_tky_bus_asakusa"] = []model.RealtimeArrival{
		{StopID: "jp_tky_bus_asakusa", RouteID: "jp_tky_bus_to06", RouteNumber: "S-1", Destination: "Tokyo Skytree", MinutesAway: 4, StopsRemaining: 2, Status: model.StatusLive, VehiclePlate: "足立200 か 31-29", CrowdingLevel: "Low", UpdatedAt: time.Now()},
	}
}

func (s *SeedStore) initLondonTransit() {
	lines := []model.MetroLine{
		{
			ID: "gb_lon_central", CityID: "london", LineNumber: "Central", Name: "Central Line", EnglishName: "Central Line",
			ColorHex: "#E32017", TextColorHex: "#FFFFFF",
			StationIDs: []string{"gb_lon_nottinghill", "gb_lon_oxfordcircus", "gb_lon_holborn", "gb_lon_liverpoolst"},
			IsCircular: false, OperatingHours: "05:15 - 00:30 (24h Fri/Sat)",
		},
		{
			ID: "gb_lon_jubilee", CityID: "london", LineNumber: "Jubilee", Name: "Jubilee Line", EnglishName: "Jubilee Line",
			ColorHex: "#A0A5A9", TextColorHex: "#FFFFFF",
			StationIDs: []string{"gb_lon_bakerst", "gb_lon_westminster", "gb_lon_waterloo", "gb_lon_londonbridge"},
			IsCircular: false, OperatingHours: "05:20 - 00:30 (24h Fri/Sat)",
		},
		{
			ID: "gb_lon_piccadilly", CityID: "london", LineNumber: "Piccadilly", Name: "Piccadilly Line", EnglishName: "Piccadilly Line",
			ColorHex: "#003688", TextColorHex: "#FFFFFF",
			StationIDs: []string{"gb_lon_kingscross", "gb_lon_holborn", "gb_lon_piccadillycircus", "gb_lon_southkensington"},
			IsCircular: false, OperatingHours: "05:30 - 00:30 (24h Fri/Sat)",
		},
	}
	s.MetroLines["london"] = lines

	stations := []model.MetroStation{
		{
			ID: "gb_lon_westminster", CityID: "london", Code: "WMS", Name: "Westminster", EnglishName: "Westminster", LocalName: "Westminster",
			Latitude: 51.5014, Longitude: -0.1250, SchematicX: 250, SchematicY: 300,
			Lines: []string{"gb_lon_jubilee"},
			Exits: []model.StationExit{
				{ExitNumber: "Bridge Street", Destinations: []string{"Big Ben", "Houses of Parliament", "Westminster Abbey"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:35", LastTrain: "00:20",
			NearbyBusStopIDs: []string{"gb_lon_bus_westminster"}, NearbyPlaceIDs: []string{"lon_big_ben", "lon_london_eye"},
		},
		{
			ID: "gb_lon_kingscross", CityID: "london", Code: "KGX", Name: "King's Cross St. Pancras", EnglishName: "King's Cross St. Pancras", LocalName: "King's Cross",
			Latitude: 51.5308, Longitude: -0.1238, SchematicX: 280, SchematicY: 150,
			Lines: []string{"gb_lon_piccadilly"},
			Exits: []model.StationExit{
				{ExitNumber: "Eurostar / St Pancras", Destinations: []string{"Platform 9 3/4", "British Library"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:25", LastTrain: "00:35",
			NearbyBusStopIDs: []string{"gb_lon_bus_kingscross"}, NearbyPlaceIDs: []string{"lon_british_museum"},
		},
		{
			ID: "gb_lon_piccadillycircus", CityID: "london", Code: "PIC", Name: "Piccadilly Circus", EnglishName: "Piccadilly Circus", LocalName: "Piccadilly Circus",
			Latitude: 51.5100, Longitude: -0.1347, SchematicX: 220, SchematicY: 230,
			Lines: []string{"gb_lon_piccadilly"},
			Exits: []model.StationExit{
				{ExitNumber: "Shaftesbury Ave", Destinations: []string{"West End Theatres", "Chinatown", "Soho"}, HasElevator: false, HasEscalator: true},
			},
			ElevatorAccessible: false, WheelchairBoarding: false, FirstTrain: "05:40", LastTrain: "00:25",
			NearbyBusStopIDs: []string{"gb_lon_bus_piccadilly"}, NearbyPlaceIDs: []string{"lon_tower_bridge"},
		},
	}
	s.MetroStations["london"] = stations

	s.BusStops["london"] = []model.BusStop{
		{ID: "gb_lon_bus_westminster", CityID: "london", Code: "BP4001", Name: "Westminster Station / Parliament Sq", EnglishName: "Westminster Station", Latitude: 51.5011, Longitude: -0.1258, NearbyMetroStationID: "gb_lon_westminster"},
	}
	s.BusRoutes["london"] = []model.BusRoute{
		{
			ID: "gb_lon_bus_11", CityID: "london", RouteNumber: "11", Name: "Route 11 (Heritage route)", Operator: "London General",
			Origin: "Fulham Town Hall", Destination: "Waterloo Station", ColorHex: "#CC0000",
			StopIDs: []string{"gb_lon_bus_westminster"}, LowFloor: true, IntervalMin: 10, FirstBus: "05:00", LastBus: "23:50", Fare: "£1.75",
		},
	}
	s.RealtimeArrivals["gb_lon_bus_westminster"] = []model.RealtimeArrival{
		{StopID: "gb_lon_bus_westminster", RouteID: "gb_lon_bus_11", RouteNumber: "11", Destination: "Waterloo", MinutesAway: 2, StopsRemaining: 1, Status: model.StatusLive, VehiclePlate: "LTZ 1148", CrowdingLevel: "Low", UpdatedAt: time.Now()},
	}
}

func (s *SeedStore) initParisTransit() {
	lines := []model.MetroLine{
		{
			ID: "fr_par_m1", CityID: "paris", LineNumber: "1", Name: "Ligne 1", EnglishName: "Line 1",
			ColorHex: "#FFCD00", TextColorHex: "#000000",
			StationIDs: []string{"fr_par_champs_elysees", "fr_par_louvre_rivoli", "fr_par_chatelet", "fr_par_bastille"},
			IsCircular: false, OperatingHours: "05:30 - 01:15",
		},
		{
			ID: "fr_par_m6", CityID: "paris", LineNumber: "6", Name: "Ligne 6", EnglishName: "Line 6",
			ColorHex: "#7eceb1", TextColorHex: "#000000",
			StationIDs: []string{"fr_par_bir_hakeim", "fr_par_montparnasse", "fr_par_nation"},
			IsCircular: false, OperatingHours: "05:30 - 01:15",
		},
	}
	s.MetroLines["paris"] = lines

	stations := []model.MetroStation{
		{
			ID: "fr_par_bir_hakeim", CityID: "paris", Code: "BIH", Name: "Bir-Hakeim (Tour Eiffel)", EnglishName: "Bir-Hakeim", LocalName: "Bir-Hakeim",
			Latitude: 48.8539, Longitude: 2.2893, SchematicX: 150, SchematicY: 300,
			Lines: []string{"fr_par_m6"},
			Exits: []model.StationExit{
				{ExitNumber: "Sortie 1", Destinations: []string{"Tour Eiffel (Eiffel Tower)", "Pont de Bir-Hakeim"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:35", LastTrain: "01:05",
			NearbyBusStopIDs: []string{"fr_par_bus_eiffel"}, NearbyPlaceIDs: []string{"par_eiffel_tower"},
		},
		{
			ID: "fr_par_louvre_rivoli", CityID: "paris", Code: "LOU", Name: "Louvre - Rivoli", EnglishName: "Louvre - Rivoli", LocalName: "Louvre - Rivoli",
			Latitude: 48.8607, Longitude: 2.3406, SchematicX: 280, SchematicY: 220,
			Lines: []string{"fr_par_m1"},
			Exits: []model.StationExit{
				{ExitNumber: "Sortie 1", Destinations: []string{"Musée du Louvre", "Rue de Rivoli"}, HasElevator: false, HasEscalator: true},
			},
			ElevatorAccessible: false, WheelchairBoarding: false, FirstTrain: "05:32", LastTrain: "01:18",
			NearbyBusStopIDs: []string{"fr_par_bus_louvre"}, NearbyPlaceIDs: []string{"par_louvre_museum"},
		},
	}
	s.MetroStations["paris"] = stations

	s.BusStops["paris"] = []model.BusStop{
		{ID: "fr_par_bus_eiffel", CityID: "paris", Code: "PAR-B-72", Name: "Tour Eiffel", EnglishName: "Eiffel Tower Stop", Latitude: 48.8575, Longitude: 2.2933, NearbyMetroStationID: "fr_par_bir_hakeim"},
	}
	s.BusRoutes["paris"] = []model.BusRoute{
		{
			ID: "fr_par_bus_72", CityID: "paris", RouteNumber: "72", Name: "Bus 72 (Seine Riverbank)", Operator: "RATP",
			Origin: "Parc de Saint-Cloud", Destination: "Gare de Lyon", ColorHex: "#00643C",
			StopIDs: []string{"fr_par_bus_eiffel"}, LowFloor: true, IntervalMin: 8, FirstBus: "06:00", LastBus: "00:30", Fare: "€2.15",
		},
	}
	s.RealtimeArrivals["fr_par_bus_eiffel"] = []model.RealtimeArrival{
		{StopID: "fr_par_bus_eiffel", RouteID: "fr_par_bus_72", RouteNumber: "72", Destination: "Gare de Lyon", MinutesAway: 3, StopsRemaining: 2, Status: model.StatusLive, VehiclePlate: "FL-892-XT", CrowdingLevel: "Low", UpdatedAt: time.Now()},
	}
}

func (s *SeedStore) initNewYorkTransit() {
	lines := []model.MetroLine{
		{
			ID: "us_nyc_subway_1", CityID: "newyork", LineNumber: "1", Name: "Broadway - 7 Avenue Local", EnglishName: "1 Train",
			ColorHex: "#EE352E", TextColorHex: "#FFFFFF",
			StationIDs: []string{"us_nyc_times_sq", "us_nyc_columbus_circle", "us_nyc_south_ferry"},
			IsCircular: false, OperatingHours: "24 Hours / 7 Days",
		},
		{
			ID: "us_nyc_subway_nqrw", CityID: "newyork", LineNumber: "N", Name: "Broadway Express", EnglishName: "N Train",
			ColorHex: "#FCCC0A", TextColorHex: "#000000",
			StationIDs: []string{"us_nyc_times_sq", "us_nyc_union_sq", "us_nyc_canal_st"},
			IsCircular: false, OperatingHours: "24 Hours / 7 Days",
		},
	}
	s.MetroLines["newyork"] = lines

	stations := []model.MetroStation{
		{
			ID: "us_nyc_times_sq", CityID: "newyork", Code: "127", Name: "Times Sq - 42 St", EnglishName: "Times Square - 42nd St", LocalName: "Times Square",
			Latitude: 40.7553, Longitude: -73.9870, SchematicX: 250, SchematicY: 200,
			Lines: []string{"us_nyc_subway_1", "us_nyc_subway_nqrw"},
			Exits: []model.StationExit{
				{ExitNumber: "Broadway & 42nd", Destinations: []string{"Times Square", "Broadway Theatres"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "00:00", LastTrain: "23:59",
			NearbyBusStopIDs: []string{"us_nyc_bus_times_sq"}, NearbyPlaceIDs: []string{"nyc_times_square", "nyc_empire_state"},
		},
		{
			ID: "us_nyc_south_ferry", CityID: "newyork", Code: "142", Name: "South Ferry", EnglishName: "South Ferry", LocalName: "South Ferry",
			Latitude: 40.7021, Longitude: -74.0135, SchematicX: 250, SchematicY: 420,
			Lines: []string{"us_nyc_subway_1"},
			Exits: []model.StationExit{
				{ExitNumber: "Battery Park", Destinations: []string{"Statue of Liberty Ferry", "Staten Island Ferry"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "00:00", LastTrain: "23:59",
			NearbyBusStopIDs: []string{"us_nyc_bus_battery"}, NearbyPlaceIDs: []string{"nyc_statue_liberty"},
		},
	}
	s.MetroStations["newyork"] = stations

	s.BusStops["newyork"] = []model.BusStop{
		{ID: "us_nyc_bus_times_sq", CityID: "newyork", Code: "MTA-4022", Name: "7 Av / W 41 St", EnglishName: "7th Ave & 41st St", Latitude: 40.7558, Longitude: -73.9875, NearbyMetroStationID: "us_nyc_times_sq"},
	}
	s.BusRoutes["newyork"] = []model.BusRoute{
		{
			ID: "us_nyc_bus_m7", CityID: "newyork", RouteNumber: "M7", Name: "M7 (Broadway / Columbus)", Operator: "MTA New York City Transit",
			Origin: "Harlem", Destination: "14th Street", ColorHex: "#0039A6",
			StopIDs: []string{"us_nyc_bus_times_sq"}, LowFloor: true, IntervalMin: 12, FirstBus: "24h", LastBus: "24h", Fare: "$2.90",
		},
	}
	s.RealtimeArrivals["us_nyc_bus_times_sq"] = []model.RealtimeArrival{
		{StopID: "us_nyc_bus_times_sq", RouteID: "us_nyc_bus_m7", RouteNumber: "M7", Destination: "14th Street", MinutesAway: 5, StopsRemaining: 3, Status: model.StatusLive, VehiclePlate: "MTA-5912", CrowdingLevel: "High", UpdatedAt: time.Now()},
	}
}

func (s *SeedStore) initSingaporeTransit() {
	lines := []model.MetroLine{
		{
			ID: "sg_mrt_dtl", CityID: "singapore", LineNumber: "DT", Name: "Downtown Line", EnglishName: "Downtown Line",
			ColorHex: "#005EC4", TextColorHex: "#FFFFFF",
			StationIDs: []string{"sg_mrt_bayfront", "sg_mrt_chinatown", "sg_mrt_bugis"},
			IsCircular: false, OperatingHours: "05:30 - 00:00",
		},
		{
			ID: "sg_mrt_ccl", CityID: "singapore", LineNumber: "CC", Name: "Circle Line", EnglishName: "Circle Line",
			ColorHex: "#FA9E0D", TextColorHex: "#FFFFFF",
			StationIDs: []string{"sg_mrt_bayfront", "sg_mrt_marina_bay", "sg_mrt_harbourfront"},
			IsCircular: false, OperatingHours: "05:30 - 23:50",
		},
	}
	s.MetroLines["singapore"] = lines

	stations := []model.MetroStation{
		{
			ID: "sg_mrt_bayfront", CityID: "singapore", Code: "DT16 / CE1", Name: "海湾舫 (Bayfront)", EnglishName: "Bayfront", LocalName: "Bayfront",
			Latitude: 1.2828, Longitude: 103.8590, SchematicX: 300, SchematicY: 280,
			Lines: []string{"sg_mrt_dtl", "sg_mrt_ccl"},
			Exits: []model.StationExit{
				{ExitNumber: "Exit B", Destinations: []string{"Gardens by the Bay", "Marina Bay Sands"}, HasElevator: true, HasEscalator: true},
			},
			ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "06:02", LastTrain: "23:50",
			NearbyBusStopIDs: []string{"sg_bus_mbs"}, NearbyPlaceIDs: []string{"sg_gardens_by_bay", "sg_marina_bay_sands"},
		},
	}
	s.MetroStations["singapore"] = stations

	s.BusStops["singapore"] = []model.BusStop{
		{ID: "sg_bus_mbs", CityID: "singapore", Code: "03511", Name: "Marina Bay Sands Hotel", EnglishName: "MBS Hotel Stop", Latitude: 1.2835, Longitude: 103.8601, NearbyMetroStationID: "sg_mrt_bayfront"},
	}
	s.BusRoutes["singapore"] = []model.BusRoute{
		{
			ID: "sg_bus_97", CityID: "singapore", RouteNumber: "97", Name: "Service 97", Operator: "Tower Transit",
			Origin: "Jurong East", Destination: "Marina Centre", ColorHex: "#1BB251",
			StopIDs: []string{"sg_bus_mbs"}, LowFloor: true, IntervalMin: 9, FirstBus: "05:45", LastBus: "23:30", Fare: "S$1.65",
		},
	}
	s.RealtimeArrivals["sg_bus_mbs"] = []model.RealtimeArrival{
		{StopID: "sg_bus_mbs", RouteID: "sg_bus_97", RouteNumber: "97", Destination: "Marina Centre", MinutesAway: 3, StopsRemaining: 2, Status: model.StatusLive, VehiclePlate: "SG5821A", CrowdingLevel: "Low", UpdatedAt: time.Now()},
	}
}

func (s *SeedStore) initOtherCitiesTransit() {
	// Osaka
	s.MetroLines["osaka"] = []model.MetroLine{
		{ID: "jp_osa_midosuji", CityID: "osaka", LineNumber: "M", Name: "御堂筋線", EnglishName: "Midosuji Line", ColorHex: "#E5171F", TextColorHex: "#FFFFFF", StationIDs: []string{"jp_osa_umeda", "jp_osa_namba"}, IsCircular: false, OperatingHours: "05:00 - 24:00"},
	}
	s.MetroStations["osaka"] = []model.MetroStation{
		{ID: "jp_osa_namba", CityID: "osaka", Code: "M20", Name: "難波 (なんば)", EnglishName: "Namba", LocalName: "なんば", Latitude: 34.6669, Longitude: 135.5015, SchematicX: 200, SchematicY: 300, Lines: []string{"jp_osa_midosuji"}, ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "05:15", LastTrain: "23:55"},
	}

	// Hong Kong
	s.MetroLines["hongkong"] = []model.MetroLine{
		{ID: "hk_mtr_island", CityID: "hongkong", LineNumber: "ISL", Name: "港島綫", EnglishName: "Island Line", ColorHex: "#0071CE", TextColorHex: "#FFFFFF", StationIDs: []string{"hk_mtr_central", "hk_mtr_causeway"}, IsCircular: false, OperatingHours: "05:55 - 00:50"},
	}
	s.MetroStations["hongkong"] = []model.MetroStation{
		{ID: "hk_mtr_central", CityID: "hongkong", Code: "CEN", Name: "中環", EnglishName: "Central", LocalName: "中環", Latitude: 22.2819, Longitude: 114.1582, SchematicX: 200, SchematicY: 200, Lines: []string{"hk_mtr_island"}, ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "06:00", LastTrain: "00:45"},
	}

	// Taipei
	s.MetroLines["taipei"] = []model.MetroLine{
		{ID: "tw_tpe_red", CityID: "taipei", LineNumber: "R", Name: "淡水信義線", EnglishName: "Tamsui-Xinyi Line", ColorHex: "#E3002C", TextColorHex: "#FFFFFF", StationIDs: []string{"tw_tpe_taipei101", "tw_tpe_main"}, IsCircular: false, OperatingHours: "06:00 - 24:00"},
	}
	s.MetroStations["taipei"] = []model.MetroStation{
		{ID: "tw_tpe_taipei101", CityID: "taipei", Code: "R03", Name: "台北101/世貿", EnglishName: "Taipei 101 / World Trade Center", LocalName: "台北101/世貿", Latitude: 25.0330, Longitude: 121.5645, SchematicX: 300, SchematicY: 300, Lines: []string{"tw_tpe_red"}, ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "06:00", LastTrain: "00:15"},
	}

	// Berlin
	s.MetroLines["berlin"] = []model.MetroLine{
		{ID: "de_ber_u2", CityID: "berlin", LineNumber: "U2", Name: "U-Bahn Linie 2", EnglishName: "U2", ColorHex: "#FF0000", TextColorHex: "#FFFFFF", StationIDs: []string{"de_ber_alexanderplatz", "de_ber_potsdamer"}, IsCircular: false, OperatingHours: "04:30 - 00:30"},
	}
	s.MetroStations["berlin"] = []model.MetroStation{
		{ID: "de_ber_potsdamer", CityID: "berlin", Code: "POT", Name: "Potsdamer Platz", EnglishName: "Potsdamer Platz", LocalName: "Potsdamer Platz", Latitude: 52.5096, Longitude: 13.3759, SchematicX: 200, SchematicY: 200, Lines: []string{"de_ber_u2"}, ElevatorAccessible: true, WheelchairBoarding: true, FirstTrain: "04:45", LastTrain: "00:40"},
	}
}

func (s *SeedStore) initPlacesAndReviews() {
	now := time.Now()

	// SEOUL PLACES
	s.Places["seoul"] = []model.Place{
		{
			ID: "sel_gyeongbokgung", CityID: "seoul", Category: model.CategoryHistoric,
			Name: "경복궁", EnglishName: "Gyeongbokgung Palace", LocalName: "경복궁 (景福宮)",
			Description: "The grandest of Joseon dynasty's Five Grand Palaces, built in 1395. Visitors wearing traditional Hanbok enjoy free admission.",
			Latitude: 37.5796, Longitude: 126.9770, Rating: 4.8, ReviewCount: 3420,
			Address: "161 Sajik-ro, Jongno-gu, Seoul", OpeningHours: "09:00 - 18:00 (Closed Tuesdays)",
			AdmissionFee: "₩3,000 (Free with Hanbok)", OfficialWebsite: "https://royal.cha.go.kr", PhoneNumber: "+82-2-3700-3900",
			AccessibilityInfo: "Wheelchair ramps available throughout courtyards; free wheelchair rentals at ticket office.",
			BestTimeToVisit: "10:00 AM (Changing of the Royal Guard Ceremony)", EstimatedDurationMin: 120,
			NearestMetroStationID: "kr_sel_gyeongbokgung", NearestMetroStationName: "Gyeongbokgung Station (Exit 5)",
			NearestBusStopID: "kr_sel_bus_stop_gyeongbokgung",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1548115184-bc6544d06a58?auto=format&fit=crop&w=800&q=80",
				"https://images.unsplash.com/photo-1578637387939-43c525550085?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Palace", "History", "Hanbok", "Architecture"},
		},
		{
			ID: "sel_n_seoul_tower", CityID: "seoul", Category: model.CategoryNightView,
			Name: "N서울타워", EnglishName: "N Seoul Tower", LocalName: "N서울타워",
			Description: "Seoul's iconic landmark on Namsan Mountain, featuring 360-degree panoramic skyline views and famous love locks.",
			Latitude: 37.5512, Longitude: 126.9882, Rating: 4.6, ReviewCount: 2890,
			Address: "105 Namsangongwon-gil, Yongsan-gu, Seoul", OpeningHours: "10:30 - 22:30 daily",
			AdmissionFee: "₩21,000 (Observatory Deck)", OfficialWebsite: "https://www.nseoultower.co.kr", PhoneNumber: "+82-2-3455-9277",
			AccessibilityInfo: "Namsan Cable Car and shuttle buses provide wheelchair accessibility to the plaza.",
			BestTimeToVisit: "18:30 (Sunset into illuminated night view)", EstimatedDurationMin: 90,
			NearestMetroStationID: "kr_sel_myeongdong", NearestMetroStationName: "Myeong-dong Station (Exit 3)",
			NearestBusStopID: "kr_sel_bus_stop_myeongdong",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1517154421773-0529f29ea451?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Landmark", "Observatory", "Sunset", "Romantic"},
		},
		{
			ID: "sel_bukchon", CityID: "seoul", Category: model.CategoryHistoric,
			Name: "북촌한옥마을", EnglishName: "Bukchon Hanok Village", LocalName: "북촌한옥마을",
			Description: "A preserved neighborhood of hundreds of traditional Korean wooden houses (hanok) dating back to the Joseon dynasty.",
			Latitude: 37.5826, Longitude: 126.9837, Rating: 4.7, ReviewCount: 2150,
			Address: "Gahoe-dong, Jongno-gu, Seoul", OpeningHours: "10:00 - 17:00 (Residential quiet hours strictly enforced)",
			AdmissionFee: "Free", OfficialWebsite: "https://hanok.seoul.go.kr", PhoneNumber: "+82-2-2148-4161",
			AccessibilityInfo: "Hilly terrain with cobblestone inclines; limited wheelchair access on narrow alleys.",
			BestTimeToVisit: "Morning before 11:00 AM for quiet photo opportunities", EstimatedDurationMin: 90,
			NearestMetroStationID: "kr_sel_gyeongbokgung", NearestMetroStationName: "Anguk Station / Gyeongbokgung Station",
			NearestBusStopID: "kr_sel_bus_stop_gyeongbokgung",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Hanok", "Culture", "Photography", "Tradition"},
		},
		{
			ID: "sel_ddp", CityID: "seoul", Category: model.CategoryLandmark,
			Name: "동대문디자인플라자 (DDP)", EnglishName: "Dongdaemun Design Plaza", LocalName: "DDP",
			Description: "Zaha Hadid's futuristic architectural masterpiece featuring exhibitions, rooftop park, and night LED rose garden.",
			Latitude: 37.5665, Longitude: 127.0092, Rating: 4.7, ReviewCount: 1980,
			Address: "281 Eulji-ro, Jung-gu, Seoul", OpeningHours: "10:00 - 20:00 daily (Outdoor grounds open 24/7)",
			AdmissionFee: "Free for grounds; Special exhibitions ticketed", OfficialWebsite: "https://ddp.or.kr", PhoneNumber: "+82-2-2153-0000",
			AccessibilityInfo: "Fully barrier-free design with smooth ramps and elevators throughout.",
			BestTimeToVisit: "Evening when the undulating aluminum facade lights up", EstimatedDurationMin: 75,
			NearestMetroStationID: "kr_sel_ddp", NearestMetroStationName: "Dongdaemun History & Culture Park Station (Exit 1)",
			NearestBusStopID: "kr_sel_bus_stop_ddp",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Architecture", "Design", "NightView", "Exhibition"},
		},
	}

	// TOKYO PLACES
	s.Places["tokyo"] = []model.Place{
		{
			ID: "tky_sensoji", CityID: "tokyo", Category: model.CategoryHistoric,
			Name: "浅草寺", EnglishName: "Senso-ji Temple", LocalName: "金龍山 浅草寺",
			Description: "Tokyo's oldest and most significant Buddhist temple, founded in 645 AD, approached through Nakamise-dori shopping street.",
			Latitude: 35.7148, Longitude: 139.7967, Rating: 4.8, ReviewCount: 4120,
			Address: "2-3-1 Asakusa, Taito City, Tokyo", OpeningHours: "06:00 - 17:00 (Grounds open 24h)",
			AdmissionFee: "Free", OfficialWebsite: "https://www.senso-ji.jp", PhoneNumber: "+81-3-3842-0181",
			AccessibilityInfo: "Elevator installed in the Main Hall; wide stone pathways accessible for wheelchairs.",
			BestTimeToVisit: "08:30 AM before midday crowds arrive", EstimatedDurationMin: 90,
			NearestMetroStationID: "jp_tky_asakusa", NearestMetroStationName: "Asakusa Station (Exit 1)",
			NearestBusStopID: "jp_tky_bus_asakusa",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Temple", "Culture", "Historic", "Lantern"},
		},
		{
			ID: "tky_shibuya_scramble", CityID: "tokyo", Category: model.CategoryLandmark,
			Name: "渋谷スクランブル交差点", EnglishName: "Shibuya Scramble Crossing", LocalName: "渋谷交差点",
			Description: "The world's busiest pedestrian intersection where up to 3,000 people cross at each green light beneath dazzling electronic billboards.",
			Latitude: 35.6595, Longitude: 139.7005, Rating: 4.7, ReviewCount: 3870,
			Address: "2 Chome Dogenzaka, Shibuya City, Tokyo", OpeningHours: "Open 24 Hours",
			AdmissionFee: "Free", OfficialWebsite: "https://www.gotokyo.org", PhoneNumber: "N/A",
			AccessibilityInfo: "Flat paved surface with curb ramps and tactile paving.",
			BestTimeToVisit: "19:00 - 21:00 for peak neon atmosphere", EstimatedDurationMin: 45,
			NearestMetroStationID: "jp_tky_shibuya", NearestMetroStationName: "Shibuya Station (Hachiko Exit)",
			NearestBusStopID: "jp_tky_bus_shibuya",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1542051841857-5f90071e7989?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Iconic", "Cityscape", "Neon", "Photography"},
		},
	}

	// LONDON PLACES
	s.Places["london"] = []model.Place{
		{
			ID: "lon_big_ben", CityID: "london", Category: model.CategoryLandmark,
			Name: "Big Ben & Palace of Westminster", EnglishName: "Big Ben", LocalName: "Big Ben",
			Description: "The iconic Gothic clock tower and seat of the UK Parliament on the banks of the River Thames.",
			Latitude: 51.5007, Longitude: -0.1246, Rating: 4.8, ReviewCount: 5200,
			Address: "Westminster, London SW1A 0AA", OpeningHours: "Exterior 24 Hours; Tours require advance booking",
			AdmissionFee: "Free exterior viewing", OfficialWebsite: "https://www.parliament.uk", PhoneNumber: "+44-20-7219-4272",
			AccessibilityInfo: "Fully paved public walkways along Westminster Bridge with step-free dropped curbs.",
			BestTimeToVisit: "17:00 when the clock face glows amber in the twilight", EstimatedDurationMin: 60,
			NearestMetroStationID: "gb_lon_westminster", NearestMetroStationName: "Westminster Station",
			NearestBusStopID: "gb_lon_bus_westminster",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Landmark", "Heritage", "Thames", "History"},
		},
	}

	// PARIS PLACES
	s.Places["paris"] = []model.Place{
		{
			ID: "par_eiffel_tower", CityID: "paris", Category: model.CategoryLandmark,
			Name: "Tour Eiffel", EnglishName: "Eiffel Tower", LocalName: "La Tour Eiffel",
			Description: "Gustave Eiffel's 330m wrought-iron marvel erected in 1889, defining the Paris skyline.",
			Latitude: 48.8584, Longitude: 2.2945, Rating: 4.8, ReviewCount: 6100,
			Address: "Champ de Mars, 5 Av. Anatole France, 75007 Paris", OpeningHours: "09:30 - 23:45 daily",
			AdmissionFee: "€29.40 (Lift to top)", OfficialWebsite: "https://www.toureiffel.paris", PhoneNumber: "+33-8-92-70-12-39",
			AccessibilityInfo: "Floors 1 & 2 fully accessible via designated elevators with priority security lanes.",
			BestTimeToVisit: "Every hour on the hour after dusk for the 5-minute sparkle show", EstimatedDurationMin: 120,
			NearestMetroStationID: "fr_par_bir_hakeim", NearestMetroStationName: "Bir-Hakeim Station",
			NearestBusStopID: "fr_par_bus_eiffel",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Landmark", "Romantic", "Views", "Iconic"},
		},
		{
			ID: "par_louvre_museum", CityID: "paris", Category: model.CategoryMuseum,
			Name: "Musée du Louvre", EnglishName: "Louvre Museum", LocalName: "Musée du Louvre",
			Description: "The world's most visited art museum, preserving the Mona Lisa, Venus de Milo, and over 35,000 historic works.",
			Latitude: 48.8606, Longitude: 2.3376, Rating: 4.8, ReviewCount: 5800,
			Address: "Rue de Rivoli, 75001 Paris", OpeningHours: "09:00 - 18:00 (Closed Tuesdays, open until 21:45 Fridays)",
			AdmissionFee: "€22.00 (Timed reservation required)", OfficialWebsite: "https://www.louvre.fr", PhoneNumber: "+33-1-40-20-53-17",
			AccessibilityInfo: "Step-free glass pyramid elevator; dedicated PRM guides available at info desk.",
			BestTimeToVisit: "Wednesday or Friday evening for quieter gallery atmosphere", EstimatedDurationMin: 180,
			NearestMetroStationID: "fr_par_louvre_rivoli", NearestMetroStationName: "Louvre - Rivoli Station",
			NearestBusStopID: "fr_par_bus_louvre",
			PhotoURLs: []string{
				"https://images.unsplash.com/photo-1499856871958-5b9627545d1a?auto=format&fit=crop&w=800&q=80",
			},
			Tags: []string{"Art", "Museum", "MonaLisa", "Historic"},
		},
	}

	// AUTHENTIC VERIFIED REVIEWS
	s.Reviews["sel_gyeongbokgung"] = []model.Review{
		{
			ID: "rev_sel_01", PlaceID: "sel_gyeongbokgung", AuthorName: "Min-Ji K.", Rating: 5,
			Title: "한복 착용시 무료 입장과 수문장 교대의식 팁",
			Content: "경복궁역 5번 출구로 나오면 국립고궁박물관을 통해 궁궐 안마당으로 바로 진입할 수 있어 편리합니다. 오전 10시 수문장 교대의식은 놓치지 마세요. 인근 한복 대여점에서 한복을 빌려 입으면 별도 티켓 발권 없이 바로 무료 입장이 가능합니다.",
			VisitPeriod: "October 2026", TravelType: "Solo", VisitTip: "오전 9시 30분에 도착해 근정전 사진을 먼저 찍고 10시 교대의식을 관람하세요.",
			HelpfulCount: 42, VerifiedVisit: true, Language: "ko", CreatedAt: now.Add(-3 * 24 * time.Hour),
		},
		{
			ID: "rev_sel_02", PlaceID: "sel_gyeongbokgung", AuthorName: "Marcus Vance", Rating: 5,
			Title: "Flawless transit access and jaw-dropping history",
			Content: "Coming directly from Incheon Airport on the AREX to Seoul Station, then just a quick subway hop to Gyeongbokgung Station Exit 5. The palace courtyard with the mountain backdrop is unforgettable.",
			VisitPeriod: "October 2026", TravelType: "Couple", VisitTip: "Download offline maps in advance; although subway English signage is fantastic!",
			HelpfulCount: 29, VerifiedVisit: true, Language: "en", CreatedAt: now.Add(-5 * 24 * time.Hour),
		},
	}

	s.Reviews["tky_sensoji"] = []model.Review{
		{
			ID: "rev_tky_01", PlaceID: "tky_sensoji", AuthorName: "Kenichi Sato", Rating: 5,
			Title: "銀座線浅草駅1番出口からの最短ルート",
			Content: "銀座線の浅草駅1番出口を出ると目の前に雷門が見えます。仲見世通りは昼過ぎになると大変混雑するので、朝8時半頃の参拝が一番落ち着いていておすすめです。",
			VisitPeriod: "October 2026", TravelType: "Solo", VisitTip: "おみくじを引く際は小銭を用意しておくとスムーズです。",
			HelpfulCount: 35, VerifiedVisit: true, Language: "ja", CreatedAt: now.Add(-2 * 24 * time.Hour),
		},
	}
}

func (s *SeedStore) initInitialWeather() {
	now := time.Now()

	s.WeatherReports["seoul"] = model.WeatherReport{
		CityID: "seoul", CityName: "Seoul", Latitude: 37.5665, Longitude: 126.9780,
		CurrentTempC: 17.5, FeelsLikeC: 17.0, Condition: "Clear", ConditionKorean: "맑음",
		Humidity: 52, WindSpeedKmH: 8.5, UVIndex: 4, PrecipProb: 5, AirQualityIndex: "Good (32)",
		Sunrise: "06:48", Sunset: "17:42", Attribution: "Weather data by Open-Meteo.com", ObservedAt: now,
		Hourly: []model.HourlyForecast{
			{Hour: "12:00", TempC: 18.0, Condition: "Clear", PrecipProb: 0, Icon: "sunny"},
			{Hour: "15:00", TempC: 19.5, Condition: "Clear", PrecipProb: 0, Icon: "sunny"},
			{Hour: "18:00", TempC: 16.0, Condition: "Partly Cloudy", PrecipProb: 10, Icon: "partly_cloudy"},
			{Hour: "21:00", TempC: 13.5, Condition: "Clear", PrecipProb: 5, Icon: "clear_night"},
		},
		Daily: []model.DailyForecast{
			{Date: "2026-10-25", DayOfWeek: "Sun", TempMinC: 9.0, TempMaxC: 19.5, Condition: "Clear", PrecipProb: 5, Icon: "sunny"},
			{Date: "2026-10-26", DayOfWeek: "Mon", TempMinC: 10.5, TempMaxC: 20.0, Condition: "Clear", PrecipProb: 10, Icon: "sunny"},
			{Date: "2026-10-27", DayOfWeek: "Tue", TempMinC: 11.0, TempMaxC: 18.5, Condition: "Rain", PrecipProb: 65, Icon: "rainy"},
			{Date: "2026-10-28", DayOfWeek: "Wed", TempMinC: 8.5, TempMaxC: 16.0, Condition: "Partly Cloudy", PrecipProb: 15, Icon: "partly_cloudy"},
		},
	}

	s.WeatherReports["tokyo"] = model.WeatherReport{
		CityID: "tokyo", CityName: "Tokyo", Latitude: 35.6762, Longitude: 139.6503,
		CurrentTempC: 19.0, FeelsLikeC: 18.8, Condition: "Partly Cloudy", ConditionKorean: "구름 조금",
		Humidity: 58, WindSpeedKmH: 11.2, UVIndex: 5, PrecipProb: 10, AirQualityIndex: "Good (24)",
		Sunrise: "05:56", Sunset: "16:54", Attribution: "Weather data by Open-Meteo.com", ObservedAt: now,
		Hourly: []model.HourlyForecast{
			{Hour: "12:00", TempC: 20.0, Condition: "Partly Cloudy", PrecipProb: 10, Icon: "partly_cloudy"},
			{Hour: "15:00", TempC: 21.0, Condition: "Clear", PrecipProb: 5, Icon: "sunny"},
			{Hour: "18:00", TempC: 18.0, Condition: "Clear", PrecipProb: 5, Icon: "clear_night"},
			{Hour: "21:00", TempC: 16.5, Condition: "Clear", PrecipProb: 0, Icon: "clear_night"},
		},
		Daily: []model.DailyForecast{
			{Date: "2026-10-25", DayOfWeek: "Sun", TempMinC: 14.0, TempMaxC: 21.5, Condition: "Clear", PrecipProb: 5, Icon: "sunny"},
			{Date: "2026-10-26", DayOfWeek: "Mon", TempMinC: 15.0, TempMaxC: 22.0, Condition: "Partly Cloudy", PrecipProb: 20, Icon: "partly_cloudy"},
		},
	}

	s.WeatherReports["london"] = model.WeatherReport{
		CityID: "london", CityName: "London", Latitude: 51.5074, Longitude: -0.1278,
		CurrentTempC: 13.0, FeelsLikeC: 12.2, Condition: "Overcast", ConditionKorean: "흐림",
		Humidity: 74, WindSpeedKmH: 14.0, UVIndex: 2, PrecipProb: 25, AirQualityIndex: "Moderate (45)",
		Sunrise: "07:44", Sunset: "17:48", Attribution: "Weather data by Open-Meteo.com", ObservedAt: now,
	}

	s.WeatherReports["paris"] = model.WeatherReport{
		CityID: "paris", CityName: "Paris", Latitude: 48.8566, Longitude: 2.3522,
		CurrentTempC: 14.5, FeelsLikeC: 13.8, Condition: "Partly Cloudy", ConditionKorean: "구름 조금",
		Humidity: 68, WindSpeedKmH: 9.8, UVIndex: 3, PrecipProb: 15, AirQualityIndex: "Good (35)",
		Sunrise: "08:24", Sunset: "18:42", Attribution: "Weather data by Open-Meteo.com", ObservedAt: now,
	}

	s.WeatherReports["newyork"] = model.WeatherReport{
		CityID: "newyork", CityName: "New York", Latitude: 40.7128, Longitude: -74.0060,
		CurrentTempC: 15.0, FeelsLikeC: 14.2, Condition: "Clear", ConditionKorean: "맑음",
		Humidity: 48, WindSpeedKmH: 12.5, UVIndex: 4, PrecipProb: 0, AirQualityIndex: "Good (28)",
		Sunrise: "07:15", Sunset: "18:05", Attribution: "Weather data by Open-Meteo.com", ObservedAt: now,
	}
}

func (s *SeedStore) initInitialTrips() {
	now := time.Now()

	s.Trips["trip_sample_seoul"] = model.Trip{
		ID: "trip_sample_seoul", Title: "Autumn in Seoul 4-Day Journey",
		CountryCode: "KR", CityID: "seoul", CityName: "Seoul",
		StartDate: "2026-10-26", EndDate: "2026-10-29",
		Collaborators: []string{"dev@bookingnetwork.internal"},
		CreatedAt:     now.Add(-48 * time.Hour),
		UpdatedAt:     now.Add(-2 * time.Hour),
		Days: []model.TripDay{
			{
				DayNumber: 1, DateStr: "2026-10-26", CityID: "seoul", CityName: "Seoul",
				WeatherNote: "Clear & Crisp (10°C - 20°C)",
				Items: []model.ItineraryItem{
					{
						ID: "item_01", PlaceID: "sel_gyeongbokgung", Title: "Gyeongbokgung Palace", Subtitle: "Royal Changing of Guard",
						Category: "Historic & Culture", Order: 1, TimeScheduled: "10:00",
						Latitude: 37.5796, Longitude: 126.9770, DurationMin: 120, Notes: "Hanbok rental booked across exit 5", IsCompleted: false,
					},
					{
						ID: "item_02", PlaceID: "sel_bukchon", Title: "Bukchon Hanok Village", Subtitle: "Stroll along traditional alleys",
						Category: "Historic & Culture", Order: 2, TimeScheduled: "13:30",
						Latitude: 37.5826, Longitude: 126.9837, DurationMin: 90, Notes: "Respect quiet hours", IsCompleted: false,
					},
					{
						ID: "item_03", PlaceID: "sel_n_seoul_tower", Title: "N Seoul Tower", Subtitle: "Sunset over Seoul Skyline",
						Category: "Night View", Order: 3, TimeScheduled: "17:30",
						Latitude: 37.5512, Longitude: 126.9882, DurationMin: 90, Notes: "Take Namsan Cable Car from Myeongdong", IsCompleted: false,
					},
				},
			},
			{
				DayNumber: 2, DateStr: "2026-10-27", CityID: "seoul", CityName: "Seoul",
				WeatherNote: "Rain expected afternoon (11°C - 18°C)",
				Items: []model.ItineraryItem{
					{
						ID: "item_04", PlaceID: "sel_ddp", Title: "Dongdaemun Design Plaza", Subtitle: "Exhibitions & Zaha Hadid Architecture",
						Category: "Landmark", Order: 1, TimeScheduled: "14:00",
						Latitude: 37.5665, Longitude: 127.0092, DurationMin: 100, Notes: "Indoor venue safe from rain", IsCompleted: false,
					},
				},
			},
		},
	}
}

func (s *SeedStore) initOfflinePackages() {
	now := time.Now()
	s.OfflinePackages = []model.OfflinePackage{
		{CityID: "seoul", CityName: "Seoul", Version: "2026.10.1", SizeBytes: 15420000, SizeMB: 14.7, Contents: []string{"Metro Lines 1-9 & AREX", "Major Bus Routes", "120 Attractions", "Offline Schematic Map"}, LastUpdated: now.Add(-24 * time.Hour), Attribution: "Seoul TOPIS / Korail"},
		{CityID: "tokyo", CityName: "Tokyo", Version: "2026.10.1", SizeBytes: 18200000, SizeMB: 17.3, Contents: []string{"Tokyo Metro & Toei Subways", "JR Yamanote Line", "140 Attractions", "Offline Schematic Map"}, LastUpdated: now.Add(-24 * time.Hour), Attribution: "ODPT / Toei / JR"},
		{CityID: "london", CityName: "London", Version: "2026.10.1", SizeBytes: 16100000, SizeMB: 15.3, Contents: []string{"London Underground (All lines)", "Central Bus Corridors", "110 Landmarks", "Tube Map"}, LastUpdated: now.Add(-24 * time.Hour), Attribution: "TfL Open Data"},
		{CityID: "paris", CityName: "Paris", Version: "2026.10.1", SizeBytes: 14800000, SizeMB: 14.1, Contents: []string{"RATP Métro Lines 1-14", "RER A/B", "95 Monuments", "Offline Métro Map"}, LastUpdated: now.Add(-24 * time.Hour), Attribution: "Île-de-France Mobilités"},
		{CityID: "newyork", CityName: "New York", Version: "2026.10.1", SizeBytes: 19500000, SizeMB: 18.6, Contents: []string{"MTA Subway (Full System)", "Manhattan Bus Network", "130 Landmarks", "Subway Map"}, LastUpdated: now.Add(-24 * time.Hour), Attribution: "MTA Open Data"},
	}
}

