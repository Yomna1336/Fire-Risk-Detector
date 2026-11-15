import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'model.dart';

class HistoricalLayer extends StatelessWidget {
  final List<HistoricalFire> fires;
  final ValueChanged<HistoricalFire>? onFireTap;

  const HistoricalLayer({
    super.key,
    required this.fires,
    this.onFireTap,
  });

  @override
  Widget build(BuildContext context) {
    if (fires.isEmpty) {
      return const SizedBox.shrink();
    }

    return MarkerLayer(
      markers: fires.map((fire) {
        return Marker(
          point: LatLng(
            fire.latitude,
            fire.longitude,
          ),
          width: 45,
          height: 45,
          child: GestureDetector(
            onTap: () {
              onFireTap?.call(fire);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}