import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crise_model.dart';
import '../repositories/crise_repository.dart';

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

class CriseNotifier extends Notifier<CriseState> {
  final CriseRepository _criseRepository = CriseRepository();
  Timer? _timer;
  DateTime? _inicioCrise;

  final int _maxCrisisDuration = 300;

  @override
  CriseState build() {
    return CriseState();
  }

  Future<void> toggleCrise() async {
    if (state.isActive) {
      await _stopCrisis();
    } else {
      _startCrisis();
    }
  }

  void _startCrisis() {
    _inicioCrise = DateTime.now();
    state = state.copyWith(isActive: true, secondsElapsed: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(secondsElapsed: state.secondsElapsed + 1);

      if (state.secondsElapsed >= _maxCrisisDuration) {
        _stopCrisis();
      }
    });
  }

  Future<void> _stopCrisis() async {
    if (!state.isActive) return;

    _timer?.cancel();
    final duracaoFinal = state.secondsElapsed;
    final inicio = _inicioCrise ?? DateTime.now();

    final crise = Crise(
      idPaciente: 1,
      dataHoraInicio: inicio,
      duracaoSegundos: duracaoFinal,
    );

    try {
      await _criseRepository.inserirCrise(crise);
    } catch (_) {}

    state = state.copyWith(
      isActive: false,
      secondsElapsed: 0,
      lastCrisisDuration: duracaoFinal,
    );
  }
}

final criseProvider = NotifierProvider<CriseNotifier, CriseState>(() {
  return CriseNotifier();
});