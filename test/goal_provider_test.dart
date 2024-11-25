import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:mockito/annotations.dart';
import 'goal_provider_test.mocks.dart';

// Generate mocks using mockito
@GenerateMocks([GoalDBService])
void main() {
  group('GoalProvider', () {
    late MockGoalDBService mockGoalDBService;
    late GoalProvider goalProvider;
    const String userId = 'testUser';

    setUp(() {
      mockGoalDBService = MockGoalDBService();
      goalProvider = GoalProvider(userId: userId);
      
    });

    test('addGoal calls addGoal on GoalDBService and updates the list', () async {
      final Goal newGoal = Goal(
        id: 'goal1',
        title: 'Test Goal',
        description: 'A test goal description',
        category: 'Work',
        priority: 1,
        progress: 0,
        target: 100,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        isCompleted: false,
      );

      // Mocking the addGoal method to simulate database behavior
      when(mockGoalDBService.addGoal(userId, newGoal)).thenAnswer((_) async => null);

      await goalProvider.addGoal(newGoal);

      // Verify that the addGoal method was called once
      verify(mockGoalDBService.addGoal(userId, newGoal)).called(1);

      // The provider should notify listeners after adding a goal
      expect(goalProvider.goals, contains(newGoal));
    });

    // Additional test cases for other functionalities can go here
  });
}
