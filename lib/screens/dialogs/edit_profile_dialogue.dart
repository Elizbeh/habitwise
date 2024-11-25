import 'dart:io';
import 'package:flutter/material.dart';
import 'package:habitwise/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habitwise/services/storage_service.dart';
import 'package:habitwise/services/user_db_service.dart';

class EditProfileScreen extends StatefulWidget {
  final HabitWiseUser user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  
  // Declare a state variable to hold the updated profile picture URL
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;

    // Initialize the profile picture URL with the user's existing one
    _profilePictureUrl = widget.user.profilePictureUrl;
  }

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        String imageUrl = await _storageService.uploadFile(_imageFile!);
        print('Uploaded Image URL: $imageUrl');

        // Update state with the new profile picture URL
        setState(() {
          _profilePictureUrl = imageUrl;
        });

        Navigator.pop(context); // Close loading indicator
      } catch (e) {
        Navigator.pop(context); // Close loading indicator
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = _profilePictureUrl ?? widget.user.profilePictureUrl!;

      // Create an updated user object
      HabitWiseUser updatedUser = widget.user.copyWith(
        username: _usernameController.text,
        email: _emailController.text,
        profilePictureUrl: imageUrl,
      );

      await UserDBService().updateUserProfile(updatedUser);
      Navigator.pop(context, updatedUser); // Return updated user to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(134, 41, 137, 1.0), // Dark Purple
                Color.fromRGBO(181, 58, 185, 1),   // Light Purple
                Color.fromRGBO(46, 197, 187, 1.0)  // Teal
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                GestureDetector(
                  onTap: _uploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_profilePictureUrl?.isNotEmpty ?? false)
                            ? NetworkImage(_profilePictureUrl!)
                            : AssetImage('assets/images/default_profilePic.png') as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Username Text Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color.fromRGBO(134, 41, 137, 1.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Email Text Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color.fromRGBO(46, 197, 187, 1.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Save Changes Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: Color.fromRGBO(46, 197, 187, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // Teal
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
