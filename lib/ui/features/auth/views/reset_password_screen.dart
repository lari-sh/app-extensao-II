import 'recovery_form_field.dart';
import 'package:flutter/material.dart';
import '../../team/views/team_components.dart';
import '../view_models/recovery_view_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.viewModel});
  final ResetPasswordViewModel viewModel;
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController(),
      _confirmation = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _login() => Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => route.isFirst,
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final vm = widget.viewModel, state = vm.state;
      return Scaffold(
        appBar: TeamHeader(
          context: context,
          title: 'Definir nova senha',
          eyebrow: 'Recuperação de acesso',
          enabled: !state.busy,
        ),
        bottomNavigationBar: TeamFooter(
          child: state.completed
              ? FilledButton(
                  onPressed: _login,
                  child: const Text('Ir para o login'),
                )
              : state.available
              ? FilledButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          await vm.submit(_password.text, _confirmation.text);
                          if (mounted && vm.state.completed) {
                            _password.clear();
                            _confirmation.clear();
                          }
                        },
                  child: const Text('Salvar nova senha'),
                )
              : OutlinedButton(
                  onPressed: state.loading
                      ? null
                      : () => Navigator.pushReplacementNamed(
                          context,
                          '/recovery',
                        ),
                  child: const Text('Solicitar novo link'),
                ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/images/logo.png'),
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(height: 20),
            state.completed
                ? const Text(
                    'Senha atualizada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const Text(
                    'Escolha uma nova senha para voltar a acessar sua conta.',
                    style: TextStyle(fontSize: 12, height: 1.8),
                  ),
            const SizedBox(height: 24),
            if (state.loading || state.busy) const LinearProgressIndicator(),
            if (state.available && !state.completed) ...[
              RecoveryFormField(
                controller: _password,
                label: 'Nova senha',
                hint: 'Crie uma senha',
                fieldKey: const ValueKey('resetPassword'),
                obscure: true,
                enabled: !state.busy,
                helper: 'Use pelo menos 12 caracteres.',
                error: state.errors['password'],
              ),
              const SizedBox(height: 20),
              RecoveryFormField(
                controller: _confirmation,
                label: 'Confirmar nova senha',
                hint: 'Repita a nova senha',
                fieldKey: const ValueKey('resetConfirmation'),
                obscure: true,
                enabled: !state.busy,
                error: state.errors['confirmation'],
              ),
              const TeamCallout(
                child: Text(
                  'Depois de salvar, entre novamente no aplicativo com sua nova senha.',
                ),
              ),
            ],
            if (state.completed)
              const Text(
                'Faça login novamente com sua nova senha.',
                textAlign: TextAlign.center,
              ),
            if (state.message != null) TeamCallout(child: Text(state.message!)),
          ],
        ),
      );
    },
  );
}
