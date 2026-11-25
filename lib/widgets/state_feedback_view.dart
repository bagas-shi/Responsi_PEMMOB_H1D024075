import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'neumorphic_card.dart';
import 'pill_button.dart';

/// Komponen reusable untuk menangani state Loading, Empty (Kosong), dan Error
/// secara konsisten sesuai gaya Light Neumorphism / Soft UI.
class StateFeedbackView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool isError;

  const StateFeedbackView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    this.isError = false,
  });

  /// Factory state Loading dengan indikator putar halus.
  factory StateFeedbackView.loading({
    String title = 'Memuat Data Real-Time...',
    String message = 'Menghubungi layanan cuaca Open-Meteo',
  }) {
    return StateFeedbackView(
      icon: Icons.cloud_sync_rounded,
      title: title,
      message: message,
      isLoading: true,
    );
  }

  /// Factory state Empty ketika hasil pencarian atau data kosong.
  factory StateFeedbackView.empty({
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return StateFeedbackView(
      icon: Icons.travel_explore_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Factory state Error lengkap dengan tombol Retry (Coba Lagi).
  factory StateFeedbackView.error({
    String title = 'Gagal Memuat Data',
    required String message,
    String actionLabel = 'COBA LAGI',
    required VoidCallback onRetry,
  }) {
    return StateFeedbackView(
      icon: Icons.wifi_off_rounded,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onRetry,
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? AppTheme.errorColor : AppTheme.primaryEnd;

    return NeumorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.recessedSurface,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softSmallShadows,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.primaryEnd,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 32,
                      color: accentColor,
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            PillButton(
              label: actionLabel!,
              icon: Icons.refresh_rounded,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
