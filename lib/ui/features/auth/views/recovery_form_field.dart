import 'package:flutter/material.dart';
import '../../team/views/team_components.dart';

/// Label, hint and border follow the approved access prototype.
class RecoveryFormField extends StatelessWidget {
  const RecoveryFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.fieldKey,
    this.error,
    this.helper,
    this.enabled = true,
    this.obscure = false,
  });
  final TextEditingController controller;
  final String label, hint;
  final Key fieldKey;
  final String? error, helper;
  final bool enabled, obscure;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: label,
        child: TextField(
          key: fieldKey,
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          autocorrect: false,
          enableSuggestions: !obscure,
          keyboardType: obscure
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            helperText: helper,
            helperStyle: const TextStyle(fontSize: 10),
            hintStyle: const TextStyle(color: teamMuted, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teamLine),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teamLine),
            ),
          ),
        ),
      ),
    ],
  );
}
