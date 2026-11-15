import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nasa/histrotical/thelayer.dart';
import 'package:nasa/theAnalysismap/presentation/screen/map_controller.dart';
import 'package:nasa/theAnalysismap/presentation/widgets/map_layers.dart';

class TheAnalysisMap extends StatefulWidget {
  final AppMapController controller;
  TheAnalysisMap({super.key, required this.controller});

  @override
  State<TheAnalysisMap> createState() => _TheAnalysisMapState();
}

class _TheAnalysisMapState extends State<TheAnalysisMap> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(26.8206, 30.8025),
            initialZoom: 5.5,
            minZoom: 3,
            maxZoom: 18,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (tapPosition, point) {
              widget.controller.The_selectedLocation(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: "com.example.fire_detection",
            ),
            MarkerLayer(
              markers: [
                if (widget.controller.selectedLocation != null)
                  Marker(
                    point: widget.controller.selectedLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_pin,
                      color: const Color.fromARGB(255, 10, 115, 164),
                      size: 30,
                    ),
                  ),
              ],
            ),
        
            if (widget.controller.isLayerActive(
              MapLayers.historitcal_information,
            ))
              HistoricalLayer(
                fires: widget.controller.historicalData?.uniqueFires ?? [],
                onFireTap: (fire) {
                },
              ),
          ],
        );
      },
    );
  }
}
