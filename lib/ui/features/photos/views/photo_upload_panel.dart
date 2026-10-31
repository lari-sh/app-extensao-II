import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../view_models/photo_upload_view_model.dart';

class PhotoUploadPanel extends StatelessWidget {
  const PhotoUploadPanel({super.key, required this.viewModel});
  final PhotoUploadViewModel viewModel;
  Widget _image(List<int> bytes, String key) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.memory(
      Uint8List.fromList(bytes),
      key: ValueKey(key),
      height: 180,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Não foi possível visualizar a imagem.'),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final state = viewModel.state;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Foto do animal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (state.image != null)
                _image(state.image!.bytes, 'currentAnimalPhoto')
              else
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.pets, size: 64),
                ),
              const SizedBox(height: 12),
              Text(viewModel.guidance),
              OutlinedButton.icon(
                onPressed: viewModel.canSelect ? viewModel.pick : null,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Selecionar foto'),
              ),
              if (viewModel.canRecover)
                TextButton(
                  onPressed: viewModel.useRecovered,
                  child: const Text('Usar foto recuperada neste animal'),
                ),
              if (state.candidate != null) ...[
                const SizedBox(height: 12),
                const Text('Nova foto, ainda não enviada'),
                const SizedBox(height: 8),
                _image(state.candidate!.bytes, 'selectedAnimalPhoto'),
                FilledButton(
                  onPressed: viewModel.canUpload ? viewModel.upload : null,
                  child: const Text('Confirmar envio da foto'),
                ),
              ],
              if (state.busy) const LinearProgressIndicator(),
              if (state.message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(state.message!),
                ),
              if (state.uncertain)
                OutlinedButton(
                  onPressed: state.busy ? null : viewModel.reconcile,
                  child: const Text('Verificar envio da foto'),
                ),
              if (state.canRetry)
                TextButton(
                  onPressed: state.busy ? null : viewModel.retry,
                  child: const Text('Tentar enviar novamente'),
                ),
            ],
          ),
        ),
      );
    },
  );
}
