import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String apiUrl = 'https://zenquotes.io/api/today'; // API URL for random quotes

  Future<String> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'];
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      throw Exception('Failed to fetch quote: $e');
    }
  }
}
