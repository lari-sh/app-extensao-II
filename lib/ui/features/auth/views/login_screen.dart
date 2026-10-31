import 'package:flutter/material.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.viewModel,
    this.navigateOnSuccess = true,
    this.onCancel,
  });
  final LoginViewModel viewModel;
  final bool navigateOnSuccess;
  final VoidCallback? onCancel;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(), _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await widget.viewModel.submit(_email.text, _password.text);
    if (!mounted || !widget.viewModel.state.signedIn) return;
    _password.clear();
    if (widget.navigateOnSuccess) {
      Navigator.pushReplacementNamed(context, '/volunteer');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Área do voluntário'),
      automaticallyImplyLeading: widget.onCancel == null,
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            const SizedBox(height: 20),
            Text(
              'Entre com sua conta autorizada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'O acesso é reservado aos voluntários cadastrados pelo abrigo.',
            ),
            const SizedBox(height: 20),
            TextField(
              key: const ValueKey('loginEmail'),
              controller: _email,
              enabled: !widget.viewModel.state.busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: 'E-mail',
                errorText: widget.viewModel.state.fieldErrors['email'],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('loginPassword'),
              controller: _password,
              enabled: !widget.viewModel.state.busy,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Senha',
                errorText: widget.viewModel.state.fieldErrors['password'],
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            if (widget.viewModel.state.busy) const LinearProgressIndicator(),
            FilledButton(
              onPressed: widget.viewModel.state.busy ? null : _submit,
              child: const Text('Entrar'),
            ),
            if (widget.viewModel.state.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(widget.viewModel.state.message!),
              ),
            if (widget.onCancel != null)
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancelar reautenticação'),
              ),
          ],
        ),
      ),
    ),
  );
}
