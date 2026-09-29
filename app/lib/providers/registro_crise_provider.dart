import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/crise_repository.dart';
import '../repositories/diario_repository.dart';

/// Provider do CriseRepository para a tela de Registro de Crise usar.
final criseRepositoryProvider = Provider<CriseRepository>((ref) {
  return CriseRepository();
});

/// Provider do DiarioRepository (catálogos, entidade diario e relações N:N).
final diarioRepositoryProvider = Provider<DiarioRepository>((ref) {
  return DiarioRepository();
});

/// Provider que sinaliza quando um novo registro foi salvo.
/// A tela de Diário escuta isso para recarregar a lista automaticamente.
final refreshDiarioProvider = StateProvider<int>((ref) => 0);
