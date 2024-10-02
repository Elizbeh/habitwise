// QuoteService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String apiUrl = 'https://api.api-ninjas.com/v1/quotes';

  Future<String> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['q']; // Change 'content' to 'q' if that is the correct field
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quote: $e');
    }
  }
}