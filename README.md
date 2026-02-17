# 🌡️ TempTracker

Visualize temperaturas históricas em um grid estilo GitHub, com dados diários do ano inteiro.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/flutter-3.41.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📱 Sobre o Projeto

TempTracker é um aplicativo Flutter que permite visualizar dados de temperatura em um formato visual inspirado no gráfico de contribuições do GitHub. Cada dia do ano é representado por um quadrado colorido, onde a cor indica a temperatura registrada naquele dia.

### ✨ Funcionalidades

- 📊 Grid visual com 365 dias do ano
- 🌍 Busca de cidades em todo o mundo
- 📍 Detecção automática de localização
- 🎨 Escala de cores intuitiva (do azul ao vermelho)
- 📱 Interface moderna e responsiva
- 🔄 Atualização manual de dados
- 💾 Funcionamento offline (após primeiro carregamento)

---

## 🎨 Screenshots

```
[TODO: Adicionar screenshots do app]
```

---

## 🚀 Como Usar

### Requisitos
- Flutter 3.0 ou superior
- Android SDK 28 ou superior
- Dart 3.0 ou superior

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/temp-tracker.git
cd temp-tracker
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o app:
```bash
flutter run
```

### Build para Release

```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏗️ Arquitetura

```
lib/
├── main.dart                 # Entry point
├── models/
│   └── day_data.dart         # Modelo de dados do dia
├── screens/
│   └── home_screen.dart      # Tela principal
├── services/
│   ├── weather_service.dart  # Serviço de clima
│   └── geocoding_service.dart # Serviço de geocoding
├── widgets/
│   ├── month_grid.dart       # Grid mensal
│   └── day_square.dart       # Quadrado individual
└── utils/
    └── color_utils.dart      # Utilitários de cor
```

---

## 🎨 Escala de Cores

| Temperatura | Cor | Hex |
|-------------|-----|-----|
| < 0°C | Branco | `#FFFFFF` |
| 0-10°C | Azul claro | `#A8D5FF` |
| 11-20°C | Azul | `#6BB6FF` |
| 21-25°C | Azul escuro | `#2E86DE` |
| 26-30°C | Amarelo | `#FFD93D` |
| 31-35°C | Laranja | `#F4A300` |
| 36-37°C | Laranja escuro | `#FF8C42` |
| > 38°C | Vermelho | `#FF4757` |
| Sem dados | Cinza | `#4A4A4A` |

---

## 🔌 APIs Utilizadas

### Open-Meteo API
- **Clima:** `https://api.open-meteo.com/v1/forecast`
- **Geocoding:** `https://geocoding-api.open-meteo.com/v1/search`
- **Documentação:** https://open-meteo.com/
- **Gratuito:** Sim, sem necessidade de API key

---

## 📦 Dependências

### Principais
- `http: ^1.1.0` - Requisições HTTP
- `geolocator: ^10.1.0` - Serviços de localização
- `intl: ^0.18.1` - Internacionalização

### Dev
- `flutter_lints: ^3.0.0` - Linting
- `flutter_test` - Testes

---

## 🛣️ Roadmap

### ✅ Versão 1.0 (Atual)
- [x] Visualização em grid
- [x] Busca de cidades
- [x] Localização GPS
- [x] Escala de cores
- [x] Interface responsiva

### 🔄 Versão 1.1 (Em breve)
- [ ] Cache local de dados
- [ ] Estatísticas (média, máx, mín)
- [ ] Legenda de cores
- [ ] Pull-to-refresh
- [ ] Salvamento de localização favorita

### 🎯 Versão 1.2 (Futuro)
- [ ] Múltiplas localizações
- [ ] Histórico de anos anteriores
- [ ] Modo claro/escuro
- [ ] Widget para home screen
- [ ] Exportação de dados

### 🚀 Versão 2.0 (Planejado)
- [ ] Notificações inteligentes
- [ ] Comparação entre cidades
- [ ] Gamificação e badges
- [ ] Compartilhamento social

Ver [ROADMAP.md](ROADMAP.md) para detalhes completos.

---

## 📚 Documentação

- **[ROADMAP.md](ROADMAP.md)** - Plano completo de melhorias e features
- **[TECHNICAL_IMPROVEMENTS.md](TECHNICAL_IMPROVEMENTS.md)** - Melhorias técnicas detalhadas
- **[QUICK_WINS.md](QUICK_WINS.md)** - Ações rápidas de alto impacto

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Guidelines
- Siga o style guide do Flutter
- Adicione testes quando possível
- Atualize a documentação
- Mantenha commits semânticos

---

## 🐛 Reportar Bugs

Encontrou um bug? Abra uma [issue](https://github.com/seu-usuario/temp-tracker/issues) com:

- Descrição clara do problema
- Steps to reproduce
- Expected behavior
- Screenshots (se aplicável)
- Informações do dispositivo

---

## 📄 Licença

Este projeto está sob a licença MIT. Ver arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👤 Autor

**Lucas** (lks)

- GitHub: [@seu-usuario](https://github.com/seu-usuario)

---

## 🙏 Agradecimentos

- [Open-Meteo](https://open-meteo.com/) pela API gratuita e excelente
- Flutter team pela framework incrível
- Comunidade Flutter Brasil

---

## 📊 Status do Projeto

- **Status:** ✅ Ativo
- **Última atualização:** 17 de fevereiro de 2026
- **Versão:** 1.0.0
- **Plataforma:** Android
- **Manutenção:** Ativa

---

## 💡 Inspiração

Inspirado no gráfico de contribuições do GitHub e na necessidade de visualizar dados climáticos de forma intuitiva e bonita.

---

## 🔗 Links Úteis

- [Flutter Documentation](https://docs.flutter.dev/)
- [Open-Meteo API Docs](https://open-meteo.com/en/docs)
- [Material Design Guidelines](https://material.io/design)

---

**Feito com ❤️ e Flutter**
