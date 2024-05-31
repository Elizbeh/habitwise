import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/services/group_db_service.dart';

class GroupDetailsScreen extends StatelessWidget {
  final GroupDBService _groupDBService = GroupDBService();

  GroupDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    final String groupId = args;

    return Scaffold(
      appBar: AppBar(title: Text('Group Details')),
      body: FutureBuilder<HabitWiseGroup>(
        future: _groupDBService.getGroupById(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Group not found'));
          } else {
            HabitWiseGroup group = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Group Name: ${group.groupName}'),
                  SizedBox(height: 8.0),
                  Text('Group Type: ${group.groupType}'),
                  SizedBox(height: 8.0),
                  Text('Members: ${group.members.join(', ')}'),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _groupDBService.joinGroup(group.groupId, 'userId');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Joined group successfully!'),
                          duration: Duration(seconds: 2),
                        ));
                        // Implement logic to update UI or navigate to another screen
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error joining group: $e'),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                    child: Text('Join Group'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _groupDBService.leaveGroup(group.groupId, 'userId');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Left group successfully!'),
                          duration: Duration(seconds: 2),
                        ));
                        // Implement logic to update UI or navigate to another screen
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error leaving group: $e'),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                    child: Text('Leave Group'),
                  ),
                  // Add buttons to view group goals/habits
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
