import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app/widgets/botao_de_crise.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Botão de crise ativa, conta e para', (tester) async {
    // Aumenta a tela de teste (jeito novo do Flutter)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: BotaoDeCrise())),
        ),
      ),
    );

    // 1. Estado inicial: em repouso
    expect(find.text('CRISE EM ANDAMENTO'), findsNothing);
    expect(find.text('Toque para iniciar registro'), findsOneWidget);

    // 2. Toca no botão
    final botao = find.ancestor(
      of: find.text('Toque para iniciar registro'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(botao);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // 3. Estado ativo
    expect(find.text('CRISE EM ANDAMENTO'), findsOneWidget);
    expect(find.text('Toque para encerrar'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    // 4. Espera 2 segundos
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 5. Cronômetro mostra 00:02
    expect(find.text('00:02'), findsOneWidget);

    // 6. Para a crise (cancela o timer)
    final botaoParar = find.ancestor(
      of: find.text('Toque para encerrar'),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(botaoParar);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(seconds: 1));
  });
}