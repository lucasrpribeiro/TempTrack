# Temp Tracker

Aplicação Flutter para tracking de temperatura durante o ano de 2026.

## Características

- Grid de visualização estilo GitHub
- Cores baseadas em faixas de temperatura
- Layout mobile-first (coluna única)
- Dados de temperatura da API Open-Meteo
- Animações suaves ao tocar nos quadrados

## Como executar

### Pré-requisitos

- Flutter SDK instalado
- Android Studio ou VS Code com extensões Flutter
- Emulador Android ou dispositivo físico

### Instalação

1. Instale as dependências:

```bash
flutter pub get
```

2. Execute o app:

```bash
flutter run
```

## Estrutura do Projeto

```
lib/
├── main.dart              # Entry point
├── models/
│   └── day_data.dart      # Modelo de dados
├── screens/
│   └── home_screen.dart   # Tela principal
├── widgets/
│   ├── day_square.dart    # Widget do quadrado do dia
│   └── month_grid.dart    # Widget do grid do mês
├── services/
│   └── weather_service.dart # Serviço de API
└── utils/
    └── color_utils.dart   # Utilitários de cor
```

## Faixas de Temperatura

- Cinza: Datas futuras
- Branco: Abaixo de 0°C
- Azul claro: 0-10°C
- Azul médio: 11-20°C
- Azul: 21-25°C
- Amarelo: 26-30°C
- Amarelo escuro: 31-35°C
- Laranja: 36-37°C
- Vermelho: 38°C+
