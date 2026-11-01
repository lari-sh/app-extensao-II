import '../../../core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import '../view_models/managed_animals_view_model.dart';

class ManagedAnimalsScreen extends StatelessWidget {
  const ManagedAnimalsScreen({super.key, required this.viewModel});
  final ManagedAnimalsViewModel viewModel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBackButton(),
      title: const Text('Animais do abrigo'),
      actions: [
        IconButton(
          tooltip: 'Atualizar animais',
          onPressed: () => viewModel.load(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(
        context,
        '/animal-editor',
      ).then((_) => viewModel.load()),
      icon: const Icon(Icons.add),
      label: const Text('Cadastrar animal'),
    ),
    body: ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text('${viewModel.state.total} animais cadastrados'),
          if (viewModel.state.loading) const LinearProgressIndicator(),
          if (viewModel.state.message != null) Text(viewModel.state.message!),
          for (final item in viewModel.state.items)
            Card(
              child: ListTile(
                title: Text(item.animal.name),
                subtitle: Text(item.animal.approximateAge),
                trailing: const Icon(Icons.edit),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/animal-editor',
                  arguments: item.animal.id,
                ).then((_) => viewModel.load()),
              ),
            ),
          if (viewModel.state.cursor != null)
            TextButton(
              onPressed: viewModel.state.loading
                  ? null
                  : () => viewModel.load(more: true),
              child: const Text('Carregar mais'),
            ),
        ],
      ),
    ),
  );
}
