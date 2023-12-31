import 'dart:io';
import 'package:connect/components/image_preview.dart';
import 'package:connect/screens/home/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/services.dart';

class AddUserDetails extends StatefulWidget {
  const AddUserDetails({Key? key}) : super(key: key);
  static const routeName = '/add-user-details';
  @override
  State<AddUserDetails> createState() => _AddUserDetailsState();
}

class _AddUserDetailsState extends State<AddUserDetails> {
  final _usernameController = TextEditingController();
  File? _pickedImage;

  void _saveDetails() async {
    FocusScope.of(context).unfocus();
    if (_pickedImage == null || _usernameController.text.isEmpty) {
      return;
    }
    showLoadingSpinner();
    final isDone = await context.read<AuthProvider>().saveUserDetails(
        _pickedImage as File, _usernameController.text.trim());
    Navigator.of(context).pop(); //pop loading spinner
    if (!isDone) {
      return;
    }
    Navigator.of(context).popAndPushNamed(ChatsScreen.routeName);
  }

  void _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(
        source: source);
    if (image == null) {
      return;
    }
    File imageFile = File(image.path);
    if (source == ImageSource.gallery) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => ImagePreview(image: imageFile)))
          .then((value) {
        if (value) {
          setState(() {
            _pickedImage = imageFile;
          });
          return;
        }
      });
    }
    setState(() {
      _pickedImage = imageFile;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = getDeviceHeight(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: deviceHeight * 0.2,
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: shadePrimaryColor,
                    backgroundImage: _pickedImage == null
                        ? null
                        : FileImage(_pickedImage as File),
                    child: _pickedImage == null
                        ? const Icon(
                            Icons.person_add,
                            color: kPrimaryColor,
                            size: 40,
                          )
                        : null,
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: IconButton(
                            onPressed: () {
                              showImageOptions(_pickImage, null);
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: kPrimaryColor,
                            ),
                          )))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'username',
                  )),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: shadePrimaryColor),
                  onPressed: _saveDetails,
                  child: const Text(
                    "Save",
                    style: TextStyle(color: kPrimaryColor, fontSize: 20),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
