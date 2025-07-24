import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TipsService {
  final _tipsCollection = FirebaseFirestore.instance.collection('tips');

  // Comprehensive local financial tips
  final List<String> _localFinancialTips = [
    "Save 20% of your income before spending on anything else.",
    "Create an emergency fund with 3-6 months of expenses.",
    "Track every expense to identify spending patterns.",
    "Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings.",
    "Pay yourself first - automate your savings.",
    "Avoid lifestyle inflation when you get a raise.",
    "Invest in your financial education.",
    "Review your budget monthly and adjust as needed.",
    "Use cash for discretionary spending to limit impulse buys.",
    "Negotiate bills and shop around for better rates.",
    "Cook at home more often to save on food costs.",
    "Set specific financial goals with deadlines.",
    "Diversify your income sources.",
    "Learn to distinguish between needs and wants.",
    "Start investing early, even with small amounts.",
    "Build good credit by paying bills on time.",
    "Consider the opportunity cost of every purchase.",
    "Automate your bill payments to avoid late fees.",
    "Review your insurance coverage annually.",
    "Teach your children about money management.",
    "Use the envelope method for budget categories.",
    "Maximize your employer's 401(k) match.",
    "Build multiple income streams.",
    "Learn about compound interest and start early.",
    "Create a debt payoff strategy (snowball or avalanche).",
    "Set up automatic transfers to savings accounts.",
    "Review and cancel unused subscriptions monthly.",
    "Use cashback credit cards wisely and pay in full.",
    "Consider buying used items for major purchases.",
    "Learn to negotiate your salary and benefits.",
    "Invest in yourself through education and skills.",
    "Create a will and estate plan.",
    "Diversify your investment portfolio.",
    "Learn about tax-advantaged accounts (IRA, HSA).",
    "Set up sinking funds for irregular expenses.",
    "Practice the 24-hour rule for non-essential purchases.",
    "Track your net worth monthly.",
    "Learn about inflation and its impact on savings.",
    "Consider side hustles to increase income.",
    "Build a strong financial foundation before investing.",
  ];

  Future<String?> getRandomTip() async {
    try {
      // Try to get from Firestore first
      final snap = await _tipsCollection.get();
      if (snap.docs.isNotEmpty) {
        final random = Random();
        final doc = snap.docs[random.nextInt(snap.docs.length)];
        return doc.data()['text'] as String?;
      }
    } catch (e) {
      print('Error fetching from Firestore: $e');
    }

    // Fallback to local tips
    final random = Random();
    return _localFinancialTips[random.nextInt(_localFinancialTips.length)];
  }

  Future<String?> getExternalTip() async {
    try {
      // Try financial quotes API (free, no API key required)
      final url = Uri.parse(
        'https://api.quotable.io/quotes?tags=finance|money|success&maxLength=150',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null &&
            data['results'] is List &&
            data['results'].isNotEmpty) {
          final random = Random();
          final quote = data['results'][random.nextInt(data['results'].length)];
          return quote['content'];
        }
      }
    } catch (e) {
      print('Error fetching from Quotable API: $e');
    }

    try {
      // Try API Ninjas for financial quotes (requires API key)
      final url = Uri.parse(
        'https://api.api-ninjas.com/v1/quotes?category=finance',
      );
      final response = await http
          .get(
            url,
            headers: {
              'X-Api-Key': 'YOUR_API_KEY', // Replace with your API key
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0]['quote'] != null) {
          return data[0]['quote'];
        }
      }
    } catch (e) {
      print('Error fetching from API Ninjas: $e');
    }

    // Final fallback to local financial tips
    final random = Random();
    return _localFinancialTips[random.nextInt(_localFinancialTips.length)];
  }

  // Get a financial tip specifically - now returns only financial advice
  Future<String> getFinancialTip() async {
    // 80% chance to use local financial tips, 20% chance to try external API
    final random = Random();
    if (random.nextDouble() < 0.8) {
      // Use local financial tips (more reliable and relevant)
      return _localFinancialTips[random.nextInt(_localFinancialTips.length)];
    } else {
      // Try external API
      final tip = await getExternalTip();
      return tip ??
          _localFinancialTips[random.nextInt(_localFinancialTips.length)];
    }
  }

  // Get a random financial tip from local collection only
  Future<String> getLocalFinancialTip() async {
    final random = Random();
    return _localFinancialTips[random.nextInt(_localFinancialTips.length)];
  }
}
