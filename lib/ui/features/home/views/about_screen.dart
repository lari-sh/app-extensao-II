import '../../../core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/shelter_channel.dart';
import '../view_models/about_view_model.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.viewModel});
  final AboutViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(viewModel.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Image.asset('assets/images/logo.png', height: 140),
            const SizedBox(height: 24),
            Text(viewModel.body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('Doe via Pix', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Sua doação ajuda a cuidar dos animais do abrigo.'),
            const SizedBox(height: 12),
            SelectableText(
              viewModel.pixKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: viewModel.busy ? null : viewModel.copyPix,
              icon: const Icon(Icons.copy),
              label: const Text('Copiar chave Pix'),
            ),
            if (viewModel.message case final message?)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(liveRegion: true, child: Text(message)),
              ),
            const SizedBox(height: 24),
            Text(
              'Contato e redes sociais',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _contact(
              'WhatsApp',
              '(34) 99137-8936',
              Icons.chat_outlined,
              ShelterChannel.whatsapp,
            ),
            _contact(
              'Instagram',
              '@abrigodosanjosoficial',
              Icons.camera_alt_outlined,
              ShelterChannel.instagram,
            ),
            _contact(
              'Facebook',
              'Abrigo dos Anjos',
              Icons.facebook,
              ShelterChannel.facebook,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.popUntil(
                context,
                ModalRoute.withName(viewModel.close()),
              ),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _contact(
    String title,
    String subtitle,
    IconData icon,
    ShelterChannel channel,
  ) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: viewModel.busy ? null : () => viewModel.openContact(channel),
    ),
  );
}
