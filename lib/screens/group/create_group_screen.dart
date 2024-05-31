import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatelessWidget {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _groupTypeController,
              decoration: InputDecoration(labelText: 'Group Type'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String groupName = _groupNameController.text.trim();
                String groupType = _groupTypeController.text.trim();
                if (groupName.isNotEmpty && groupType.isNotEmpty) {
                  try {
                    HabitWiseGroup newGroup = HabitWiseGroup(
                      groupId: '', // This will be set in the database
                      groupName: groupName,
                      members: [],
                      goals: [],
                      habits: [],
                      groupType: groupType,
                      groupPictureUrl: null,
                    );
                    await Provider.of<GroupProvider>(context, listen: false).createGroup(newGroup);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Group created successfully!'),
                      duration: Duration(seconds: 2),
                    ));
                    // Navigate back to the dashboard
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error creating group: $e'),
                      duration: Duration(seconds: 2),
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill in all fields.'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
