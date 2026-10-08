import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/medicamento_repository.dart';

final medicamentoRepositoryProvider = Provider<MedicamentoRepository>((ref) {
  return MedicamentoRepository();
});