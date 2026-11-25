import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import 'neumorphic_card.dart';

/// Kartu daftar lokasi kota untuk hasil pencarian Geocoding API maupun
/// daftar kota Favorit yang tersimpan di Local Storage.
class LocationTileCard extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;

  const LocationTileCard({
    super.key,
    required this.location,
    required this.isFavorite,
    this.isActive = false,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      border: isActive
          ? Border.all(
              color: AppTheme.primaryStart,
              width: 1.6,
            )
          : null,
      onTap: onSelect,
      child: Row(
        children: [
          // Ikon pin lokasi bergaya Soft UI
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : AppTheme.recessedSurface,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? AppTheme.primaryGlowShadows
                  : AppTheme.softSmallShadows,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 21,
              color: isActive ? Colors.white : AppTheme.primaryEnd,
            ),
          ),
          const SizedBox(width: 14),

          // Nama kota, provinsi/wilayah, dan negara
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        location.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryStart.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            color: AppTheme.primaryEnd,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  location.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Lat ${location.latitude.toStringAsFixed(2)} • Lon ${location.longitude.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Bintang Favorit (gradasi kuning hangat bila sudah difavoritkan)
          Tooltip(
            message: isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            child: InkWell(
              onTap: onToggleFavorite,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isFavorite ? AppTheme.secondaryGradient : null,
                  color: isFavorite ? null : AppTheme.recessedSurface,
                  shape: BoxShape.circle,
                  boxShadow: isFavorite
                      ? AppTheme.secondaryGlowShadows
                      : AppTheme.softSmallShadows,
                ),
                child: Icon(
                  isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 22,
                  color: isFavorite ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
