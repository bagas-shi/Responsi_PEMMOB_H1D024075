import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'neumorphic_card.dart';

/// Kartu metrik khusus Kelembapan Udara (`relative_humidity_2m`)
/// yang dilengkapi angka metrik besar, ikon biru langit, serta
/// indikator visual *vertical pill progress bar* khas Soft UI.
class HumidityMetricCard extends StatelessWidget {
  final int humidityPercent;

  const HumidityMetricCard({
    super.key,
    required this.humidityPercent,
  });

  String get _humidityCategory {
    if (humidityPercent < 40) return 'Udara kering';
    if (humidityPercent <= 70) return 'Tingkat nyaman';
    return 'Udara lembap';
  }

  @override
  Widget build(BuildContext context) {
    final normalized = (humidityPercent.clamp(0, 100)) / 100.0;

    return NeumorphicCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.recessedSurface,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softSmallShadows,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 18,
                        color: AppTheme.primaryEnd,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kelembapan',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$humidityPercent',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '%',
                      style: TextStyle(
                        color: AppTheme.primaryEnd,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _humidityCategory,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Vertical Pill Progress Bar khas Neumorphic Soft UI
          Container(
            width: 14,
            height: 86,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: AppTheme.recessedSurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: normalized < 0.08 ? 0.08 : normalized,
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryEnd.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu metrik cuaca serbaguna bergaya Neumorphic untuk Kecepatan Angin,
/// Curah Hujan, dan Peluang Hujan dengan ikon melingkar & indikator bar opsional.
class WeatherMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final IconData icon;
  final double? progressFraction;

  const WeatherMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.icon,
    this.progressFraction,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.recessedSurface,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softSmallShadows,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppTheme.primaryEnd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppTheme.primaryEnd,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (progressFraction != null)
            Container(
              height: 7,
              width: double.infinity,
              padding: const EdgeInsets.all(1.2),
              decoration: BoxDecoration(
                color: AppTheme.recessedSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor:
                    progressFraction!.clamp(0.0, 1.0) < 0.06 &&
                            progressFraction! > 0
                        ? 0.06
                        : progressFraction!.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            )
          else
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
