import 'package:drp29/page_widgets/TasksPage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drp29/widgets/TaskWidget.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets("TasksPage builds with TaskWidget", (WidgetTester tester) async {
    final tasksPage = TasksPage();

    await tester.pumpWidget(tasksPage);

    var taskWidget = find.byType(TaskWidget);

    expect(taskWidget, findsNothing);
  });
}