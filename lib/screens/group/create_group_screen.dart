import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/main.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/screens/dashboard_screen.dart';
import 'package:habitwise/screens/personal_goal.dart';
import 'package:habitwise/screens/personal_habits.dart';
import 'package:habitwise/screens/profile_screen.dart';
import 'package:habitwise/screens/setting_screen.dart';
import 'package:habitwise/screens/widgets/bottom_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habitwise/providers/group_provider.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/services/storage_service.dart';
import 'package:provider/provider.dart';

const List<Color> appBarGradientColors = [
  Color.fromRGBO(134, 41, 137, 1.0),
  Color.fromRGBO(134, 41, 137, 1.0),
  Color.fromRGBO(181, 58, 185, 1),
  Color.fromRGBO(46, 197, 187, 1.0),
];

class CreateGroupScreen extends StatefulWidget {
  final HabitWiseGroup? groupToEdit;
  final VoidCallback? onGroupUpdated;
  final HabitWiseUser user;
  final String? groupId;

  CreateGroupScreen({this.groupToEdit, this.onGroupUpdated, required this.user, this.groupId});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _groupPhoto;
  final ImagePicker _picker = ImagePicker();

  final StorageService _storageService = StorageService();
  bool _isUploading = false;

  int _currentIndex = 0;
  late HabitWiseGroup _group;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user, groupId: widget.groupId ?? '',)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoalScreen(user: widget.user, groupId: widget.groupId ?? '',)));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HabitScreen(user: widget.user, groupId: widget.groupId ?? '',)));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(themeNotifier: appThemeNotifier,)));
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeGroup();
  }

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
        memberIds: [],  
        habits: [],
        groupType: '',
        groupPictureUrl: '',
        creationDate: DateTime.now(),
        groupCode: '',
        groupRoles: {},
        creatorId: '',
      );
    }
  }

  Future<void> _loadGroupPhoto() async {
    if (widget.groupToEdit?.groupPictureUrl?.isNotEmpty ?? false) {
      final file = await _storageService.getImageFileFromUrl(widget.groupToEdit!.groupPictureUrl!);
      setState(() {
        _groupPhoto = file;
      });
    }
  }

  Future<void> _selectGroupPhoto() async {
    final selectedOption = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: () {
                Navigator.pop(context, 0); // 0 for camera
              },
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () {
                Navigator.pop(context, 1); // 1 for gallery
              },
            ),
          ],
        );
      },
    );

    if (selectedOption != null) {
      XFile? pickedImage;
      if (selectedOption == 0) {
        pickedImage = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
      } else if (selectedOption == 1) {
        pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      }

      if (pickedImage != null) {
        setState(() {
          _groupPhoto = File(pickedImage!.path);
        });
      }
    }
  }

  Future<String?> _uploadGroupPhoto() async {
    if (_groupPhoto != null) {
      try {
        setState(() {
          _isUploading = true;
        });
        return await _storageService.uploadGroupPhoto(_groupPhoto!);
      } catch (e) {
        print('Error uploading group photo: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
    return null;
  }

  Future<void> _saveGroup() async {
    String groupName = _groupNameController.text.trim();
    String groupType = _groupTypeController.text.trim();
    String description = _descriptionController.text.trim();

    HabitWiseUser? user = Provider.of<UserProvider>(context, listen: false).currentUser;

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

        // Create the current user as an Admin if creating a new group
        Member currentUser = Member(
          id: user.uid,
          name: user.username,
          role: MemberRole.admin,  // Default to admin for group creator
          email: user.email,
          profilePictureUrl: user.profilePictureUrl,
        );

        // Create or update group data
        HabitWiseGroup updatedGroup = _group.copyWith(
          groupName: groupName,
          description: description,
          groupType: groupType,
          groupPictureUrl: groupPhotoUrl ?? _group.groupPictureUrl,
          members: _group.members.isEmpty ? [currentUser] : _group.members,
          groupRoles: _group.groupRoles.isEmpty
            ? {user.uid: MemberRole.admin.toString()} // Assign admin role for the creator
            : {..._group.groupRoles, user.uid: MemberRole.admin.toString()},
          creationDate: _group.creationDate,
          groupCode: _createGroupCode(),
          creatorId: user.uid,  // Set the creatorId
        );

        // Create or update group based on context
        if (widget.groupToEdit == null) {
          // Creating a new group
          String groupId = await Provider.of<GroupProvider>(context, listen: false).createGroup(updatedGroup);
          updatedGroup = updatedGroup.copyWith(groupId: groupId);
          _showSnackBar('Group created successfully!');
          Navigator.pushReplacementNamed(context, '/groupDetails', arguments: updatedGroup);
        } else {
          // Editing an existing group
          if (_group.groupRoles[user.uid] == MemberRole.admin.toString()) {
            // User is admin, allow editing
            await Provider.of<GroupProvider>(context, listen: false).updateGroup(updatedGroup);
            _showSnackBar('Group updated successfully!');
            Navigator.pushReplacementNamed(context, '/groupDetails', arguments: updatedGroup);
          } else {
            // User is not an admin, prevent editing
            _showSnackBar('Only admins can edit this group.');
          }
        }

        // Trigger the callback if provided
        widget.onGroupUpdated?.call();
      } catch (e) {
        print('Error saving group: $e');
        _showSnackBar('Error saving group: ${e.toString()}');

      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      _showSnackBar('Please fill in all fields.');
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(50),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(50),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        title: Text(widget.groupToEdit == null ? 'Create Group' : 'Edit Group'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _buildTextField(_groupNameController, 'Group Name', Icons.group),
                const SizedBox(height: 8),
                _buildTextField(_groupTypeController, 'Group Type', Icons.category),
                const SizedBox(height: 8),
                _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3, maxLength:   150),
                const SizedBox(height: 8),
                _buildTextField(TextEditingController(text: _createGroupCode()), 'Group Code', Icons.vpn_key, enabled: false),
                const SizedBox(height: 8),
                Text('Group Photo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
              onTap: _selectGroupPhoto,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: _groupPhoto != null
                      ? DecorationImage(image: FileImage(_groupPhoto!), fit: BoxFit.cover)
                      : const DecorationImage(image: AssetImage('assets/images/placeholder.png'), fit: BoxFit.cover),
                  border: Border.all(color: Colors.grey, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: _groupPhoto == null
                    ? Center(
                        child: Text(
                          'Tap to select a photo',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      )
                    : null,
              ),
            ), 
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isUploading ? null : _saveGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Color.fromRGBO(46, 197, 187, 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(widget.groupToEdit == null ? 'Create Group' : 'Update Group', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onTap,
        themeNotifier: ValueNotifier(ThemeMode.light), // Pass theme if needed
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool enabled = true, int? maxLength}) {
    return TextField(
      controller: controller,
            maxLines: maxLines,
      enabled: enabled,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }



// Generates a unique and fun group code
String _createGroupCode() {
  // Get first three letters of group type (if available)
  String groupTypeCode = _groupTypeController.text.length >= 3 
      ? _groupTypeController.text.substring(0, 3).toUpperCase() 
      : _groupTypeController.text.toUpperCase();

  // Get first two letters of group name (if available)
  String groupNameCode = _groupNameController.text.length >= 2 
      ? _groupNameController.text.substring(0, 2).toUpperCase() 
      : _groupNameController.text.toUpperCase();

  // Generate a random alphanumeric string of 4 characters
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  String randomCode = List.generate(4, (index) => characters[random.nextInt(characters.length)]).join();

  // Combine the group type, group name, and random code
  return '$groupTypeCode-$groupNameCode-$randomCode';
}

}