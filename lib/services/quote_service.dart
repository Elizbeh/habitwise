import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String apiUrl = 'https://quote-garden.herokuapp.com/api/v3/quotes/random';

  Future<String> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['quote'];  // Adjust the path to get the quote
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quote: $e');
    }
  }
}
