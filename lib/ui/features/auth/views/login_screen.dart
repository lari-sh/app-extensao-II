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
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EAE5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEADDD7)),
                ),
                child: const Center(
                  child: SizedBox.square(
                    dimension: 38,
                    child: CustomPaint(painter: _AccessMarkPainter()),
                  ),
                ),
              ),
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
                const Tooltip(
                  message: 'Opção indisponível nesta versão.',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: true, onChanged: null),
                      Text('Permanecer logado', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const Tooltip(
                  message: 'Recuperação de senha indisponível nesta versão.',
                  child: TextButton(
                    onPressed: null,
                    child: Text(
                      'Esqueci a senha',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Opções indisponíveis nesta versão.',
              style: TextStyle(fontSize: 11, color: Color(0xFF795C52)),
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

// The small line drawing used by the approved login artboard.
class _AccessMarkPainter extends CustomPainter {
  const _AccessMarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64, size.height / 64);
    final outline = Paint()
      ..color = const Color(0xFFC51D2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final body = Path()
      ..moveTo(16, 36)
      ..cubicTo(16, 28, 22, 22, 30, 22)
      ..cubicTo(38, 22, 44, 28, 44, 36)
      ..lineTo(44, 42)
      ..lineTo(16, 42)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFFCF4EE));
    canvas.drawPath(body, outline);
    for (final center in [
      const Offset(24, 22),
      const Offset(40, 22),
      const Offset(32, 34),
    ]) {
      canvas.drawCircle(center, 3, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _AccessMarkPainter oldDelegate) => false;
}
