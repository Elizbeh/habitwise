import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  late String _userId;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserIds();
  }

  Future<void> _fetchUserIds() async {
    try {
      // Get the current user ID using your authentication method
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _currentUserId = user.uid;
        });
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          toolbarHeight: 200,
          title: const Text(
            'Create Group',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(126, 35, 191, 0.498),
                  Color.fromARGB(255, 222, 144, 236),
                  Color.fromRGBO(126, 35, 191, 0.498),
                  Color.fromARGB(57, 181, 77, 199),
                  Color.fromARGB(255, 201, 5, 236)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topLeft,
              ),
            ),
          ),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logoutUser();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  String groupName = _groupNameController.text.trim();
                  String groupType = _groupTypeController.text.trim();
                  String description = _descriptionController.text.trim();
                  if (groupName.isNotEmpty && groupType.isNotEmpty && description.isNotEmpty) {
                    try {
                      HabitWiseGroup newGroup = HabitWiseGroup(
                        groupId: '',
                        groupName: groupName,
                        description: description,
                        members: [_userId],
                        goals: [],
                        habits: [],
                        groupType: groupType,
                        groupPictureUrl: null,
                        groupCreator: _currentUserId,
                        creationDate: DateTime.now(),
                      );
                      await Provider.of<GroupProvider>(context, listen: false).createGroup(newGroup);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Group created successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Navigate back to the dashboard and refresh groups
                      Navigator.pop(context);
                      Provider.of<GroupProvider>(context, listen: false).fetchGroups();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating group: $e'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all fields.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      )
    ); 
  }
}