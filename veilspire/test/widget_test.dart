import 'package:flutter_test/flutter_test.dart';
import 'package:veilspire/main.dart';

void main() {
  testWidgets('title screen shows the game name', (tester) async {
    await tester.pumpWidget(const VeilspireApp());
    expect(find.text('VEILSPIRE'), findsOneWidget);
    expect(find.text('Enter the Veil'), findsOneWidget);
  });
}
