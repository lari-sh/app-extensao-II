import 'package:flutter/material.dart';
import '../view_models/adoption_contact_view_model.dart';

class AdoptionContactScreen extends StatelessWidget {
  const AdoptionContactScreen({super.key, required this.viewModel});
  final AdoptionContactViewModel viewModel;
  static const _brown = Color(0xFF451A0D),
      _muted = Color(0xFF795C52),
      _border = Color(0xFFEADDD7),
      _soft = Color(0xFFF6EAE5);
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFFCFA),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Voltar à ficha do animal',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADOÇÃO RESPONSÁVEL',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: Color(0xFFC51D2A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fale com o abrigo',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 92,
                      height: 92,
                      semanticLabel: 'Abrigo dos Anjos — Humanizando Vidas',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Que bom que você quer dar um novo lar! Escolha um dos canais oficiais para conversar com nossa equipe sobre a adoção.',
                    style: TextStyle(fontSize: 13, height: 1.6, color: _muted),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _soft,
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Color(0xFFC51D2A),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tenho interesse em adotar',
                                style: TextStyle(fontSize: 10, color: _muted),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                viewModel.state.animalName,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _brown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'CONVERSE COM A NOSSA EQUIPE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: .8,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (viewModel.state.loading || viewModel.state.opening)
                    const LinearProgressIndicator(),
                  _channel(
                    'WhatsApp',
                    '(34) 99137-8936',
                    Icons.chat_outlined,
                    viewModel.openWhatsApp,
                  ),
                  const SizedBox(height: 10),
                  _channel(
                    'Instagram',
                    '@abrigodosanjosoficial',
                    Icons.camera_alt_outlined,
                    viewModel.openInstagram,
                  ),
                  const SizedBox(height: 10),
                  _channel(
                    'Facebook',
                    '/abrigodosanjosura',
                    Icons.facebook,
                    viewModel.openFacebook,
                  ),
                  if (viewModel.state.message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          Text(
                            viewModel.state.message!,
                            style: const TextStyle(color: _muted),
                          ),
                          TextButton(
                            onPressed: viewModel.state.opening
                                ? null
                                : viewModel.retry,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 22),
                  const Divider(color: _border),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.state.contactNotice,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.6,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(13),
                      foregroundColor: _brown,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Voltar à ficha do animal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _channel(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback action,
  ) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: _border),
      borderRadius: BorderRadius.circular(14),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: viewModel.state.canContact && !viewModel.state.opening
          ? action
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFC51D2A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _brown,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 17, color: _muted),
          ],
        ),
      ),
    ),
  );
}
