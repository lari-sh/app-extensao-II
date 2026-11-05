import 'package:flutter/material.dart';
import '../../../../domain/models/session_access.dart';
import 'team_components.dart';
import '../view_models/team_view_model.dart';

class InviteMemberScreen extends StatefulWidget {
  const InviteMemberScreen({super.key, required this.viewModel});
  final InviteMemberViewModel viewModel;
  @override
  State<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  final _name = TextEditingController(), _email = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
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
          title: 'Convidar pessoa',
          eyebrow: 'Equipe',
          enabled: !state.busy,
        ),
        bottomNavigationBar: TeamFooter(
          child: state.uncertain
              ? FilledButton(
                  onPressed: state.busy ? null : vm.reconcile,
                  child: const Text('Consultar envio'),
                )
              : state.sent
              ? FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Voltar para equipe'),
                )
              : FilledButton(
                  onPressed: vm.canEdit
                      ? () async {
                          FocusScope.of(context).unfocus();
                          await vm.submit(_name.text, _email.text);
                        }
                      : null,
                  child: const Text('Enviar convite'),
                ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          children: [
            const Text(
              'Envie um convite para alguém fazer parte da equipe. A pessoa vai definir a própria senha.',
              style: TextStyle(color: teamMuted, fontSize: 13, height: 1.65),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _name,
              enabled: vm.canEdit,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nome completo',
                errorText: state.errors['name'],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              enabled: vm.canEdit,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'E-mail',
                errorText: state.errors['email'],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Perfil de acesso',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final role in const [
              StaffRole.employee,
              StaffRole.administrator,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: state.role == role
                        ? const Color(0xFFF6EAE5)
                        : Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: vm.canEdit ? () => vm.selectRole(role) : null,
                  child: Row(
                    children: [
                      Icon(
                        state.role == role
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roleLabel(role),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              role == StaffRole.employee
                                  ? 'Cuida dos animais, fotos e medicações.'
                                  : 'Também convida pessoas e gerencia os acessos.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const TeamCallout(
              child: Text(
                'O acesso só será liberado depois que a pessoa aceitar o convite. O link vale por 1 hora.',
              ),
            ),
            const SizedBox(height: 24),
            if (state.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(state.message!),
              ),
            if (state.busy) const LinearProgressIndicator(),
          ],
        ),
      );
    },
  );
}
