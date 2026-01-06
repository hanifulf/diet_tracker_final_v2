import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class FoodAnalyzerService {
  static const String _apiKey = 'AIzaSyDZNW88gcPQGBl5OTnr1BDGlwJe_77JWME';

  static Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      final imageBytes = await imageFile.readAsBytes();
      final mimeType = imageFile.path.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      final content = [
        Content.multi([
          TextPart("""
Kamu adalah Ahli Gizi, Analisis gambar makanan ini sedetail mungkin dan kembalikan HANYA JSON VALID tanpa markdown.
Semuanya dalam Bahasa Indonesia.
Format:
{
  "name": "Nama makanan",
  "confidence": 0.0,
  "calories": 0,
  "carbohydrates": 0,
  "proteins": 0,
  "fats": 0,
  "serving_size": "string"
}
"""),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('AI tidak mengembalikan respon');
      }

      final raw = response.text!.trim();

      // Ambil JSON murni
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1) {
        throw FormatException('Respon AI bukan JSON valid:\n$raw');
      }

      final cleanJson = raw.substring(start, end + 1);

      return jsonDecode(cleanJson);
    } catch (e) {
      // JANGAN fallback di sini
      // Lempar error agar UI tahu penyebabnya
      rethrow;
    }
  }
}
