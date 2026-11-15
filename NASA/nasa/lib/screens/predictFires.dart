import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class  Predictfires extends StatefulWidget {
  const  Predictfires({super.key});

  @override
  State<Predictfires> createState() => _PredictfiresState();
}

class _PredictfiresState extends State<Predictfires> {
  String fireResult = "Select your current location or a city for fire forecasting.";
  bool isLoading = false;
  final TextEditingController _cityController = TextEditingController();

  Future<void> sendDataToPython({Map<String, dynamic>? bodyData}) async {
    setState(() {
      isLoading = true;
      fireResult = "Data retrieval and analysis via artificial intelligence are underway......";
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/predict'); 
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          setState(() {
            fireResult = "Error: ${data['error']}";
            isLoading = false;
          });
          return;
        }

        int isFireProne = data['is_fire_prone'];
        double riskProbability = data['risk_probability'];

        setState(() {
          if (isFireProne == 1) {
            fireResult = "LEVEL OF RISK : HIGH LEVEL OF RISK ${(riskProbability * 100).toStringAsFixed(1)}%";
          } else {
            fireResult = "LEVEL OF RISK : THE AREA IS RELATIVELY SAFE  ${(riskProbability * 100).toStringAsFixed(1)}%";
          }
          isLoading = false;
        });
      } else {
        setState(() {
          fireResult = "Failed to connect to the server";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        fireResult = "Error: $e";
        isLoading = false;
      });
    }
  }

  
  Future<void> checkByGPS() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await sendDataToPython(bodyData: {
      "latitude": position.latitude,
      "longitude": position.longitude,
    });
  }

  
  Future<void> checkByCity() async {
    String cityName = _cityController.text.trim();
    if (cityName.isEmpty) return;

    await sendDataToPython(bodyData: {
      "city": cityName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("The Firs Risks Prediction" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 25))),
      body: 
         Center(
           child: Padding(
            padding:  EdgeInsets.only(left:12 ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fireResult,
                  textAlign: TextAlign.center,
                  style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Gap(20 ),
                
                  
                    Padding(
                      padding: EdgeInsets.all(50),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextField(
                          
                          controller: _cityController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Enter The City Name",
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.location_on, color: const Color.fromARGB(255, 10, 115, 164),),
                          ),
                        ),
                      ),
                    ),
                    Gap( 15),
                       isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          
                          ElevatedButton.icon(
                            onPressed: checkByCity,
                            icon:  Icon(Icons.search),
                            label:  Text("Predict This City"),
                          ),
                           Gap(25),
                          
                          
                          OutlinedButton.icon(
                            onPressed: checkByGPS,
                            icon: const Icon(Icons.my_location),
                            label: const Text("Predict My Location"),
                          ),
                  ],
                ),
        
                        
                      
              ],
            ),
                   ),
         ),
      
    );
  }
}