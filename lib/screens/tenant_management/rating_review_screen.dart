import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Models
class RatingAverages {
  final double cleaning;
  final double internet;
  final double food;

  RatingAverages({required this.cleaning, required this.internet, required this.food});

  factory RatingAverages.fromJson(Map<String, dynamic> json) {
    return RatingAverages(
      cleaning: (json['cleaning'] ?? 0.0).toDouble(),
      internet: (json['internet'] ?? 0.0).toDouble(),
      food: (json['food'] ?? 0.0).toDouble(),
    );
  }
}

class Review {
  final String feedbackText;
  final String tenantName;

  Review({required this.feedbackText, required this.tenantName});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      feedbackText: json['feedback_text'] ?? '',
      tenantName: json['rating__tenant__name'] ?? 'Anonymous',
    );
  }
}

class RatingData {
  final RatingAverages averages;
  final List<Review> reviews;

  RatingData({required this.averages, required this.reviews});

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      averages: RatingAverages.fromJson(json['averages'] ?? {}),
      reviews: (json['reviews'] as List? ?? []).map((r) => Review.fromJson(r)).toList(),
    );
  }
}

class RatingReviewScreen extends StatefulWidget {
  final String propertyId;
  const RatingReviewScreen({super.key, required this.propertyId});

  @override
  _RatingReviewScreenState createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  late Future<RatingData> _ratingsFuture;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  void _loadRatings() {
    _ratingsFuture = _fetchRatings();
  }

  Future<RatingData> _fetchRatings() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/property/${widget.propertyId}/ratings/?year=${_selectedMonth.year}&month=${_selectedMonth.month}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return RatingData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load ratings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadRatings();
          });
        },
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: FutureBuilder<RatingData>(
                future: _ratingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No ratings data found.'));
                  }

                  final ratingData = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildAveragesSection(ratingData.averages),
                      const SizedBox(height: 24),
                      Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildReviewsSection(ratingData.reviews),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
     return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActionChip(
            avatar: const Icon(Icons.calendar_today),
            label: Text(DateFormat('MMM yyyy').format(_selectedMonth)),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null && (picked.year != _selectedMonth.year || picked.month != _selectedMonth.month)) {
                setState(() {
                  _selectedMonth = picked;
                  _loadRatings();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAveragesSection(RatingAverages averages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _AverageRatingIndicator(label: 'Cleaning', average: averages.cleaning, color: Colors.blue),
        _AverageRatingIndicator(label: 'Internet', average: averages.internet, color: Colors.orange),
        _AverageRatingIndicator(label: 'Food', average: averages.food, color: Colors.purple),
      ],
    );
  }

  Widget _buildReviewsSection(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No reviews for this month.'),
      ));
    }
    return Column(
      children: reviews.map((review) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('"${review.feedbackText}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text('- ${review.tenantName}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _AverageRatingIndicator extends StatelessWidget {
  final String label;
  final double average;
  final Color color;

  const _AverageRatingIndicator({required this.label, required this.average, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 8.0,
          percent: average / 5.0,
          center: Text('${average.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}