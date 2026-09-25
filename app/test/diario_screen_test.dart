import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

import 'package:app/database/tables.dart';
import 'package:app/providers/registro_crise_provider.dart';
import 'package:app/repositories/crise_repository.dart';
import 'package:app/screens/diario_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late Database db;
  late CriseRepository repository;

  setUpAll(() {
    initializeDateFormatting('pt_BR');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute(AppDatabaseTables.paciente);
    await db.execute(AppDatabaseTables.crise);
    await db.insert('paciente', {
      'id_paciente': 1,
      'nome': 'Paciente Teste',
      'data_cadastro': DateTime.now().toIso8601String(),
    });
    repository = CriseRepository(databaseProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('diário mostra as crises reais do dia selecionado', (
    tester,
  ) async {
    final agora = DateTime.now();
    await db.insert('crise', {
      'id_paciente': 1,
      'data_hora_inicio': agora.toIso8601String(),
      'duracao_segundos': 150,
      'tipo_crise': 'Focal',
    });

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [criseRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: DiarioScreen()),
      ),
    );

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(find.text('Registros de Crises'), findsOneWidget);
    expect(find.text('Focal'), findsOneWidget);
  });
}
