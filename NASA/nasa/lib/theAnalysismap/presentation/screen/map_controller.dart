// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nasa/histrotical/model.dart';
import 'package:nasa/histrotical/theservice.dart';
import 'package:nasa/theAnalysismap/presentation/widgets/map_layers.dart';

 class AppMapController extends ChangeNotifier {

final HistoricalServer _historicalServer = HistoricalServer();

HistoricalResponse? historicalData;
bool isLoadingHistorical = false;
String? historicalError;

  final Set<MapLayers> _activeLayers = {};
  LatLng? selectedLocation;

  void The_selectedLocation(LatLng location) {
     selectedLocation = location;
    notifyListeners();
  }

  bool isLayerActive(MapLayers layer) {
    return _activeLayers.contains(layer);
  }

  void toggleLayer(MapLayers layer) {
    if (_activeLayers.contains(layer)) {
      _activeLayers.remove(layer);
    } else {
      _activeLayers.add(layer);
    }
    notifyListeners();
  }

  Future<void> loadHistoricalInformation() async {
  if (selectedLocation == null) {
    historicalError = 'Please select a location on the map';
    notifyListeners();
    return;
  }

  isLoadingHistorical = true;
  historicalError = null;
  notifyListeners();

  try {
    historicalData =
        await _historicalServer.fetchHistoricalInformation(
      latitude: selectedLocation!.latitude,
      longitude: selectedLocation!.longitude,
    );
  } catch (e) {
    historicalError = e.toString();
  } finally {
    isLoadingHistorical = false;
    notifyListeners();
  }
}

  
}