// Finance and Emergency Domain Models

class EmergencyContact {
  final String police;
  final String ambulance;
  final String fire;
  final String touristPolice;
  final String embassyPhone;
  final String hospitalEnglish;

  EmergencyContact({
    required this.police,
    required this.ambulance,
    required this.fire,
    required this.touristPolice,
    required this.embassyPhone,
    required this.hospitalEnglish,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      police: json['police'] ?? '',
      ambulance: json['ambulance'] ?? '',
      fire: json['fire'] ?? '',
      touristPolice: json['tourist_police'] ?? '',
      embassyPhone: json['embassy_phone'] ?? '',
      hospitalEnglish: json['hospital_english'] ?? '',
    );
  }
}

class ExchangeRateResponse {
  final String baseCurrency;
  final Map<String, double> rates;
  final String lastUpdated;

  ExchangeRateResponse({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      baseCurrency: json['base_currency'] ?? 'USD',
      rates:
          (json['rates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}

