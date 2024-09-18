import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habitwise/models/group.dart';

class GroupInfoSection extends StatefulWidget {
  final HabitWiseGroup group;
  final String creatorName;
  final bool isCreator;
  final void Function(String) onMemberRemoved;
  
  GroupInfoSection({
    required this.group,
    required this.creatorName,
    required this.isCreator,
    required this.onMemberRemoved,
  });

  @override
  _GroupInfoSectionState createState() => _GroupInfoSectionState();
}

class _GroupInfoSectionState extends State<GroupInfoSection> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${group.groupType ?? 'Group Type'}',
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
                          widget.onMemberRemoved(member.id);  // Call the callback to handle removal
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
