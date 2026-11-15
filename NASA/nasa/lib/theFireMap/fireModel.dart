class FireMarker {
  final double latitude;
  final double longitude;
  final double brightness;
  final String acqDate;
  final String time;
  final String confidence;
  final String version;
 

  FireMarker({
    required this.latitude,
    required this.longitude,
    required this.brightness,
    required this.acqDate,
    required this.time,
    required this.confidence,
    required this.version
  });

  factory FireMarker.fromJson(Map<String, dynamic> jsonData) {
    return FireMarker(
      latitude: (jsonData['latitude'] as num).toDouble(),
      longitude: (jsonData['longitude'] as num).toDouble(),
      brightness: (jsonData['brightness'] as num).toDouble(),
      acqDate: jsonData['acq_date'].toString(),
      time: jsonData['acq_time'].toString(),
      confidence: jsonData['confidence'].toDouble(),
      version:jsonData['version'].toString(),
    );
  }
}
