import '../../../core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import '../view_models/favorites_view_model.dart';
import '../../../core/widgets/public_animal_list.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.viewModel});
  final FavoritesViewModel viewModel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBackButton(),
      title: const Text('Favoritos'),
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PublicAnimalList(
              viewModel: viewModel,
              emptyMessage: 'Você ainda não tem favoritos disponíveis.',
            ),
          ],
        ),
      ),
    ),
  );
}
