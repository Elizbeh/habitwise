import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/providers/goal_provider.dart';
import 'package:habitwise/screens/dialogs/add_goal_dialog.dart';
import 'package:habitwise/screens/dialogs/add_habit_dialog.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
import 'package:habitwise/themes/theme.dart'; // Assuming your custom theme is here
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/services/goals_db_service.dart';
import 'package:provider/provider.dart';

class GroupInfoSection extends StatefulWidget {
  final HabitWiseGroup group;
  final String creatorName;
  final bool isAdmin;

  final void Function(String) onMemberRemoved;
  final void Function() onEditGroupInfo;

  GroupInfoSection({
    required this.group,
    required this.creatorName,
    required this.isAdmin,
    required this.onMemberRemoved,
    required this.onEditGroupInfo,
  });

  @override
  _GroupInfoSectionState createState() => _GroupInfoSectionState();
}

class _GroupInfoSectionState extends State<GroupInfoSection> {
  void _confirmMemberRemoval(String memberId) {
    // confirmation dialog code...
  }

  void _showMemberDetails(Member member) {
  _showDetailDialog(
    title: '${member.name ?? 'Member Details'}${member.id == widget.group.creatorId ? " (Admin)" : ""}',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundImage: member.profilePictureUrl != null
              ? NetworkImage(member.profilePictureUrl!)
              : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
          radius: 60,
        ),
        SizedBox(height: 16.0),
        Text('Username: ${member.name}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),), // Add this line
        SizedBox(height: 8.0),
        Text('Email: ${member.email}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),
        ),
        SizedBox(height: 8.0),
        Text(
          'Joined on: ${DateFormat('yyyy-MM-dd').format(member.joinedDate ?? DateTime.now())}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Close', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),),
      ),
      if (widget.isAdmin && member.id != widget.group.creatorId)
        TextButton(
          onPressed: () {
            _confirmMemberRemoval(member.id);
            Navigator.of(context).pop();
          },
          child: Text('Remove', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),),
        ),
    ],
  );
}
  void _showDetailDialog({
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          contentPadding: EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
            ),
          ),
          content: SizedBox(width: 300, child: content),
          actions: actions,
        );
      },
    );
  }

  void _showMembersList() {
  _showDetailDialog(
    title: 'Members (${widget.group.members.length})',
    content: Container(
      width: 300,
      height: 400,
      child: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          final member = widget.group.members[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: member.profilePictureUrl != null
                    ? NetworkImage(member.profilePictureUrl!)
                    : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
              ),
              title: Text(
                '${member.name ?? 'No Name'}${member.id == widget.group.creatorId ? " (Admin)" : "(Member)"}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),
              ),
              onTap: () => _showMemberDetails(member),
              trailing: widget.isAdmin && member.id != widget.group.creatorId
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800], // Background color for contrast
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmMemberRemoval(member.id);
                        },
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Close', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,),),
      ),
    ],
  );
}

  Stream<List<Goal>> _fetchGoals() {
    return GoalDBService().getGroupGoalsStream(widget.group.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: group.groupPictureUrl != null && group.groupPictureUrl!.isNotEmpty
                    ? NetworkImage(group.groupPictureUrl!)
                    : const AssetImage('assets/images/default_profilePic.png') as ImageProvider,
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${group.groupType ?? 'Group Type'}',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Created by ${widget.creatorName} on ${DateFormat('yyyy-MM-dd').format(group.creationDate ?? DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
              if (widget.isAdmin)
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                  onPressed: widget.onEditGroupInfo,
                ),
            ],
          ),
          // Goals Section
          StreamBuilder<List<Goal>>(
            stream: _fetchGoals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 50,
                        color: Color.fromRGBO(46, 197, 187, 1.0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No goals yet! Start setting up some goals and track your progress here.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                     
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your group’s success and stay motivated!',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );

            } else {
              final goals = snapshot.data!;
              final completedGoals = goals.where((goal) => goal.isCompleted).length;
              final totalGoals = goals.length;
              final completionPercentage = totalGoals > 0 ? completedGoals / totalGoals : 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('Total Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('$totalGoals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CircularPercentIndicator(
                          radius: 60.0, // Smaller size for a compact layout
                          lineWidth: 10.0,
                          percent: completionPercentage,
                          center: Text(
                            '${(completionPercentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          progressColor: Color.fromRGBO(46, 197, 187, 1.0),
                          backgroundColor: Colors.grey[300]!,
                        ),
                      ),
                      Column(
                        children: [
                          Text('In Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${goals.length - completedGoals}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        SizedBox(height: 8.0),
        // Add Goal and Habit Buttons (always visible)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add Goal Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                minimumSize: Size(110, 40),
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(Icons.add, size: 20, color: Colors.white),
              label: Text('Goal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddGoalDialog(
                      addGoalToGroup: (Goal goal) async {
                        final goalProvider = Provider.of<GoalProvider>(context, listen: false);
                        try {
                          await goalProvider.addGoalToGroup(goal, group!.groupId);
                          showSnackBar(context, 'Goal added to group successfully!');
                        } catch (e) {
                          showSnackBar(context, 'Error adding goal: $e', isError: true);
                        }
                      },
                      groupId: group!.groupId,
                    );
                  },
                );
              },
            ),
            SizedBox(width: 8.0),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(110, 40),
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(Icons.visibility, size: 20, color: Colors.white),
              label: Text('Members', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _showMembersList,
            ),
            SizedBox(width: 8.0),
            // Add Habit Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                minimumSize: Size(110, 40),
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(Icons.add, size: 20, color: Colors.white),
              label: Text('Habit', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddHabitDialog(isGroupHabit: true, groupId: group!.groupId);
                  },
                );
              },
            ),
          ],
        ),
        ],
      ),
    );
  }
}
