import '../../../core/widgets/app_back_button.dart';
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
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          children: [
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    key: const ValueKey('loginShelterLogo'),
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    semanticLabel: 'Abrigo dos Anjos — Humanizando Vidas',
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: AppBackButton(
                    enabled: !widget.viewModel.state.busy,
                    onPressed: widget.onCancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Acesso restrito',
              style: TextStyle(fontFamily: 'serif', fontSize: 24, height: 1.15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Entre com suas credenciais de voluntário para acessar o painel administrativo.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF795C52),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'E-mail institucional',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('loginEmail'),
              controller: _email,
              enabled: !widget.viewModel.state.busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: 'seu.email@abrigo.org',
                prefixIcon: const Icon(Icons.mail_outline),
                errorText: widget.viewModel.state.fieldErrors['email'],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Senha',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('loginPassword'),
              controller: _password,
              enabled: !widget.viewModel.state.busy,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: '••••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                errorText: widget.viewModel.state.fieldErrors['password'],
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.viewModel.state.remember,
                      onChanged: widget.viewModel.state.busy
                          ? null
                          : widget.viewModel.setRemember,
                    ),
                    const Text(
                      'Permanecer logado',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: widget.viewModel.state.busy
                      ? null
                      : () => Navigator.pushNamed(context, '/recovery'),
                  child: const Text(
                    'Esqueci a senha',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (widget.viewModel.state.busy) const LinearProgressIndicator(),
            FilledButton(
              onPressed: widget.viewModel.state.busy ? null : _submit,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Entrar no painel',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            if (widget.viewModel.state.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(widget.viewModel.state.message!),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EAE5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEADDD7)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acesso restrito',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Apenas voluntários e funcionários cadastrados podem acessar as ferramentas administrativas de manejo clínico.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF795C52),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Visitante?', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: widget.onCancel == null
                  ? () => Navigator.pushNamed(context, '/catalog')
                  : null,
              child: const Text(
                'Conhecer os animais disponíveis',
                style: TextStyle(fontSize: 12),
              ),
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
