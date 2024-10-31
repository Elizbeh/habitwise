import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  final String apiUrl = 'https://api.api-ninjas.com/v1/quotes?category=inspirational';
  final String apiKey = 'sdGFB+I1+UTllvDqE7o0QA==wuTFo08UUyAuccDz';  // Replace with your actual API key

  Future<String> fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // Return the quote from the first result
          return '${data[0]['quote']} - ${data[0]['author']}';  // Include the author
        } else {
          throw Exception('No quotes found');
        }
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch quote: $e');
    }
  }
}
