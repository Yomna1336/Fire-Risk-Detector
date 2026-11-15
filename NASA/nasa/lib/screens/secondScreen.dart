// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:latlong2/latlong.dart';
import 'package:nasa/screens/myWidget.dart';
import 'package:nasa/screens/pulsingMarker.dart';
import 'package:nasa/theFireMap/fireModel.dart';
import 'package:nasa/theFireMap/harmonization.dart';
import 'package:nasa/theFireMap/service.dart';

class Secondscreen extends StatefulWidget {
  final bool isActive;
  const Secondscreen({super.key, required this.isActive});

  @override
  State<Secondscreen> createState() => _SecondscreenState();
}

class _SecondscreenState extends State<Secondscreen> {
  String formatFireTime(String rowtime) {
    if (rowtime.length >= 4) {
      String hours = rowtime.substring(0, 2);
      String minutes = rowtime.substring(2, 4);
      return "$hours:$minutes";
    }
    return rowtime;
  }

  String currentSource = "VIIRS_NOAA21_NRT";

  List<HarmonizedFireMarker> harmoniedMarkers = [];
  bool isHarmonizedLoading = false;
  bool shouldFetchData = false;
  bool isHarmonizedSelected = false;

  void loadHarmonizedFiresData() async {
    setState(() {
      isHarmonizedLoading = true;
      isHarmonizedSelected = true;
    });

    List<HarmonizedFireMarker> fetchedResult =
        await Harmonization.fetchHarmonizedFires();
    print("{fetchedResult.length}");

    setState(() {
      harmoniedMarkers = fetchedResult;
      isHarmonizedLoading = false;
      isHarmonizedSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child:  SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LIVE FIRE MAP",
                style: TextStyle(
                  color: const Color.fromARGB(255, 10, 115, 164),
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Global Fire Detection Map",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Explore real-time fire hotspots detected by VIIRS and MODIS satellites.",
                style: TextStyle(
                  color: const Color.fromARGB(255, 10, 115, 164),
                  fontWeight: FontWeight.normal,
                ),
              ),
              Gap(10),
          
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentSource = "VIIRS_NOAA21_NRT";
                        shouldFetchData = true;
                      });
                    },
                    child: Text(
                      "VIIRS_NOAA21",
                      style: TextStyle(
                        fontSize: 15,
                        color: currentSource == "VIIRS_NOAA21_NRT"
                            ? const Color.fromARGB(255, 10, 115, 164)
                            : Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentSource = "VIIRS_NOAA20_NRT";
                        shouldFetchData = true;
                      });
                    },
                    child: Text(
                      "VIIRS_NOAA20",
                      style: TextStyle(
                        fontSize: 15,
                        color: currentSource == "VIIRS_NOAA20_NRT"
                            ? const Color.fromARGB(255, 10, 115, 164)
                            : Colors.white,
                      ),
                    ),
                  ),
          
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentSource = "MODIS_NRT";
                        shouldFetchData = true;
                      });
                    },
                    child: Text(
                      "MODIS",
                      style: TextStyle(
                        fontSize: 15,
                        color: currentSource == "MODIS_NRT"
                            ? const Color.fromARGB(255, 10, 115, 164)
                            : Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
          context,
          MaterialPageRoute(builder: (c) =>  HarmonizationMap()),
                  );
                    },
                    child: Text(
                      "Harmonization",
                      style: TextStyle(
                        fontSize: 15,
                        color: isHarmonizedSelected
                            ? const Color.fromARGB(255, 10, 115, 164)
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          
              Gap(10),
          
              FutureBuilder<List<FireMarker>>(
                future: Service.fetchFireData(currentSource),
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
                                  Text('Time: ${formatFireTime(fire.time)}'),
                                  Text('Brightness: ${fire.brightness}'),
                                  Text('Confidence: ${fire.confidence}'),
                                  Text('version: ${fire.version}'),
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
          
                  return  SizedBox(
                    height: 650,
                    width: double.infinity,
                    child: Expanded(
                      child:  FlutterMap(
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
            ],
          ),
        ),
      ),
    );
  }
}
