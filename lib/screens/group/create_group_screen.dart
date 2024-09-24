import 'dart:io'; // Required for working with File
import 'package:flutter/material.dart';
import 'package:habitwise/themes/theme.dart'; // Custom theme
import 'package:habitwise/models/user.dart'; // User model
import 'package:habitwise/providers/user_provider.dart'; // User state management
import 'package:habitwise/widgets/bottom_navigation_bar.dart'; // Custom Bottom Nav Bar
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:habitwise/providers/group_provider.dart'; // Group state management
import 'package:habitwise/models/group.dart'; // Group model
import 'package:habitwise/models/member.dart'; // Member model
import 'package:habitwise/services/storage_service.dart'; // Storage service for uploads
import 'package:provider/provider.dart'; // Provider for state management

// Gradient colors for the app bar
const List<Color> appBarGradientColors = [
  Color.fromRGBO(134, 41, 137, 1.0),
  Color.fromRGBO(134, 41, 137, 1.0),
  Color.fromRGBO(181, 58, 185, 1),
  Color.fromRGBO(46, 197, 187, 1.0),
];

// StatefulWidget for creating or editing a group
class CreateGroupScreen extends StatefulWidget {
  final HabitWiseGroup? groupToEdit; // Optional group to edit
  final VoidCallback? onGroupUpdated; // Callback after group update

  CreateGroupScreen({this.groupToEdit, this.onGroupUpdated});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController(); // Group name input
  final TextEditingController _groupTypeController = TextEditingController(); // Group type input
  final TextEditingController _descriptionController = TextEditingController(); // Group description input
  File? _groupPhoto; // Selected group photo file
  final StorageService _storageService = StorageService(); // Handles photo uploads
  int _currentIndex = 0; // Current bottom navigation index
  late HabitWiseGroup _group; // Current group data
  bool _isUploading = false; // Uploading state indicator

  @override
  void initState() {
    super.initState();
    _initializeGroup();
  }

  // Initializes the group data if editing an existing group or creates a new one
  void _initializeGroup() {
    if (widget.groupToEdit != null) {
      _group = widget.groupToEdit!;
      _groupNameController.text = _group.groupName;
      _groupTypeController.text = _group.groupType;
      _descriptionController.text = _group.description;
      _loadGroupPhoto(); // Load existing photo if available
    } else {
      _group = HabitWiseGroup(
        groupId: '',
        groupName: '',
        description: '',
        members: [],
        habits: [],
        groupType: '',
        groupPictureUrl: '',
        groupCreator: '',
        creationDate: DateTime.now(),
      );
    }
  }

  // Loads the group photo from a URL if editing an existing group
  Future<void> _loadGroupPhoto() async {
    if (_group.groupPictureUrl?.isNotEmpty ?? false) {
      final file = await _storageService.getImageFileFromUrl(_group.groupPictureUrl!);
      setState(() {
        _groupPhoto = file;
      });
    }
  }

  // Opens image picker for selecting a group photo
  Future<void> _selectGroupPhoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _groupPhoto = File(pickedFile.path);
      });
    }
  }

  // Uploads the selected group photo to cloud storage
  Future<String?> _uploadGroupPhoto() async {
    if (_groupPhoto != null) {
      try {
        setState(() {
          _isUploading = true;
        });
        return await _storageService.uploadGroupPhoto(_groupPhoto!); // Upload photo
      } catch (e) {
        print('Error uploading group photo: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
    return null; // No photo uploaded
  }

  // Saves the group data (either creates a new group or updates an existing one)
  Future<void> _saveGroup() async {
    String groupName = _groupNameController.text.trim();
    String groupType = _groupTypeController.text.trim();
    String description = _descriptionController.text.trim();

    HabitWiseUser? user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) {
      _showSnackBar('User not found. Please log in again.');
      return;
    }

    if (groupName.isNotEmpty && groupType.isNotEmpty && description.isNotEmpty) {
      try {
        setState(() {
          _isUploading = true;
        });
        String? groupPhotoUrl = await _uploadGroupPhoto(); // Upload and get photo URL

        Member currentUser = Member(
          id: user.uid,
          name: user.username,
          email: user.email,
          profilePictureUrl: user.profilePictureUrl,
        );

        // Update group data
        HabitWiseGroup updatedGroup = _group.copyWith(
          groupName: groupName,
          description: description,
          groupType: groupType,
          groupPictureUrl: groupPhotoUrl ?? _group.groupPictureUrl,
          members: _group.members.isEmpty ? [currentUser] : _group.members,
          groupCreator: _group.groupCreator.isEmpty ? user.uid : _group.groupCreator,
          creationDate: _group.creationDate,
        );

        // Create or update group based on context
        if (widget.groupToEdit == null) {
          String groupId = await Provider.of<GroupProvider>(context, listen: false).createGroup(updatedGroup);
          updatedGroup = updatedGroup.copyWith(groupId: groupId);
          _showSnackBar('Group created successfully!');
          Navigator.pushReplacementNamed(context, '/groupDetails', arguments: updatedGroup);
        } else {
          await Provider.of<GroupProvider>(context, listen: false).updateGroup(updatedGroup);
          _showSnackBar('Group updated successfully!');
          Navigator.pushReplacementNamed(context, '/groupDetails', arguments: updatedGroup);
        }

        // Trigger the callback if provided
        widget.onGroupUpdated?.call();
      } catch (e) {
        _showSnackBar('Error saving group: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      _showSnackBar('Please fill in all fields.');
    }
  }

  // Displays a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Handles bottom navigation bar tap
  void _onBottomNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the selected screen based on index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/goals');
        break;
      case 2:
        Navigator.pushNamed(context, '/habit');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
      case 4:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  void dispose() {
    // Dispose of controllers to free up resources
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.groupToEdit == null ? 'Create Group' : 'Edit Group',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Input fields for group details
                _buildTextField(
                  controller: _groupNameController,
                  label: 'Group Name',
                  icon: Icons.group,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _groupTypeController,
                  label: 'Group Type',
                  icon: Icons.category,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                // Group photo section
                Text(
                  'Group Photo',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectGroupPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: _groupPhoto != null
                          ? DecorationImage(
                              image: FileImage(_groupPhoto!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/placeholder.png'), // Placeholder image
                              fit: BoxFit.cover,
                            ),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: _groupPhoto == null
                        ? Center(
                            child: Text(
                              'Tap to select a photo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Save button
                ElevatedButton(
                  onPressed: _isUploading ? null : _saveGroup,
                  child: _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(widget.groupToEdit == null ? 'Create Group' : 'Update Group'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavBarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
