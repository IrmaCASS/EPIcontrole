import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/crise_repository.dart';

/// Provider do CriseRepository para a tela de Registro de Crise usar.
final criseRepositoryProvider = Provider<CriseRepository>((ref) {
  return CriseRepository();
});
