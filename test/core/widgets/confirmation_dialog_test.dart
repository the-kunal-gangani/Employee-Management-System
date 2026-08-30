import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:employee_management_system/core/widgets/confirmation_dialog.dart';

void main() {
  Widget buildSubject({required VoidCallback onPressed}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: onPressed,
              child: const Text('Delete employee'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('shows title, message, and both actions when opened', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await ConfirmationDialog.show(
                    context,
                    title: 'Delete employee',
                    message:
                        'Are you sure you want to delete Jane Doe? This cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete employee'), findsOneWidget);
    expect(
      find.text(
        'Are you sure you want to delete Jane Doe? This cannot be undone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('tapping Cancel dismisses the dialog and resolves false', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await ConfirmationDialog.show(
                    context,
                    title: 'Delete employee',
                    message: 'Are you sure?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete employee'), findsNothing);
    expect(result, isFalse);
  });

  testWidgets('tapping Delete dismisses the dialog and resolves true', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await ConfirmationDialog.show(
                    context,
                    title: 'Delete employee',
                    message: 'Are you sure?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete employee'), findsNothing);
    expect(result, isTrue);
  });

  testWidgets(
    'dismissing without a choice (barrier tap) resolves false via show()',
    (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await ConfirmationDialog.show(
                      context,
                      title: 'Delete employee',
                      message: 'Are you sure?',
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the scrim outside the dialog to dismiss without choosing.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Delete employee'), findsNothing);
      expect(result, isFalse);
    },
  );
}
