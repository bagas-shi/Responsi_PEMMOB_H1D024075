import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kartu bergaya Light Neumorphism / Soft UI dengan sudut membulat besar,
/// permukaan putih lembut, highlight kiri-atas, dan bayangan difus kanan-bawah.
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 22,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardSurface,
        gradient: backgroundColor == null ? AppTheme.softSurfaceGradient : null,
        borderRadius: radius,
        border: border ??
            Border.all(
              color: AppTheme.borderLight.withValues(alpha: 0.9),
              width: 1.2,
            ),
        boxShadow: AppTheme.softCardShadows,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppTheme.primaryStart.withValues(alpha: 0.12),
          highlightColor: AppTheme.primaryStart.withValues(alpha: 0.06),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon melingkar bergaya Neumorphic untuk aksi navigasi & utilitas
/// seperti Search, Refresh, Back, dan Favorite.
class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? iconColor;
  final double size;
  final bool isSpinning;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconColor,
    this.size = 46,
    this.isSpinning = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
        boxShadow: AppTheme.softSmallShadows,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: isSpinning
                ? SizedBox(
                    width: size * 0.42,
                    height: size * 0.42,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: AppTheme.primaryEnd,
                    ),
                  )
                : Icon(
                    icon,
                    size: size * 0.46,
                    color: iconColor ?? AppTheme.textPrimary,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
