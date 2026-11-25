import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Menyelaraskan warna status bar sistem dengan background Soft UI (#F0F4F8)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WeatherApp());
}

/// Root widget aplikasi yang menginisialisasi `MultiProvider` (arsitektur MVVM)
/// serta menerapkan Material 3 Theme (`AppTheme.lightTheme`).
class WeatherApp extends StatelessWidget {
  final WeatherViewModel? weatherViewModel;
  final LocationViewModel? locationViewModel;

  const WeatherApp({
    super.key,
    this.weatherViewModel,
    this.locationViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => weatherViewModel ?? (WeatherViewModel()..initialize()),
        ),
        ChangeNotifierProvider<LocationViewModel>(
          create: (_) =>
              locationViewModel ?? (LocationViewModel()..loadSavedData()),
        ),
      ],
      child: MaterialApp(
        title: 'SkySoft Cuaca',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
