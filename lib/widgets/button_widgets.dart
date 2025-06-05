import 'package:cocinando/widgets/text_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? text;
  final Color? color;
  final Color textColor;
  final TextStyle textStyle;
  final double? fontSize;
  final IconData? icon;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    this.text,
    required this.color,
    this.fontSize = 14.0,
    this.textColor = Colors.white,
    this.textStyle = AppTextStyles.subtitle_14,
    this.icon,
    this.onPressed,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _controller.forward().then((_) {
              _controller.reverse();
              widget.onPressed?.call();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final hasIcon = widget.icon != null;
    final hasText = widget.text != null && widget.text!.isNotEmpty;

    if (hasIcon && hasText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            widget.text!,
            style: widget.textStyle,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ],
      );
    } else if (hasIcon) {
      return Padding(padding: const EdgeInsets.all(2.5), child: Icon(widget.icon, color: widget.textColor, size: 14));
    } else if (hasText) {
      return Text(
        widget.text!,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w600,
          color: widget.textColor,
          fontFamily: 'SF Pro Display',
        ),
      );
    } else {
      return const SizedBox(); // Ничего не отображать
    }
  }
}

class BigButton extends StatefulWidget {
  final String? text;
  final bool isBlue;
  final VoidCallback? onPressed;

  const BigButton({
    super.key,
    this.text,
    this.isBlue = false,
    this.onPressed,
  });

  @override
  _BigButtonState createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.isBlue
          ? AlwaysStoppedAnimation(1.0)
          : _scaleAnimation,
      child: Padding(
        padding: (widget.isBlue) ? const EdgeInsets.all(0) : const EdgeInsets.symmetric(vertical: 3),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _controller.forward().then((_) {
                _controller.reverse();
                widget.onPressed?.call();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (widget.isBlue)
                  ? const Color.fromRGBO(0, 87, 248, 1)
                  : Color.fromRGBO(242, 242, 242, 1),
              padding: (widget.isBlue) ? const EdgeInsets.all(16) : const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: widget.isBlue ? Alignment.topLeft : Alignment.centerLeft,
                  child: Text(
                    widget.text ?? '',
                    style: widget.isBlue
                        ? const TextStyle(
                      fontSize: 36,
                      height: 1,
                      letterSpacing: 0,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                    )
                        : const TextStyle(
                      fontSize: 17,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'SF Pro',
                      letterSpacing: -0.43,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!widget.isBlue)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color.fromRGBO(128, 128, 128, 1),
                    size: 12,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
