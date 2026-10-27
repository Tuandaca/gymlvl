import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SystemTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  const SystemTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
    this.textInputAction,
  });

  @override
  State<SystemTextField> createState() => _SystemTextFieldState();
}

class _SystemTextFieldState extends State<SystemTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: widget.isPassword && !_showPassword,
    keyboardType: widget.keyboardType,
    onChanged: widget.onChanged,
    onFieldSubmitted: widget.onSubmitted,
    validator: widget.validator,
    autofillHints: widget.autofillHints,
    textInputAction: widget.textInputAction,
    autocorrect:
        !widget.isPassword && widget.keyboardType != TextInputType.emailAddress,
    enableSuggestions: !widget.isPassword,
    style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
    decoration: InputDecoration(
      labelText: widget.hintText,
      filled: true,
      fillColor: AppTheme.background,
      prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      suffixIcon: widget.isPassword
          ? IconButton(
              tooltip: widget.hintText,
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            )
          : null,
      errorMaxLines: 3,
    ),
  );
}
