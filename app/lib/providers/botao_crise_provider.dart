import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/crise_model.dart';
import 'package:app/repositories/crise_repository.dart';

// Classe de Estado: Guarda as variáveis que a tela precisa ler
class CriseState {
  final bool isActive;
  final int secondsElapsed;
  final int lastCrisisDuration;

  CriseState({
    this.isActive = false,
    this.secondsElapsed = 0,
    this.lastCrisisDuration = 0,
  });

  CriseState copyWith({
    bool? isActive,
    int? secondsElapsed,
    int? lastCrisisDuration,
  }) {
    return CriseState(
      isActive: isActive ?? this.isActive,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      lastCrisisDuration: lastCrisisDuration ?? this.lastCrisisDuration,
    );
  }
}

// Notifier: Contém a lógica de negócio (Cronômetro, Salvar DB, SMS)
class CriseNotifier extends Notifier<CriseState> {
  Timer? _timer;

  final _criseRepository = CriseRepository();

  // Tempo limite de segurança de 5 minutos (300 segundos)
  final int _maxCrisisDuration = 300;

  @override
  CriseState build() {
    return CriseState();
  }

  void toggleCrise() {
    if (state.isActive) {
      _stopCrisis();
    } else {
      _startCrisis();
    }
  }

  void _startCrisis() {
    state = state.copyWith(isActive: true, secondsElapsed: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(secondsElapsed: state.secondsElapsed + 1);

      if (state.secondsElapsed >= _maxCrisisDuration) {
        _stopCrisis();
      }
    });
  }

  Future<void> _stopCrisis() async {
    _timer?.cancel();

    final duracaoFinal = state.secondsElapsed;

    // Salva a crise no banco (só se durou pelo menos 1 segundo)
    if (duracaoFinal > 0) {
      try {
        final novaCrise = CriseModel(
          dataHoraInicio: DateTime.now().subtract(
            Duration(seconds: duracaoFinal),
          ),
          duracao: Duration(seconds: duracaoFinal),
        );
        await _criseRepository.inserirCrise(novaCrise);
      } catch (e) {
        // Se der erro no banco, não deixa o app travar
        // ignore: avoid_print
        print('Erro ao salvar crise: $e');
      }
    }

    state = state.copyWith(
      isActive: false,
      secondsElapsed: 0,
      lastCrisisDuration: duracaoFinal,
    );
  }
}

// variável global do Provider que será lida pela tela
final criseProvider = NotifierProvider<CriseNotifier, CriseState>(() {
  return CriseNotifier();
});