import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:nasa/theFireMap/fireModel.dart';
 
class Service {
  static const String apiKey = "put your Nasa key ";
  static Future<List<FireMarker>> fetchFireData(String Source) async {
    final url = Uri.parse(
      'https://firms.modaps.eosdis.nasa.gov/api/area/csv/$apiKey/$Source/24,22,37,32/5',
    );

    final response = await http.get(url);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> csvTable = csv.decode(response.body);
      if (csvTable.length <= 1) {
        print("Currently There Is No Recorded Fire Data For This Area");
        return [];
      }
      List<FireMarker> markers = [];

      for (int i = 1; i < csvTable.length; i++) {
        // هنبدأ من واحد عشان نسيب العناوين
        var row = csvTable[i];

        markers.add(
          FireMarker(
            latitude: double.parse(row[0].toString()),
            longitude: double.parse(row[1].toString()),
            brightness: double.parse(row[2].toString()),
            acqDate: row[5].toString(),
            time: row[6].toString(),
            confidence: row[9].toString(), 
            version: row[10].toString(),
            
          ),
        );
      }

      return markers;
    } else {
      throw Exception("Failed To Fetch Fires Data From NASA FIRMS");
    }
  }
}
