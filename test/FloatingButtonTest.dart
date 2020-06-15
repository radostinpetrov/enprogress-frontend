import 'package:EnProgress/page_widgets/TasksPage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:EnProgress/widgets/FloatingButton.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets("TasksPage builds with no FloatingButton", (WidgetTester tester) async {
    final tasksPage = TasksPage();

    await tester.pumpWidget(tasksPage);

    var floatingButton = find.byType(FloatingButton);

    expect(floatingButton, findsNothing);
  });
}