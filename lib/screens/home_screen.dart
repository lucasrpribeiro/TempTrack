import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:temp_tracker/services/geocoding_service.dart';
import '../models/day_data.dart';
import '../services/weather_service.dart';
import '../widgets/month_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();
  Map<String, double> _temperatureData = {};
  bool _isLoading = true;
  
  // Location state
  double _currentLat = -23.41485; // Maringá default
  double _currentLng = -51.939448;
  String _locationLabel = 'Maringá, PR';

  @override
  void initState() {
    super.initState();
    _loadTemperatureData();
  }

  Future<void> _loadTemperatureData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _weatherService.fetchTemperatureData(
        latitude: _currentLat,
        longitude: _currentLng,
      );
      setState(() {
        _temperatureData = data;
        _isLoading = false;
      });
      if (data.isEmpty && mounted) {
        _showError('Não foi possível carregar os dados. Verifique sua conexão com a internet.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Erro ao carregar dados: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }
  
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Serviço de localização desativado.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Permissão de localização negada.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showError('Permissão de localização negada permanentemente.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _locationLabel = 'Sua Localização';
      });
      await _loadTemperatureData();
    } catch (e) {
      _showError('Erro ao obter localização: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CitySearchModal(
        geocodingService: _geocodingService,
        onLocationSelected: (city) {
          setState(() {
            _currentLat = city.latitude;
            _currentLng = city.longitude;
            _locationLabel = '${city.name}, ${city.country}';
          });
          _loadTemperatureData();
        },
        onUseCurrentLocation: () {
          _getCurrentLocation();
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E86DE))),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  List<DayData> _generateDaysForMonth(int month) {
    final daysInMonth = DateTime(2026, month + 1, 0).day;
    final now = DateTime.now();
    final List<DayData> days = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(2026, month, day);
      final dateStr = '${date.year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final isFuture = date.isAfter(now);
      final temperature = _temperatureData[dateStr];

      days.add(DayData(
        date: date,
        temperature: temperature,
        isFuture: isFuture,
      ));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.thermostat_outlined, color: Color(0xFFE8E8E8)),
        title: Column(
          children: [
            const Text(
              'Temperatura 2026',
              style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              _locationLabel,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadTemperatureData,
            icon: const Icon(Icons.refresh, color: Color(0xFFE8E8E8)),
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            onPressed: _showLocationPicker,
            icon: const Icon(Icons.location_on_outlined, color: Color(0xFFE8E8E8)),
            tooltip: 'Trocar localização',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6BB6FF),
                  strokeWidth: 3,
                ),
              )
            : _temperatureData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 80,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sem dados disponíveis',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verifique sua conexão com a internet',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadTemperatureData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E86DE),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MonthGrid(
                          monthName: 'Janeiro',
                          days: _generateDaysForMonth(1),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Fevereiro',
                          days: _generateDaysForMonth(2),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Março',
                          days: _generateDaysForMonth(3),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Abril',
                          days: _generateDaysForMonth(4),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Maio',
                          days: _generateDaysForMonth(5),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Junho',
                          days: _generateDaysForMonth(6),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Julho',
                          days: _generateDaysForMonth(7),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Agosto',
                          days: _generateDaysForMonth(8),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Setembro',
                          days: _generateDaysForMonth(9),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Outubro',
                          days: _generateDaysForMonth(10),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Novembro',
                          days: _generateDaysForMonth(11),
                          locationLabel: _locationLabel,
                        ),
                        MonthGrid(
                          monthName: 'Dezembro',
                          days: _generateDaysForMonth(12),
                          locationLabel: _locationLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class CitySearchModal extends StatefulWidget {
  final GeocodingService geocodingService;
  final Function(LocationModel) onLocationSelected;
  final VoidCallback onUseCurrentLocation;

  const CitySearchModal({
    super.key,
    required this.geocodingService,
    required this.onLocationSelected,
    required this.onUseCurrentLocation,
  });

  @override
  State<CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
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
            const Text(
              'Buscar Localização',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onUseCurrentLocation();
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Usar minha localização'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E86DE),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome da cidade...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) async {
                if (value.length >= 3) {
                  setState(() => _isSearching = true);
                  final results = await widget.geocodingService.searchCities(value);
                  if (mounted) {
                    setState(() {
                      _searchResults = results;
                      _isSearching = false;
                    });
                  }
                } else {
                  setState(() => _searchResults = []);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(child: CircularProgressIndicator(color: Color(0xFF2E86DE)))
            else if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final city = _searchResults[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(city.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        '${city.admin1 ?? ''}${city.admin1 != null ? ', ' : ''}${city.country ?? ''}',
                        style: const TextStyle(color: Colors.white38),
                      ),
                      leading: const Icon(Icons.location_city, color: Colors.white38),
                      onTap: () {
                        widget.onLocationSelected(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            else if (_searchController.text.length >= 3)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text('Nenhum resultado encontrado.', style: TextStyle(color: Colors.white38)),
              ),
          ],
        ),
      ),
    );
  }
}
