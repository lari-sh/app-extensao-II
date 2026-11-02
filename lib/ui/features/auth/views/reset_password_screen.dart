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
            Text(
              state.completed
                  ? 'Senha atualizada'
                  : 'Escolha uma nova senha para sua conta.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            if (state.loading || state.busy) const LinearProgressIndicator(),
            if (state.available && !state.completed) ...[
              TextField(
                controller: _password,
                enabled: !state.busy,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  helperText: 'Use pelo menos 12 caracteres.',
                  errorText: state.errors['password'],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmation,
                enabled: !state.busy,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha',
                  errorText: state.errors['confirmation'],
                ),
              ),
              const TeamCallout(
                child: Text(
                  'Depois de salvar, faça login novamente com sua nova senha.',
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
