import 'package:flutter/material.dart';
import '../design_system.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.primary).withOpacity(
                    0.18,
                  ),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined
              ? Colors.transparent
              : (backgroundColor ?? AppColors.primary),
          foregroundColor:
              textColor ??
              (isOutlined
                  ? (backgroundColor ?? AppColors.primary)
                  : Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            side: isOutlined
                ? BorderSide(
                    color: (backgroundColor ?? AppColors.primary),
                    width: 2,
                  )
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color:
                textColor ??
                (isOutlined
                    ? (backgroundColor ?? AppColors.primary)
                    : Colors.white),
          ),
        ),
      ),
    );
  }
}
