package service

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"

	"github.com/bookingnetwork/global-travel-app/backend/internal/model"
)

type offlineCityData struct {
	SchemaVersion int `json:"schema_version"`
	Source string `json:"source"`
	City model.City `json:"city"`
	Coverage model.CoverageRegistry `json:"coverage"`
	MetroLines []model.MetroLine `json:"metro_lines"`
	MetroStations []model.MetroStation `json:"metro_stations"`
	BusRoutes []model.BusRoute `json:"bus_routes"`
	BusStops []model.BusStop `json:"bus_stops"`
	Places []model.Place `json:"places"`
	Weather *model.WeatherReport `json:"weather,omitempty"`
}

func (s *ServiceContainer) OfflineCityData(cityID string) ([]byte, string, error) {
	city, err := s.GetCity(cityID)
	if err != nil { return nil, "", fmt.Errorf("%w: city", ErrNotFound) }
	s.mu.RLock()
	defer s.mu.RUnlock()
	data := offlineCityData{
		SchemaVersion:1, Source:"sample", City:*city, Coverage:s.Store.Coverage[cityID],
		MetroLines:append([]model.MetroLine{},s.Store.MetroLines[cityID]...),
		MetroStations:append([]model.MetroStation{},s.Store.MetroStations[cityID]...),
		BusRoutes:append([]model.BusRoute{},s.Store.BusRoutes[cityID]...),
		BusStops:append([]model.BusStop{},s.Store.BusStops[cityID]...),
		Places:append([]model.Place{},s.Store.Places[cityID]...),
	}
	if weather, ok := s.Store.WeatherReports[cityID]; ok { data.Weather=&weather }
	body,err := json.Marshal(data)
	if err != nil { return nil,"",err }
	digest := sha256.Sum256(body)
	return body,fmt.Sprintf("%x",digest),nil
}

func (s *ServiceContainer) ListOfflinePackages() []model.OfflinePackage {
	packages := []model.OfflinePackage{}
	for _,city := range s.Store.Cities {
		body,checksum,err := s.OfflineCityData(city.ID)
		if err != nil { continue }
		packages=append(packages,model.OfflinePackage{
			CityID:city.ID,CityName:city.Name,Version:checksum[:16],SizeBytes:int64(len(body)),SizeMB:float64(len(body))/(1024*1024),
			Contents:[]string{"Metro lines and stations","Bus routes and stops","Places","Cached weather"},
			Attribution:"Sample transit and places; cached forecasts retain their observation time. Maps require a network connection.",
			SHA256:checksum,DownloadURL:"/api/v1/offline/packages/"+city.ID,
		})
	}
	return packages
}
