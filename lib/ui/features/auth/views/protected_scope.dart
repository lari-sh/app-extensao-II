import '../../../core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import '../view_models/session_view_model.dart';
import '../view_models/login_view_model.dart';
import 'login_screen.dart';

/// The private factory runs only on a verified access event, never in build.
class ProtectedScope extends StatefulWidget {
  const ProtectedScope({
    super.key,
    required this.session,
    required this.login,
    required this.privateBuilder,
    this.requireTeamAdministrator = false,
  });
  final bool requireTeamAdministrator;
  final SessionViewModel session;
  final LoginViewModel login;
  final Widget Function() privateBuilder;
  @override
  State<ProtectedScope> createState() => _ProtectedScopeState();
}

class _ProtectedScopeState extends State<ProtectedScope> {
  Widget? _privateContent;
  int _generation = -1;
  void _synchronize() {
    final state = widget.session.state;
    if (state.privateGeneration != _generation) {
      _privateContent = null;
      _generation = state.privateGeneration;
    }
    if (!state.canAccessPrivate && !state.retainPrivate) {
      _privateContent = null;
    }
    if (state.canAccessPrivate &&
        (!widget.requireTeamAdministrator || state.canManageTeam) &&
        _privateContent == null) {
      _privateContent = KeyedSubtree(
        key: ValueKey(_generation),
        child: widget.privateBuilder(),
      );
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(_synchronize);
  }

  @override
  void initState() {
    super.initState();
    _synchronize();
    widget.session.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant ProtectedScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      _privateContent = null;
      _generation = -1;
      oldWidget.session.removeListener(_changed);
      widget.session.addListener(_changed);
    }
    _synchronize();
  }

  @override
  void dispose() {
    widget.session.removeListener(_changed);
    _privateContent = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.session.state.requiresReauthentication,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (widget.requireTeamAdministrator &&
            widget.session.state.canAccessPrivate &&
            !widget.session.state.canManageTeam)
          Scaffold(
            appBar: AppBar(
              leading: const AppBackButton(),
              title: const Text('Equipe'),
            ),
            body: const SafeArea(
              child: Center(
                child: Text(
                  'Somente administradores podem gerenciar a equipe.',
                ),
              ),
            ),
          ),
        if (_privateContent != null)
          Offstage(
            offstage: widget.session.state.hidePrivate,
            child: ExcludeSemantics(
              excluding: widget.session.state.hidePrivate,
              child: IgnorePointer(
                ignoring: widget.session.state.hidePrivate,
                child: _privateContent,
              ),
            ),
          ),
        if (!widget.session.state.canAccessPrivate)
          if (widget.session.state.phase == SessionPhase.checking &&
              !widget.session.state.requiresReauthentication)
            const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verificando acesso...'),
                  ],
                ),
              ),
            )
          else
            LoginScreen(
              viewModel: widget.login,
              navigateOnSuccess: false,
              onCancel: widget.session.state.requiresReauthentication
                  ? widget.session.cancelReauthentication
                  : null,
            ),
      ],
    ),
  );
}
