import 'dart:async';
import 'package:flutter/material.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';

/// "SEND OTP" text button that cannot be tapped twice.
///
/// It is disabled while the request is running, so a second tap can not send a
/// second OTP. When [onSend] reports success (returns `true`) it stays disabled
/// for [cooldownSeconds] and counts down. When the send fails (`false`, or an
/// exception) it is enabled again straight away so the delivery partner can retry.
class OtpSendButton extends StatefulWidget {
  final Future<bool> Function() onSend;
  final int cooldownSeconds;
  final double fontSize;

  const OtpSendButton({
    super.key,
    required this.onSend,
    this.cooldownSeconds = 30,
    this.fontSize = 13,
  });

  @override
  State<OtpSendButton> createState() => _OtpSendButtonState();
}

class _OtpSendButtonState extends State<OtpSendButton> {
  bool _sending = false;
  int _remaining = 0;
  Timer? _timer;

  bool get _disabled => _sending || _remaining > 0;

  Future<void> _tap() async {
    if (_disabled) return;
    setState(() => _sending = true);
    bool ok = false;
    try {
      ok = await widget.onSend();
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _remaining = widget.cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining -= 1);
      if (_remaining <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _sending
        ? "SENDING..."
        : (_remaining > 0 ? "RESEND OTP IN ${_remaining}s" : "SEND OTP");
    final color = _disabled ? Colors.grey : AppColors.primary;
    return TextButton.icon(
      onPressed: _disabled ? null : _tap,
      icon: Icon(Icons.send_rounded, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: widget.fontSize,
        ),
      ),
    );
  }
}
