# 🔧 Melhorias Técnicas Detalhadas - TempTracker

## 🐛 Bugs e Problemas Identificados

### 1. **Ano Hardcoded (2026)**
**Arquivo:** `lib/screens/home_screen.dart`  
**Linha:** 122, 127  
**Problema:**
```dart
final daysInMonth = DateTime(2026, month + 1, 0).day;
final date = DateTime(2026, month, day);
```
**Impacto:** App ficará desatualizado em 2027  
**Solução:**
```dart
final currentYear = DateTime.now().year;
final daysInMonth = DateTime(currentYear, month + 1, 0).day;
final date = DateTime(currentYear, month, day);
```

### 2. **Data Hardcoded na API**
**Arquivo:** `lib/services/weather_service.dart`  
**Linha:** 17  
**Problema:**
```dart
'&start_date=2026-01-01&end_date=$todayStr'
```
**Impacto:** Em 2027 não buscará dados do ano correto  
**Solução:**
```dart
final year = DateTime.now().year;
'&start_date=$year-01-01&end_date=$todayStr'
```

### 3. **Falta de Debounce na Busca**
**Arquivo:** `lib/screens/home_screen.dart`  
**Linha:** 347  
**Problema:** Cada tecla digitada faz uma requisição à API  
**Solução:** Implementar debounce de 500ms
```dart
Timer? _debounce;

onChanged: (value) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () async {
    if (value.length >= 3) {
      // fazer busca
    }
  });
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}
```

### 4. **Memory Leak Potencial**
**Arquivo:** `lib/screens/home_screen.dart`  
**Linha:** 350  
**Problema:** `mounted` check após async, mas setState pode ser chamado  
**Solução:** Verificar mounted antes de cada setState
```dart
if (!mounted) return;
setState(() { ... });
```

### 5. **Sem Tratamento de Cancelamento de Requisição**
**Arquivo:** `lib/services/weather_service.dart`  
**Problema:** Se usuário sair da tela, requisição continua  
**Solução:** Usar CancelToken ou adicionar lógica de cancelamento

---

## 🏗️ Refatorações Recomendadas

### 1. **Criar Arquivo de Constantes**
**Novo arquivo:** `lib/constants/app_constants.dart`
```dart
class AppConstants {
  static const String appName = 'TempTracker';
  static const String defaultTimezone = 'America/Sao_Paulo';
  static const double minSearchLength = 3;
  static const int apiTimeout = 15;
  static const int searchDebounceMs = 500;
}

class AppColors {
  static const Color background = Color(0xFF1A1A1A);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color cardBackground = Color(0xFF242424);
  static const Color primary = Color(0xFF2E86DE);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFE0E0E0);
}

class TemperatureRanges {
  static const double freezing = 0;
  static const double cold = 10;
  static const double mild = 20;
  static const double warm = 25;
  static const double hot = 30;
  static const double veryHot = 35;
  static const double extreme = 37;
}
```

### 2. **Extrair Nomes de Meses**
**Novo arquivo:** `lib/utils/date_utils.dart`
```dart
class DateHelpers {
  static const List<String> monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  static String getMonthName(int month) {
    return monthNames[month - 1];
  }
  
  static String formatDate(DateTime date) {
    return '${date.day} de ${getMonthName(date.month)}';
  }
}
```

### 3. **Service Locator para Injeção de Dependência**
**Novo arquivo:** `lib/services/service_locator.dart`
```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<WeatherService>(() => WeatherService());
  getIt.registerLazySingleton<GeocodingService>(() => GeocodingService());
  getIt.registerLazySingleton<CacheService>(() => CacheService());
}
```

### 4. **Result Pattern para Erros**
**Novo arquivo:** `lib/core/result.dart`
```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}

class Loading<T> extends Result<T> {
  const Loading();
}
```

Uso:
```dart
Future<Result<Map<String, double>>> fetchTemperatureData() async {
  try {
    final response = await http.get(url).timeout(...);
    if (response.statusCode == 200) {
      return Success(temperatureMap);
    }
    return Failure('Erro ${response.statusCode}');
  } catch (e) {
    return Failure('Erro de conexão', e as Exception);
  }
}
```

### 5. **Cache Service**
**Novo arquivo:** `lib/services/cache_service.dart`
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _tempDataKey = 'temperature_data';
  static const String _lastUpdateKey = 'last_update';
  static const Duration _cacheValidity = Duration(hours: 6);
  
  Future<void> saveTemperatureData(
    Map<String, double> data,
    double lat,
    double lng,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_tempDataKey}_${lat}_$lng';
    await prefs.setString(key, json.encode(data));
    await prefs.setInt('${_lastUpdateKey}_${lat}_$lng', 
                       DateTime.now().millisecondsSinceEpoch);
  }
  
  Future<Map<String, double>?> getTemperatureData(
    double lat,
    double lng,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_tempDataKey}_${lat}_$lng';
    final updateKey = '${_lastUpdateKey}_${lat}_$lng';
    
    final lastUpdate = prefs.getInt(updateKey);
    if (lastUpdate == null) return null;
    
    final updateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    if (DateTime.now().difference(updateTime) > _cacheValidity) {
      return null;
    }
    
    final data = prefs.getString(key);
    if (data == null) return null;
    
    return Map<String, double>.from(json.decode(data));
  }
  
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
        .where((k) => k.startsWith(_tempDataKey) || k.startsWith(_lastUpdateKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

### 6. **ViewModel/Controller Pattern**
**Novo arquivo:** `lib/viewmodels/home_viewmodel.dart`
```dart
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final CacheService _cacheService;
  
  Map<String, double> _temperatureData = {};
  bool _isLoading = true;
  String? _error;
  
  HomeViewModel(this._weatherService, this._cacheService);
  
  Map<String, double> get temperatureData => _temperatureData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _temperatureData.isNotEmpty;
  
  Future<void> loadTemperatureData(double lat, double lng) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final cachedData = await _cacheService.getTemperatureData(lat, lng);
    if (cachedData != null) {
      _temperatureData = cachedData;
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    final result = await _weatherService.fetchTemperatureData(
      latitude: lat,
      longitude: lng,
    );
    
    result.when(
      success: (data) {
        _temperatureData = data;
        _cacheService.saveTemperatureData(data, lat, lng);
        _isLoading = false;
      },
      failure: (message, _) {
        _error = message;
        _isLoading = false;
      },
    );
    
    notifyListeners();
  }
}
```

---

## 📦 Dependências Recomendadas

### Adicionar ao pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.18.1
  geolocator: ^10.1.0
  
  # Gerenciamento de Estado
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # Cache e Persistência
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utilities
  get_it: ^7.6.4
  equatable: ^2.0.5
  
  # Analytics (futuro)
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.4
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.6
```

---

## 🧪 Estrutura de Testes Sugerida

### 1. **Unit Tests**
```dart
// test/services/weather_service_test.dart
void main() {
  group('WeatherService', () {
    test('should fetch temperature data successfully', () async {
      final service = WeatherService();
      final result = await service.fetchTemperatureData(
        latitude: -23.41485,
        longitude: -51.939448,
      );
      expect(result, isA<Success>());
    });
    
    test('should handle timeout error', () async {
      // Mock http client with timeout
    });
  });
}
```

### 2. **Widget Tests**
```dart
// test/widgets/day_square_test.dart
void main() {
  testWidgets('DaySquare shows temperature when tapped', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DaySquare(
          dayData: DayData(
            date: DateTime(2026, 1, 1),
            temperature: 25.5,
            isFuture: false,
          ),
          locationLabel: 'Test',
        ),
      ),
    ));
    
    await tester.tap(find.byType(DaySquare));
    await tester.pumpAndSettle();
    
    expect(find.text('25.5° Celsius'), findsOneWidget);
  });
}
```

### 3. **Integration Tests**
```dart
// integration_test/app_test.dart
void main() {
  testWidgets('Full app flow', (tester) async {
    await tester.pumpWidget(const TempTrackerApp());
    await tester.pumpAndSettle();
    
    expect(find.text('Temperatura 2026'), findsOneWidget);
    
    // Test location picker
    await tester.tap(find.byIcon(Icons.location_on_outlined));
    await tester.pumpAndSettle();
    
    expect(find.text('Buscar Localização'), findsOneWidget);
  });
}
```

---

## 🔐 Melhorias de Segurança

### 1. **Validação de Entrada**
```dart
class Validators {
  static bool isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90;
  }
  
  static bool isValidLongitude(double lng) {
    return lng >= -180 && lng <= 180;
  }
  
  static String? validateCitySearch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 3) {
      return 'Mínimo 3 caracteres';
    }
    if (value.length > 100) {
      return 'Máximo 100 caracteres';
    }
    return null;
  }
}
```

### 2. **Sanitização de Dados da API**
```dart
double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
```

---

## 📊 Logging e Debugging

### 1. **Logger Service**
```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(),
  );
  
  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

### 2. **Analytics Events**
```dart
class AnalyticsService {
  static Future<void> logLocationChange(String location) async {
    // Firebase Analytics
  }
  
  static Future<void> logTemperatureView(DateTime date) async {
    // Track user engagement
  }
  
  static Future<void> logError(String error) async {
    // Track errors for improvement
  }
}
```

---

## 🎨 Acessibilidade

### Melhorias Necessárias:
1. **Semantics para DaySquare**
```dart
Semantics(
  label: 'Dia ${day.date.day}, temperatura ${day.temperature}°C',
  button: true,
  child: GestureDetector(...),
)
```

2. **Contrast Ratio**
- Verificar se cores passam WCAG AA
- Adicionar modo alto contraste

3. **Font Scaling**
- Testar com fontes grandes do sistema
- Usar MediaQuery.textScaleFactorOf(context)

4. **Screen Reader Support**
- Adicionar labels em todos os botões
- Testar com TalkBack/VoiceOver

---

## 🚀 Performance Optimization

### 1. **Lazy Loading**
```dart
ListView.builder(
  itemCount: 12, // meses
  itemBuilder: (context, index) {
    return MonthGrid(
      monthName: DateHelpers.monthNames[index],
      days: _generateDaysForMonth(index + 1),
      locationLabel: _locationLabel,
    );
  },
)
```

### 2. **Image/Asset Optimization**
- Usar .webp para imagens
- Compressão de assets
- Lazy loading de ícones

### 3. **Reduce Rebuilds**
```dart
const DaySquare(...) // Usar const quando possível
```

---

**Próximos Passos:**
1. Corrigir bugs críticos (anos hardcoded)
2. Implementar cache
3. Adicionar testes
4. Refatorar arquitetura
5. Implementar features novas

**Estimativa:** 2-3 sprints para implementar melhorias críticas
