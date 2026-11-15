 import 'package:flutter/material.dart';
import 'package:nasa/theAnalysismap/presentation/screen/map_controller.dart';

class Sidebar extends StatelessWidget {
  final AppMapController controller;

  const Sidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final location = controller.selectedLocation;

        if (location == null) {
          return const Center(
            child: Text("Select a location on the Map"),
          );
        }

        final data = controller.historicalData;
        final statistics = data?.statistics ?? {};
        final satelliteStats =
            statistics['satellite_statistics'] ?? {};

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selected Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Latitude: ${location.latitude.toStringAsFixed(4)}",
              ),

              Text(
                "Longitude: ${location.longitude.toStringAsFixed(4)}",
              ),

              const Divider(height: 30),

              const Text(
                "Historical Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (controller.isLoadingHistorical)
                const Center(
                  child: CircularProgressIndicator(),
                )

              else if (controller.historicalError != null)
                Text(
                  "Error: ${controller.historicalError}",
                  style: const TextStyle(color: Colors.red),
                )

              else if (data == null)
                const Text("Press Historical Information to load data.")

              else ...[
                Text(
                  "Search Radius: ${data.radiusKm} km",
                ),

                Text(
                  "Period: Last ${data.daysBack} days",
                ),

                const SizedBox(height: 12),

                Text(
                  "Total Detections: ${statistics['total_detections'] ?? 0}",
                ),

                const SizedBox(height: 8),

                Text(
                  "Estimated Unique Fires: ${data.uniqueFireCount}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const Divider(height: 25),

                const Text(
                  "Satellite Statistics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "MODIS: ${satelliteStats['MODIS'] ?? 0}",
                ),

                Text(
                  "VIIRS: ${satelliteStats['VIIRS'] ?? 0}",
                ),

                const SizedBox(height: 15),

                const Text(
                  "Historical Fires",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                if (data.uniqueFires.isEmpty)
                  const Text("No historical fires found in this area.")

                else
...data.uniqueFires.map(
                    (fire) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fire #${fire.uniqueFireId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Latitude: ${fire.latitude}",
                            ),

                            Text(
                              "Longitude: ${fire.longitude}",
                            ),

                            Text(
                              "Detections: ${fire.detectionsCount}",
                            ),

                            Text(
                              "Max FRP: ${fire.maxFrp}",
                            ),

                            Text(
                              "First Seen: ${fire.firstSeen}",
                            ),

                            Text(
                              "Last Seen: ${fire.lastSeen}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}