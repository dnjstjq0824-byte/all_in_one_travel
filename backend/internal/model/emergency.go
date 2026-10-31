package model

type EmbassyContact struct {
	Country     string `json:"country"`
	Name        string `json:"name"`
	PhoneNumber string `json:"phone_number"`
	Address     string `json:"address"`
}

type HospitalInfo struct {
	Name             string `json:"name"`
	EnglishSpeaking  bool   `json:"english_speaking"`
	Emergency24Hours bool   `json:"emergency_24h"`
	PhoneNumber      string `json:"phone_number"`
	Address          string `json:"address"`
}

type EmergencyInfo struct {
	CityID           string           `json:"city_id"`
	CountryCode      string           `json:"country_code"`
	Police           string           `json:"police"`
	Ambulance        string           `json:"ambulance"`
	Fire             string           `json:"fire"`
	GeneralEmergency string           `json:"general_emergency,omitempty"`
	Embassies        []EmbassyContact `json:"embassies,omitempty"`
	Hospitals        []HospitalInfo   `json:"hospitals,omitempty"`
}

