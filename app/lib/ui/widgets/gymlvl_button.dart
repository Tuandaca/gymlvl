import 'package:flutter/material.dart';

class GymlvlButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const GymlvlButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (icon ?? const SizedBox.shrink()),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 56), // Full width
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : (icon ?? const SizedBox.shrink()),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          ),
    );
  }
}
