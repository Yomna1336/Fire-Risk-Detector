 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:nasa/screens/myWidget.dart';
import 'package:nasa/screens/pulsingMarker.dart';

class HarmonizedFireMarker {
  final double latitude;
  final double longitude;
  final String source;
  final double frp;
  final String confidence;
  final String acqDate;
  final String acqTime;

  HarmonizedFireMarker({
    required this.latitude,
    required this.longitude,
    required this.source,
    required this.frp,
    required this.confidence,
    required this.acqDate,
    required this.acqTime,
  });
}

class Harmonization {
  static Future<List<HarmonizedFireMarker>> fetchHarmonizedFires() async {
    final String apiKey = "40a9607b54bf31d3bc29f9821ccf580d"; 
    final String bbox = "25.0,22.0,36.0,32.0";

    final url = Uri.parse(
      'http://127.0.0.1:8000/api/harmonized-fires?map_key=$apiKey&bbox=$bbox',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final List fires = decodedData['data'];

        print("تم استلام ${fires.length} نقطة حريق دمج بنجاح");

        return fires.map((fire) {
          return HarmonizedFireMarker(
            latitude: double.parse(fire['latitude'].toString()),
            longitude: double.parse(fire['longitude'].toString()),
            source: fire['source']?.toString() ?? '',
            frp: fire['frp'] != null ? double.parse(fire['frp'].toString()) : 0.0,
            confidence: fire['confidence']?.toString() ?? '',
            acqDate: fire['acq_date']?.toString() ?? '',
            acqTime: fire['acq_time']?.toString() ?? '',
          );
        }).toList();
      } else {
        print("فشل الاتصال بالخادم");
        return [];
      }
    } catch (e) {
      print("خطأ: $e");
      return [];
    }
  }
}

 class  HarmonizationMap extends StatefulWidget {
  const  HarmonizationMap({super.key});

  @override
  State< HarmonizationMap> createState() => _HarmonizationMapState();
}

class _HarmonizationMapState extends State< HarmonizationMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
          FutureBuilder<List<HarmonizedFireMarker>>(
                future: Harmonization.fetchHarmonizedFires(),
                builder: (context, TheData) {
                  if (TheData.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (TheData.hasError) {
                    return Center(
                      child: Text("An Error Occurred: ${TheData.error}"),
                    );
                  } else if (!TheData.hasData || TheData.data!.isEmpty) {
                    return Center(child: Text("No Fire Data Recorded"));
                  }

                  final fireData = TheData.data!;

                  //  hena ta7weel el APIs
                  List<Marker> markers = fireData.map((fire) {
                    return Marker(
                      point: LatLng(fire.latitude, fire.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('The Fire Details'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${fire.acqDate}'),
                                  Text('Time: ${(fire.acqTime)}'),
                                  Text('FRP: ${fire.frp}'),
                                  Text('Confidence: ${fire.confidence}'),
                                  Text('Source: ${fire.source}'),
                                  Text('Logitude: ${fire.longitude}'),
                                  Text('Latitude: ${fire.latitude}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: mytext(
                                    text: "Close",
                                    fontsize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Pulsingmarker(),
                      ),
                    );
                  }).toList();

                  return SizedBox(
                    height: 650,
                    width: double.infinity,
                    child: Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            fireData.first.latitude,
                            fireData.first.longitude,
                          ),
                          initialZoom: 3,
                          maxZoom: 18,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.nasa',
                          ),

                          MarkerLayer(markers: markers),
                          
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],),
    );
  }
}
