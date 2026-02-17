import 'package:flutter/material.dart';
import '../models/day_data.dart';
import 'day_square.dart';

class MonthGrid extends StatelessWidget {
  final String monthName;
  final List<DayData> days;
  final String locationLabel;

  const MonthGrid({
    Key? key,
    required this.monthName,
    required this.days,
    required this.locationLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      // ... (rest of build remains same, but calling _buildWeekRows with the label)
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            monthName.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 16,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildWeekRows(),
        ],
      ),
    );
  }

  List<Widget> _buildWeekRows() {
    List<Widget> rows = [];
    
    for (int i = 0; i < days.length; i += 7) {
      final weekDays = days.sublist(
        i,
        i + 7 > days.length ? days.length : i + 7,
      );
      
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: weekDays.map((day) {
            return Padding(
              padding: const EdgeInsets.all(2.5),
              child: DaySquare(
                dayData: day,
                locationLabel: locationLabel,
              ),
            );
          }).toList(),
        ),
      );
      
      // Add spacing between rows except after the last row
      if (i + 7 < days.length) {
        rows.add(const SizedBox(height: 5));
      }
    }
    
    return rows;
  }
}
