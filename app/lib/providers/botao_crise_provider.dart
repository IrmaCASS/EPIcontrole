import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Notifier: Contém apenas a lógica do cronômetro.
// A persistência no banco é responsabilidade da tela de Registro de Crise.
class CriseNotifier extends Notifier<CriseState> {
  Timer? _timer;

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

    // TODO: Chamar AlertaService para enviar SMS ou GPS aos contatos
    // TODO: Chamar AudioService para tocar o alarme sonoro local

    // Inicia o cronômetro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(secondsElapsed: state.secondsElapsed + 1);

      if (state.secondsElapsed >= _maxCrisisDuration) {
        _stopCrisis();
      }
    });
  }

  void _stopCrisis() {
    _timer?.cancel();

    final duracaoFinal = state.secondsElapsed;

    // TODO: Parar a reprodução do AudioService

    // NÃO salva nada no banco aqui. Apenas guarda a duração final no state,
    // para que a tela de Registro de Crise possa pré-preencher o formulário.
    // O salvamento real (INSERT) é feito quando o usuário clicar em
    // "SALVAR REGISTRO" na tela de RegistroCriseScreen.
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
