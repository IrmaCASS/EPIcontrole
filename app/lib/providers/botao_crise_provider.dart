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

  // Metodo auxiliar para atualizar o estado mantendo o que não mudou
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

  // Tempo limite de segurança de 5 minutos (300 segundos)
  final int _maxCrisisDuration = 300;

  @override
  CriseState build() {
    // Estado inicial: crise inativa, 0 segundos
    return CriseState();
  }

  // Função principal chamada pelo Botão
  void toggleCrise() {
    if (state.isActive) {
      _stopCrisis();
    } else {
      _startCrisis();
    }
  }

  void _startCrisis() {
    // Muda o estado para ativo
    state = state.copyWith(isActive: true, secondsElapsed: 0);

    // TODO: Chamar AlertaService para enviar SMS ou GPS aos contatos
    // TODO: Chamar AudioService para tocar o alarme sonoro local

    // Inicia o cronômetro
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(secondsElapsed: state.secondsElapsed + 1);

      // Interrupção automática ao atingir tempo limite
      if (state.secondsElapsed >= _maxCrisisDuration) {
        _stopCrisis();
      }
    });
  }

  void _stopCrisis() {
    _timer?.cancel();

    // Armazena a duração final da crise (em segundos) para o back end persistir.
    final duracaoFinal = state.secondsElapsed;

    // TODO: Parar a reprodução do AudioService
    // TODO: Chamar o DatabaseService/Repository para salvar a nova crise no SQLite
    // usando o último estado (isActive, duracaoFinal) como contrato de dados.

    // Guarda a duração no estado para futura persistência/navegação.
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