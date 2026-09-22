import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

import 'package:app/database/tables.dart';
import 'package:app/providers/registro_crise_provider.dart';
import 'package:app/repositories/crise_repository.dart';
import 'package:app/screens/registro_crise_screen.dart';

void main() {
  late Database db;
  late CriseRepository repository;

  setUpAll(() {
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

  testWidgets('SALVAR REGISTRO insere a crise no banco (RF1)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [criseRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).push(RegistroCriseScreen.route()),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.pump();

    await tester.ensureVisible(find.text('SALVAR REGISTRO'));
    await tester.pump();
    await tester.tap(find.text('SALVAR REGISTRO'));
    await tester.pump();

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    final crises = (await tester.runAsync(
      () => repository.buscarUltimasCrises(),
    ))!;
    expect(crises.length, 1);
    expect(crises.first.duracao?.inSeconds, 90);
  });
}
