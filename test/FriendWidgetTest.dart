import 'package:drp29/page_widgets/friend_page_widgets/FriendsPage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drp29/widgets/FriendWidget.dart';

void main() {
  // Define a test. The TestWidgets function also provides a WidgetTester
  // to work with. The WidgetTester allows you to build and interact
  // with widgets in the test environment.
  testWidgets("FriendsPage builds with FriendWidget", (WidgetTester tester) async {
    final friendsPage = FriendsPage();

    await tester.pumpWidget(friendsPage);

    var friendWidget = find.byType(FriendWidget);

    expect(friendWidget, findsNothing);
  });
}