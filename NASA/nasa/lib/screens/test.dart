 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Future<void> checkFireRiskByLocation() async {
  try {
    // 1. التحقق من صلاحيات الموقع وجلبه
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("تم رفض صلاحية الوصول للموقع");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 2. تجهيز الإحداثيات لإرسالها للنموذج
    final url = Uri.parse('http://127.0.0.1:8000/predict'); // أو رابط سيرفر البايثون
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude,
      }),
    );

    // 3. استقبال وتحليل النتيجة من نموذج الذكاء الاصطناعي
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int isFireProne = data['is_fire_prone'];
      double riskProbability = data['risk_probability'];

      print("حالة خطر الحريق: $isFireProne");
      print("نسبة الاحتمالية: $riskProbability");

      // هنا يمكنك إظهار النتيجة للمستخدم في الواجهة (تنبيه أو علامة نابضة)
    } else {
      print("فشل الاتصال بالسر فر");
    }
  } catch (e) {
    print("حدث خطأ: $e");
  }
}