import 'package:flutter/material.dart';
import '../../team/views/team_components.dart';
import '../view_models/recovery_view_model.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key, required this.viewModel});
  final RecoveryViewModel viewModel;
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _email = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final vm = widget.viewModel, state = vm.state;
      return Scaffold(
        appBar: TeamHeader(
          context: context,
          title: 'Recuperar acesso',
          eyebrow: 'Acesso da equipe',
          enabled: !state.busy,
        ),
        bottomNavigationBar: TeamFooter(
          child: FilledButton(
            onPressed: state.busy
                ? null
                : state.completed
                ? () => Navigator.pop(context)
                : () {
                    FocusScope.of(context).unfocus();
                    vm.submit(_email.text);
                  },
            child: Text(
              state.completed ? 'Voltar ao login' : 'Enviar orientações',
            ),
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
                  ? 'Confira seu e-mail'
                  : 'Vamos ajudar você a entrar novamente.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.completed
                  ? 'Se houver uma conta para esse e-mail, você receberá as orientações para redefinir a senha. Confira também a pasta de spam.'
                  : 'Informe o e-mail usado na sua conta. Enviaremos as orientações para definir uma nova senha.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!state.completed)
              TextField(
                controller: _email,
                enabled: !state.busy,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'E-mail da conta',
                  hintText: 'nome@exemplo.com',
                  errorText: state.errors['email'],
                ),
              ),
            if (!state.completed)
              const TeamCallout(
                child: Text(
                  'Não tem mais acesso a esse e-mail? Fale com o administrador do abrigo.',
                ),
              ),
            if (state.busy) const LinearProgressIndicator(),
            if (state.message != null)
              Text(state.message!, semanticsLabel: state.message),
          ],
        ),
      );
    },
  );
}
