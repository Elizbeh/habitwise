import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/providers/user_provider.dart';
import 'package:habitwise/themes/theme.dart';
import 'package:habitwise/widgets/bottom_navigation_bar.dart';
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

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

        Member currentUser = Member(
          id: userId,
          name: user.username,
          email: user.email,
          profilePictureUrl: user.profilePictureUrl,
        );

        HabitWiseGroup newGroup = HabitWiseGroup(
          groupId: '',
          groupName: groupName,
          description: description,
          members: [currentUser],
          goals: [],
          habits: [],
          groupType: groupType,
          groupPictureUrl: groupPhotoUrl,
          groupCreator: userId,
          creationDate: DateTime.now(),
        );

        String groupId = await Provider.of<GroupProvider>(context, listen: false)
            .createGroup(newGroup);

        newGroup = newGroup.copyWith(groupId: groupId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group created successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          '/groupDetails',
          arguments: newGroup
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
        toolbarHeight: 80,
        title: Text(
                'Create Group',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _groupNameController,
                  label: 'Group Name',
                  icon: Icons.group,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _groupTypeController,
                  label: 'Group Type',
                  icon: Icons.category,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _buildPhotoSelector(context),
                const SizedBox(height: 20),
                _buildCreateButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavBarTapped,
        themeNotifier: ValueNotifier(ThemeMode.light),
      ),
    );
  }

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
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Color.fromRGBO(134, 41, 137, 1.0)),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color.fromRGBO(134, 41, 137, 1.0)),
        ),
      ),
    );
  }

  Widget _buildPhotoSelector(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _selectGroupPhoto,
          icon: Icon(Icons.photo, color: Colors.white, size: 32),
          label: Text(
            'Select Group Photo',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            backgroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_groupPhoto != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _groupPhoto!,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _createGroup,
      child: Text('Create Group', style: TextStyle(fontSize: 18, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Color.fromRGBO(134, 41, 137, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
      ),
    );
  }
}
