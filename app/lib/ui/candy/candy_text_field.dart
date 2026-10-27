import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Tactile Neubrutalist text field with 2px ink border, hard drop shadow,
/// clear focus feedback, password visibility toggle, and full Vietnamese input support.
class CandyTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;

  const CandyTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.helperText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<CandyTextField> createState() => _CandyTextFieldState();
}

class _CandyTextFieldState extends State<CandyTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused ? CandyColors.hotPink : CandyColors.ink;
    final shadowOffset = _isFocused ? const Offset(2, 2) : const Offset(4, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              widget.labelText!,
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CandyColors.ink,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: CandyTimings.press,
          decoration: BoxDecoration(
            color: CandyColors.card,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: borderColor,
              width: CandyColors.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: CandyColors.ink,
                offset: shadowOffset,
                blurRadius: 0.0,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CandyColors.ink,
              height: 1.35, // Ensures Vietnamese diacritics are not clipped
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: 15,
                color: CandyColors.muted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: CandyColors.ink, size: 20)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CandyColors.ink,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : widget.suffix,
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 4.0),
            child: Text(
              widget.helperText!,
              style: const TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: 12,
                color: CandyColors.charcoal,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
