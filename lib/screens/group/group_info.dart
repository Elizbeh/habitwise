import 'package:flutter/material.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/themes/theme.dart';
import 'package:intl/intl.dart';
import 'package:habitwise/models/group.dart';

class GroupInfoSection extends StatefulWidget {
  final HabitWiseGroup group;
  final String creatorName;
  final bool isCreator;
  final void Function(String) onMemberRemoved;
  final void Function() onEditGroupInfo;

  GroupInfoSection({
    required this.group,
    required this.creatorName,
    required this.isCreator,
    required this.onMemberRemoved,
    required this.onEditGroupInfo,
  });

  @override
  _GroupInfoSectionState createState() => _GroupInfoSectionState();
}

class _GroupInfoSectionState extends State<GroupInfoSection> {
  bool _descriptionExpanded = false;

  // Confirm member removal dialog
  void _confirmMemberRemoval(String memberId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this member?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Remove', style: TextStyle(color: Colors.red)),
              onPressed: () {
                widget.onMemberRemoved(memberId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show member details in a dialog
  void _showMemberDetails(Member member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(member.name ?? 'Member Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: member.profilePictureUrl != null
                      ? NetworkImage(member.profilePictureUrl!)
                      : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
                  radius: 60,
                ),
                SizedBox(height: 16.0),
                Text('Email: ${member.email ?? 'N/A'}'),
                SizedBox(height: 8.0),
                Text('Joined on: ${DateFormat('yyyy-MM-dd').format(member.joinedDate ?? DateTime.now())}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            if (widget.isCreator)
              TextButton(
                onPressed: () {
                  _confirmMemberRemoval(member.id);
                  Navigator.of(context).pop();
                },
                child: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
          ],
        );
      },
    );
  }

  // Show the members list
  void _showMembersList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(246, 246, 246, 1), // Light background color
          title: Text(
            'Members (${widget.group.members.length})',
            style: TextStyle(
              color: Color.fromRGBO(134, 41, 137, 1.0), // Match your theme color
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: 300, // Set a specific width for the dialog
            height: 400, // Set a specific height to limit the dialog size
            child: ListView.builder(
              itemCount: widget.group.members.length,
              itemBuilder: (context, index) {
                final member = widget.group.members[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0), // Add vertical margin between tiles
                  decoration: BoxDecoration(
                    color: Colors.white, // Tile background color
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Light shadow
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding
                    leading: CircleAvatar(
                      radius: 39, // Set radius for the avatar
                      backgroundImage: member.profilePictureUrl != null
                          ? NetworkImage(member.profilePictureUrl!)
                          : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
                    ),
                    title: Text(
                      member.name ?? 'No Name',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500), // Slightly lighter font weight
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showMemberDetails(member);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, color: Color.fromRGBO(46, 197, 187, 1.0)), // Match your theme color
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showMemberDetails(member);
                          },
                        ),
                        if (widget.isCreator)
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _confirmMemberRemoval(member.id);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Color.fromRGBO(134, 41, 137, 1.0))), // Match your theme color
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Slightly higher opacity for better contrast
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Darker shadow for better depth
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: group.groupPictureUrl != null && group.groupPictureUrl!.isNotEmpty
                          ? NetworkImage(group.groupPictureUrl!) as ImageProvider<Object>
                          : const AssetImage('assets/images/default_profilePic.png'),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.groupType ?? 'Group Type'}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(46, 197, 187, 1.0),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Created by ${widget.creatorName} on ${DateFormat('yyyy-MM-dd').format(group.creationDate ?? DateTime.now())}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700], // Slightly darker for readability
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isCreator)
                      IconButton(
                        icon: Icon(Icons.edit, color: Color.fromRGBO(181, 58, 185, 1)),
                        onPressed: widget.onEditGroupInfo,
                      ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text(
                  'Group Code: ${group.groupCode ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(181, 58, 185, 1),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Description:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(46, 197, 187, 1.0)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _descriptionExpanded = !_descriptionExpanded;
                    });
                  },
                  child: AnimatedCrossFade(
                    firstChild: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                      child: Text(
                        group.description ?? 'No description provided.',
                        maxLines: 2,
                        style: TextStyle(color: Colors.grey[700]), // Slightly darker for readability
                      ),
                    ),
                                        secondChild: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                      child: Text(
                        group.description ?? 'No description provided.',
                        style: TextStyle(color: Colors.grey[700]), // Slightly darker for readability
                      ),
                    ),
                    crossFadeState: _descriptionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 200),
                  ),
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: _showMembersList,
                  child: Text(
                    'View Members (${group.members.length})',
                    style: TextStyle(
                      color: Color.fromRGBO(46, 197, 187, 1.0), // Match your theme color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
