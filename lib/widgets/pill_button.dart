import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Varian warna tombol kapsul (Pill Button):
/// - [primary]: Gradasi biru langit ke cyan + glow biru (contoh: SEARCH, RETRY)
/// - [secondary]: Gradasi kuning matahari ke amber + glow hangat (contoh: CANCEL)
enum PillButtonVariant {
  primary,
  secondary,
}

/// Tombol berbentuk kapsul (Stadium Border) khas Soft UI dengan gradasi halus
/// dan colored glow shadow di bawahnya.
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillButtonVariant variant;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PillButtonVariant.primary,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == PillButtonVariant.primary;
    final foregroundColor = isPrimary ? Colors.white : AppTheme.textPrimary;
    final borderRadius = BorderRadius.circular(999);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: onPressed == null ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? AppTheme.primaryGradient
              : AppTheme.secondaryGradient,
          borderRadius: borderRadius,
          boxShadow: isPrimary
              ? AppTheme.primaryGlowShadows
              : AppTheme.secondaryGlowShadows,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: borderRadius,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: foregroundColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 18, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
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
