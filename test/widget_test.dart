import 'package:flutter_test/flutter_test.dart';

import 'package:tekken_move_guide/main.dart';

void main() {
  testWidgets('home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TekkenMoveGuideApp());

    expect(find.text('Tekken 8 Move Guide'), findsOneWidget);
  });
}

