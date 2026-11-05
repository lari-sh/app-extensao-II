import 'package:flutter/material.dart';

/// Visible return action; maybePop preserves route guards and does not sign out.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.enabled = true});
  final VoidCallback? onPressed;
  final bool enabled;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Voltar',
    icon: const Icon(Icons.arrow_back),
    onPressed: enabled
        ? (onPressed ?? () => Navigator.of(context).maybePop())
        : null,
  );
}
