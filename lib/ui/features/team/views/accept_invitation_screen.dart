import 'package:flutter/material.dart';
import 'team_components.dart';
import '../view_models/accept_invitation_view_model.dart';
import '../view_models/team_view_model.dart' show roleLabel;

class AcceptInvitationScreen extends StatefulWidget {
  const AcceptInvitationScreen({super.key, required this.viewModel});
  final AcceptInvitationViewModel viewModel;
  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  final _password = TextEditingController(),
      _confirmation = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final vm = widget.viewModel,
          state = vm.state,
          invitation = state.invitation;
      return Scaffold(
        appBar: TeamHeader(
          context: context,
          title: 'Seu acesso ao abrigo',
          eyebrow: 'Convite da equipe',
          enabled: !state.busy,
        ),
        bottomNavigationBar: TeamFooter(
          child: state.accepted
              ? FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => route.isFirst,
                  ),
                  child: const Text('Ir para o login'),
                )
              : invitation?.canAccept == true
              ? FilledButton(
                  onPressed: vm.canSubmit
                      ? () async {
                          FocusScope.of(context).unfocus();
                          await vm.submit(_password.text, _confirmation.text);
                          if (mounted && vm.state.passwordSaved) {
                            _password.clear();
                            _confirmation.clear();
                          }
                        }
                      : null,
                  child: Text(
                    state.passwordSaved
                        ? 'Concluir aceite'
                        : 'Definir senha e aceitar',
                  ),
                )
              : !state.loading
              ? OutlinedButton(
                  onPressed: vm.load,
                  child: const Text('Verificar convite'),
                )
              : const SizedBox.shrink(),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Você foi convidado!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Faça parte da equipe do Abrigo dos Anjos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (state.loading || state.busy) const LinearProgressIndicator(),
            if (invitation != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EAE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(invitation.email),
                    const SizedBox(height: 8),
                    Text(roleLabel(invitation.role)),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (vm.canSubmit && !state.passwordSaved) ...[
              TextField(
                controller: _password,
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
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha',
                  errorText: state.errors['confirmation'],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (state.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(state.message!),
              ),
          ],
        ),
      );
    },
  );
}
