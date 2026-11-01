import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../view_models/animal_detail_view_model.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({super.key, required this.viewModel});
  final AnimalDetailViewModel viewModel;
  static const _brown = Color(0xFF45180D),
      _muted = Color(0xFF795C52),
      _soft = Color(0xFFF6EAE5),
      _border = Color(0xFFEADDD7);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: const ColoredBox(color: Color(0x8C140F0A)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Material(
                      key: const ValueKey('publicAnimalSheet'),
                      color: Colors.white,
                      child: LayoutBuilder(
                        builder: (context, constraints) => Column(
                          children: [
                            if (viewModel.state.hasAnimal)
                              SizedBox(
                                height: math.min(
                                  constraints.maxWidth * 0.75,
                                  constraints.maxHeight * 0.43,
                                ),
                                width: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ColoredBox(
                                      color: _soft,
                                      child: viewModel.state.photo == null
                                          ? _placeholder()
                                          : Image.memory(
                                              Uint8List.fromList(
                                                viewModel.state.photo!,
                                              ),
                                              fit: BoxFit.cover,
                                              semanticLabel:
                                                  'Foto de ${viewModel.state.title}',
                                              errorBuilder: (_, _, _) =>
                                                  _placeholder(),
                                            ),
                                    ),
                                    if (viewModel.state.photo != null)
                                      const Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: SizedBox.square(
                                              dimension: 6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: _close(context),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: _close(context),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  18,
                                  18,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (viewModel.state.busy)
                                      const LinearProgressIndicator(),
                                    if (viewModel.state.hasAnimal) ...[
                                      Text(
                                        viewModel.state.title,
                                        style: const TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 26,
                                          height: 1.1,
                                          color: _brown,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (final tag
                                              in viewModel.state.tags)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _soft,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                tag,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: _brown,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        viewModel.state.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.55,
                                          color: _muted,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        viewModel.state.statusLabel,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _brown,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      LayoutBuilder(
                                        builder: (context, width) => Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (final info
                                                in viewModel
                                                    .state
                                                    .publicInformation
                                                    .entries)
                                              SizedBox(
                                                width: (width.maxWidth - 8) / 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _soft,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        info.key,
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                          letterSpacing: 0.6,
                                                          color: _muted,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        info.value,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _brown,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    if (viewModel.state.message != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          viewModel.state.message!,
                                          style: const TextStyle(color: _brown),
                                        ),
                                      ),
                                    if (!viewModel.state.hasAnimal &&
                                        !viewModel.state.busy)
                                      TextButton.icon(
                                        onPressed: viewModel.reload,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Tentar novamente'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (viewModel.state.hasAnimal)
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  12,
                                  18,
                                  18,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: _border),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FilledButton(
                                      onPressed:
                                          !viewModel.state.canAdopt ||
                                              viewModel.state.copying
                                          ? null
                                          : viewModel.copyInterest,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFC51D2A,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Entrar em contato para adoção',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      viewModel.contactHint,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _placeholder() => Center(
    child: Semantics(
      label: 'Foto indisponível',
      child: const Icon(
        Icons.pets_outlined,
        size: 110,
        color: Color(0xFFC51D2A),
      ),
    ),
  );
  Widget _close(BuildContext context) => IconButton.filledTonal(
    tooltip: 'Fechar detalhes',
    style: IconButton.styleFrom(
      backgroundColor: const Color(0xE6FFFFFF),
      foregroundColor: _brown,
    ),
    onPressed: () => Navigator.maybePop(context),
    icon: const Icon(Icons.close, size: 18),
  );
}
