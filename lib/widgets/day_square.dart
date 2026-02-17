import 'package:flutter/material.dart';
import '../models/day_data.dart';
import '../utils/color_utils.dart';

class DaySquare extends StatefulWidget {
  final DayData dayData;
  final String locationLabel;

  const DaySquare({
    Key? key,
    required this.dayData,
    required this.locationLabel,
  }) : super(key: key);

  @override
  State<DaySquare> createState() => _DaySquareState();
}

class _DaySquareState extends State<DaySquare> {
  // ... (keeping variables same)
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // ... logic remains same
    final color = ColorUtils.getColorForTemperature(
      widget.dayData.temperature,
      widget.dayData.isFuture,
    );

    final displayColor = _isPressed ? ColorUtils.getBrighterColor(color) : color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showTemperatureInfo();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 16,
        height: 16,
        transform: Matrix4.identity()..scale(_isPressed ? 1.2 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              displayColor,
              displayColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: displayColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
      ),
    );
  }

  void _showTemperatureInfo() {
    final temp = widget.dayData.temperature;
    final date = widget.dayData.date;
    final color = ColorUtils.getColorForTemperature(temp, widget.dayData.isFuture);
    
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      temp != null && temp > 25 ? Icons.thermostat : Icons.ac_unit,
                      color: temp != null && temp < 10 ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day} de ${months[date.month - 1]}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.dayData.isFuture
                            ? 'Previsão Indisponível'
                            : '${temp?.toStringAsFixed(1)}° Celsius',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, 
                       color: Colors.white.withOpacity(0.5), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.locationLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
