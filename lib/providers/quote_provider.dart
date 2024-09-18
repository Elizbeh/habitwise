import 'package:flutter/material.dart';
import 'package:habitwise/services/quote_service.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  String _quote = 'Loading...';

  String get quote => _quote;

  Future<void> fetchQuote() async {
    try {
      _quote = await _quoteService.fetchQuote();
    } catch (e) {
      _quote = 'Failed to load quote';
    }
    notifyListeners();
  }
}
