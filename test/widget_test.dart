import 'package:flutter_test/flutter_test.dart';
import 'package:poop_diary/main.dart';

void main() {
  testWidgets('mostra la home', (tester) async {
    await tester.pumpWidget(const PoopDiaryApp());
    expect(find.text('Poop Diary'), findsOneWidget);
  });
}
