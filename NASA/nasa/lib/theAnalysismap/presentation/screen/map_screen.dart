import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nasa/theAnalysismap/presentation/screen/map_controller.dart';
import 'package:nasa/theAnalysismap/presentation/screen/sideBar.dart';
import 'package:nasa/theAnalysismap/presentation/widgets/container.dart';
import 'package:nasa/theAnalysismap/presentation/widgets/map_layers.dart';
import 'package:nasa/theAnalysismap/presentation/widgets/the_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late AppMapController controller;
  @override
  void initState() {
    super.initState();
    controller = AppMapController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:  SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The Environmental Monitoring And Analysis Map",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(20),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return Row(
                           
                          children: [
                            ContainerBar(
                              text: "Weather",
                              onTap: () {
                                controller.toggleLayer(MapLayers.weather);
                              },
                              isActive: controller.isLayerActive(
                                MapLayers.weather,
                              ),
                            ),
                            Gap( 10),
                            ContainerBar(
                              text: "NDVI",
                              onTap: () {
                                controller.toggleLayer(MapLayers.ndvi);
                              },
                              isActive: controller.isLayerActive(
                                MapLayers.ndvi,
                              ),
                            ),
Gap( 10),
                            ContainerBar(
                              text: "Terrain",
                              onTap: () {
                                controller.toggleLayer(MapLayers.terrain);
                              },
                              isActive: controller.isLayerActive(
                                MapLayers.terrain,
                              ),
                            ),
Gap( 10),
                            ContainerBar(
                              text: "Population",
                              onTap: () {
                                controller.toggleLayer(MapLayers.population);
                              },
                              isActive: controller.isLayerActive(
                                MapLayers.population,
                              ),
                            ),
            Gap( 10),
                            ContainerBar(
                              text: "Historitcal Information",
                              onTap: () async {
                                controller.toggleLayer(
                                  MapLayers.historitcal_information,
                                );
            
                                if (controller.isLayerActive(
                                  MapLayers.historitcal_information,
                                )) {
                                  await controller.loadHistoricalInformation();
                                }
                              },
                              isActive: controller.isLayerActive(
                                MapLayers.historitcal_information,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Gap( 12),
                 SizedBox(
                  height: 600,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Expanded(child: TheAnalysisMap(controller: controller)),
                      Gap(15),
                      Container(
                        width: 200,
                        child: Sidebar(controller: controller),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
