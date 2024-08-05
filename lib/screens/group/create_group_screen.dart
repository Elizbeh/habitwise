import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/group/group_details_screen.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/services/storage_service.dart';
import 'package:provider/provider.dart';

// Define the gradient colors as constants
const List<Color> appBarGradientColors = [
  Color.fromRGBO(126, 35, 191, 0.498),
  Color.fromARGB(255, 93, 156, 164),
  Color.fromARGB(233, 93, 59, 99),
];

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _groupPhoto;
  final _storageService = StorageService();
  int _currentIndex = 0;

  Future<void> _selectGroupPhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _groupPhoto = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadGroupPhoto() async {
    if (_groupPhoto != null) {
      try {
        return await _storageService.uploadGroupPhoto(_groupPhoto!);
      } catch (e) {
        print('Error uploading group photo: $e');
        // Optionally, you could show a message to the user about the failure
      }
    }
    return null;
  }

  Future<void> _createGroup() async {
    String groupName = _groupNameController.text.trim();
    String groupType = _groupTypeController.text.trim();
    String description = _descriptionController.text.trim();

    HabitWiseUser? user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not found. Please log in again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String userId = user.uid;

    if (groupName.isNotEmpty && groupType.isNotEmpty && description.isNotEmpty) {
      try {
        String? groupPhotoUrl = await _uploadGroupPhoto();

        HabitWiseGroup newGroup = HabitWiseGroup(
          groupId: '',  // Initially empty
          groupName: groupName,
          description: description,
          members: [userId],
          goals: [],
          habits: [],
          groupType: groupType,
          groupPictureUrl: groupPhotoUrl,
          groupCreator: userId,
          creationDate: DateTime.now(),
        );

        // Create the group and get the groupId
        String groupId = await Provider.of<GroupProvider>(context, listen: false).createGroup(newGroup);

        // Update the newGroup with the actual groupId
        newGroup = newGroup.copyWith(groupId: groupId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group created successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to GroupDetailsScreen with the newGroup and user
        Navigator.pushReplacementNamed(
          context,
          '/groupDetails',
          arguments: newGroup, // Pass the entire updated group object
        );
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
  }

  void _onBottomNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Define your navigation logic based on the index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/goals'); // Adjust the route as needed
        break;
      case 2:
        Navigator.pushNamed(context, '/habit'); // Adjust the route as needed
        break;
      case 3:
        Navigator.pushNamed(context, '/profile'); // Adjust the route as needed
        break;
      case 4:
        Navigator.pushNamed(context, '/settings'); // Adjust the route as needed
        break;
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
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent,
              ),
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
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                  onPressed: _selectGroupPhoto,
                  child: Text('Select Group Photo'),
                ),
                SizedBox(height: 16.0),
                if (_groupPhoto != null)
                  Image.file(
                    _groupPhoto!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _createGroup,
                  child: Text('Create Group'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavBarTapped,
        themeNotifier: ValueNotifier(ThemeMode.light), // Adjust based on your theme logic
      ),
    );
  }
}
