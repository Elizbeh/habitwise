import 'package:flutter/material.dart';
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
              child: Text('Remove'),
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

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Group Info (Type and Creation Date)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${group.groupName?? 'Group Name'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Created by ${widget.creatorName} on ${DateFormat('yyyy-MM-dd').format(group.creationDate ?? DateTime.now())}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            // Edit Icon
            if (widget.isCreator)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: widget.onEditGroupInfo,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.0),
        // Description Section
        Text(
          'Description:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                style: TextStyle(color: Colors.white70),
              ),
            ),
            secondChild: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
              child: Text(
                group.description ?? 'No description provided.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            crossFadeState: _descriptionExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 200),
          ),
        ),
        SizedBox(height: 8.0),
        // Members Dropdown Button
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              'Members (${group.members.length ?? 0})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            items: (group.members ?? []).map((member) {
              return DropdownMenuItem<String>(
                value: member.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: member.profilePictureUrl != null
                              ? NetworkImage(member.profilePictureUrl!) as ImageProvider
                              : AssetImage('assets/images/default_profilePic.png'),
                        ),
                        SizedBox(width: 8.0),
                        Text(member.name ?? 'No Name', style: TextStyle(color: Colors.black)),
                      ],
                    ), 
                    // Remove button
                    if (widget.isCreator)
                      TextButton(
                        onPressed: () {
                          _confirmMemberRemoval(member.id);  // Call the removal confirmation
                        },
                        child: Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (selectedMemberId) {
              // Handle member selection if needed
            },
          ),
        ),
      ],
    );
  }
}