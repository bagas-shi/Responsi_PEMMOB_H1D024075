import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import 'neumorphic_card.dart';
import 'weather_icon_badge.dart';

/// Kartu vertikal perkiraan cuaca beberapa hari ke depan (`daily`).
/// Menampilkan singkatan hari (`Su`, `Mo`, `Tu`...), peluang hujan harian,
/// ikon cuaca di tengah, serta suhu maks (dark slate) & suhu min (muted gray) di kanan.
class WeeklyForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const WeeklyForecastCard({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppTheme.primaryEnd,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Perkiraan Mingguan',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${forecasts.length} Hari',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            separatorBuilder: (_, _) => const Divider(
              height: 16,
              thickness: 1,
              color: AppTheme.dividerSoft,
            ),
            itemBuilder: (context, index) {
              final day = forecasts[index];
              final isToday = index == 0;
              final dateLabel = DateFormat('dd/MM').format(day.date);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Kiri: Singkatan hari (Su, Mo, Tu...) + tanggal
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(
                            day.shortDayCode,
                            style: TextStyle(
                              color: isToday
                                  ? AppTheme.primaryEnd
                                  : AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isToday ? 'Hari ini' : dateLabel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isToday
                                    ? AppTheme.primaryEnd
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tengah: Ikon cuaca + indikator peluang hujan harian
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WeatherIconBadge(
                                visualType: day.condition.visualType,
                                size: 40,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.recessedSurface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.water_drop_rounded,
                                      size: 12,
                                      color: AppTheme.primaryEnd,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${day.precipitationProbabilityMax}%',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Kanan: Suhu maksimum (gelap) & suhu minimum (abu redup)
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.temperatureMax.round()}°',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${day.temperatureMin.round()}°',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
