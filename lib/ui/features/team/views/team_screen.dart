import 'package:flutter/material.dart';
import '../../../../domain/models/team_access.dart';
import '../../../../domain/models/session_access.dart';
import '../view_models/team_view_model.dart';
import 'team_components.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key, required this.viewModel});
  final TeamViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      appBar: TeamHeader(
        context: context,
        title: 'Equipe',
        eyebrow: 'Administração',
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          children: [
            const Text(
              'Pessoas que ajudam a cuidar do abrigo. Gerencie os acessos em um só lugar.',
              style: TextStyle(color: teamMuted, fontSize: 13, height: 1.65),
            ),
            const SizedBox(height: 18),
            TeamButtonTheme(
              child: FilledButton.icon(
                onPressed: viewModel.canAct
                    ? () async {
                        await Navigator.pushNamed(context, '/team-invite');
                        await viewModel.load();
                      }
                    : null,
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Convidar pessoa'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 15),
              padding: const EdgeInsets.only(bottom: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: teamLine)),
              ),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final tab in TeamTab.values)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: teamBrown,
                        backgroundColor: viewModel.state.tab == tab
                            ? teamSoft
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: viewModel.canAct
                          ? () => viewModel.select(tab)
                          : null,
                      child: Text(
                        switch (tab) {
                          TeamTab.active => 'Ativos',
                          TeamTab.invitations => 'Convites',
                          TeamTab.inactive => 'Inativos',
                        },
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: viewModel.state.tab == tab
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (viewModel.state.loading || viewModel.state.busy)
              const LinearProgressIndicator(),
            if (viewModel.state.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(viewModel.state.message!),
              ),
            if (viewModel.state.uncertain)
              OutlinedButton(
                onPressed: viewModel.state.busy ? null : viewModel.reconcile,
                child: const Text('Consultar resultado'),
              ),
            for (final member in viewModel.state.members)
              _member(context, member),
            for (final invitation in viewModel.state.invitations)
              _invitation(context, invitation),
            if (!viewModel.state.loading &&
                viewModel.state.members.isEmpty &&
                viewModel.state.invitations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhuma pessoa nesta lista.'),
              ),
            if (viewModel.state.nextCursor != null)
              TextButton(
                onPressed: viewModel.state.loading
                    ? null
                    : () => viewModel.load(more: true),
                child: const Text('Carregar mais'),
              ),
            const TeamCallout(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cada pessoa usa sua própria conta.\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: teamBrown,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Assim, as aplicações de medicamentos ficam registradas com o nome de quem realizou.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _badge(String label, {bool active = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFEDF4ED) : teamSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: active ? const Color(0xFF307B55) : teamMuted,
      ),
    ),
  );
  Widget _card(
    String name,
    String email,
    String role,
    String status, {
    Widget? menu,
    Widget? actions,
    bool active = false,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: teamLine),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: teamSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                name.characters.first,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 11, color: teamMuted),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _badge(role),
                      _badge(status, active: active),
                    ],
                  ),
                ],
              ),
            ),
            ?menu,
          ],
        ),
        if (actions != null) ...[const SizedBox(height: 12), actions],
      ],
    ),
  );
  Widget _member(BuildContext context, TeamMember member) => _card(
    member.name,
    member.email,
    roleLabel(member.role),
    member.active ? 'Ativo' : 'Inativo',
    active: member.active,
    menu: PopupMenuButton<String>(
      enabled: viewModel.canEdit(member),
      tooltip: member.id == viewModel.currentUserId()
          ? 'Seu acesso'
          : 'Gerenciar ${member.name}',
      onSelected: (action) async {
        final role = action == 'role'
            ? (member.role == StaffRole.employee
                  ? StaffRole.administrator
                  : StaffRole.employee)
            : member.role;
        final active = action == 'active' ? !member.active : member.active;
        if (await _confirm(
          context,
          action == 'role'
              ? 'Alterar perfil de ${member.name} para ${roleLabel(role)}?'
              : '${active ? 'Restaurar' : 'Desativar'} acesso de ${member.name}?',
        )) {
          await viewModel.change(member, role, active);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'role', child: Text('Alterar perfil')),
        PopupMenuItem(
          value: 'active',
          child: Text(member.active ? 'Desativar acesso' : 'Restaurar acesso'),
        ),
      ],
    ),
  );
  Widget _invitation(BuildContext context, TeamInvitation invitation) => _card(
    invitation.name,
    invitation.email,
    roleLabel(invitation.role),
    switch (invitation.status) {
      'expired' => 'Expirado',
      'failed' => 'Falha no envio',
      'preparing' => 'Envio em andamento',
      _ => 'Convite pendente',
    },
    actions: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aguardando aceite · link válido por 1 hora',
          style: TextStyle(fontSize: 11, color: teamMuted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: viewModel.canAct && invitation.canResend
                  ? () => viewModel.resend(invitation)
                  : null,
              child: const Text(
                'Reenviar convite',
                style: TextStyle(fontSize: 11),
              ),
            ),
            OutlinedButton(
              onPressed: viewModel.canAct && invitation.canCancel
                  ? () async {
                      if (await _confirm(
                        context,
                        'Cancelar o convite de ${invitation.name}?',
                      )) {
                        await viewModel.cancel(invitation);
                      }
                    }
                  : null,
              child: const Text(
                'Cancelar convite',
                style: TextStyle(fontSize: 11, color: Color(0xFFC51D2A)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Future<bool> _confirm(BuildContext context, String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar alteração'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;
}
