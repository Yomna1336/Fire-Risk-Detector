 class HistoricalResponse {
  final Map<String, dynamic> center;
  final double radiusKm;
  final int daysBack;
  final Map<String, dynamic> statistics;
  final int uniqueFireCount;
  final List<HistoricalFire> uniqueFires;
  final List<HistoricalDetection> detections;

  HistoricalResponse({
    required this.center,
    required this.radiusKm,
    required this.daysBack,
    required this.statistics,
    required this.uniqueFireCount,
    required this.uniqueFires,
    required this.detections,
  });

  factory HistoricalResponse.fromJson(
      Map<String, dynamic> json) {
    return HistoricalResponse(
      center: json['center'] ?? {},
      radiusKm: (json['radius_km'] ?? 0).toDouble(),
      daysBack: json['days_back'] ?? 0,
      statistics: json['statistics'] ?? {},
      uniqueFireCount: json['unique_fire_count'] ?? 0,
      uniqueFires: (json['unique_fires'] as List? ?? [])
          .map((e) => HistoricalFire.fromJson(e))
          .toList(),
      detections: (json['detections'] as List? ?? [])
          .map((e) => HistoricalDetection.fromJson(e))
          .toList(),
    );
  }
}

class HistoricalFire {
  final int uniqueFireId;
  final double latitude;
  final double longitude;
  final String firstSeen;
  final String lastSeen;
  final int detectionsCount;
  final double maxFrp;

  HistoricalFire({
    required this.uniqueFireId,
    required this.latitude,
    required this.longitude,
    required this.firstSeen,
    required this.lastSeen,
    required this.detectionsCount,
    required this.maxFrp,
  });

  factory HistoricalFire.fromJson(Map<String, dynamic> json) {
    return HistoricalFire(
      uniqueFireId: json['unique_fire_id'] ?? 0,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      firstSeen: json['first_seen'] ?? '',
      lastSeen: json['last_seen'] ?? '',
      detectionsCount: json['detections_count'] ?? 0,
      maxFrp: (json['max_frp'] ?? 0).toDouble(),
    );
  }
}

class HistoricalDetection {
  final double latitude;
  final double longitude;
  final double frp;
  final String source;
  final String acqDate;
  final String acqTime;

  HistoricalDetection({
    required this.latitude,
    required this.longitude,
    required this.frp,
    required this.source,
    required this.acqDate,
    required this.acqTime,
  });

  factory HistoricalDetection.fromJson(
      Map<String, dynamic> json) {
    return HistoricalDetection(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      frp: (json['frp'] ?? 0).toDouble(),
      source: json['source'] ?? '',
      acqDate: json['acq_date'] ?? '',
      acqTime: json['acq_time'] ?? '',
    );
  }
}