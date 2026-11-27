import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_state.dart';
import 'package:pokedex/features/trivia/presentation/mappers/trivia_view_mapper.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_no_data_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_question_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_result_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_reveal_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Una partida completa. Muestra la pantalla que corresponde al estado del
/// [TriviaGameCubit]: la navegación entre pasos es un cambio de estado.
class TriviaPlayPage extends StatefulWidget {
  const TriviaPlayPage({super.key});

  @override
  State<TriviaPlayPage> createState() => _TriviaPlayPageState();
}

class _TriviaPlayPageState extends State<TriviaPlayPage> {
  // El campo de texto vive aquí para que no se pierda al reconstruir.
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TriviaGameCubit>();
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<TriviaGameCubit, TriviaGameState>(
      // Al empezar una pregunta nueva, el campo se vacía.
      listenWhen: (previous, current) =>
          current is TriviaGameQuestion &&
          (previous is! TriviaGameQuestion || previous.index != current.index),
      listener: (context, state) => _controller.clear(),
      builder: (context, state) {
        // Con la partida en curso, salir pide confirmación (no se guarda nada).
        final inProgress =
            state is TriviaGameQuestion || state is TriviaGameRevealed;

        return PopScope(
          canPop: !inProgress,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _askToLeave();
          },
          child: _page(context, state, cubit, l10n),
        );
      },
    );
  }

  /// Pregunta si de verdad quiere salir. El reloj se pausa mientras tanto.
  Future<void> _askToLeave() async {
    final cubit = context.read<TriviaGameCubit>();
    cubit.pause();

    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.triviaExitTitle),
          content: Text(l10n.triviaExitMessage),
          actions: [
            // Lo seguro (seguir jugando) es lo que queda enfocado.
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.triviaExitStay),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.triviaExitLeave),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (leave == true) {
      // go() reemplaza la pila y no pasa por PopScope: sale sin preguntar otra vez.
      context.go(AppRoutes.trivia);
    } else {
      cubit.resume();
    }
  }

  Widget _page(
    BuildContext context,
    TriviaGameState state,
    TriviaGameCubit cubit,
    AppLocalizations l10n,
  ) {
    switch (state) {
      case TriviaGameLoading():
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.loading),
          ),
        );
      case TriviaGameNotEnoughData():
        return TriviaNoDataPage(
          data: TriviaNoDataData(
            saved: state.available,
            required: TriviaRules.minPokemonToPlay,
          ),
          onGoCatalog: () => context.go(AppRoutes.catalog),
          onRetry: cubit.start,
        );
      case TriviaGameQuestion():
        return TriviaQuestionPage(
          data: questionData(state),
          controller: _controller,
          onGuess: () => cubit.submitAnswer(_controller.text),
          onHint: cubit.useHint,
          onSkip: cubit.skip,
          onImageReady: cubit.imageReady,
        );
      case TriviaGameRevealed():
        return TriviaRevealPage(
          kind: state.outcome == TriviaOutcome.correct
              ? TriviaRevealKind.correct
              : TriviaRevealKind.timeUp,
          data: revealData(state),
          onNext: cubit.next,
        );
      case TriviaGameFinished():
        return TriviaResultPage(
          data: resultData(state, l10n),
          onPlayAgain: cubit.start,
          onRanking: () => context.go(AppRoutes.triviaRanking),
          onHome: () => context.go(AppRoutes.trivia),
        );
    }
  }
}
