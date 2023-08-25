import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:connect/helpers/steganography_helper.dart';
import 'package:connect/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../helpers/chat_helper.dart';
import '../../utils/constants.dart';

class EncodeMessageScreen extends StatefulWidget {
  const EncodeMessageScreen({super.key, required this.receiver});
  static const routeName = "/encode";
  final ChatUser receiver;

  @override
  State<EncodeMessageScreen> createState() => _EncodeMessageScreenState();
}

class _EncodeMessageScreenState extends State<EncodeMessageScreen> {
  final messageController = TextEditingController();
  final tokenController = TextEditingController();
  bool isLoading = false;
  File? imageFile;
  Uint8List? imageBytes;
  @override
  void initState() {
    super.initState();
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    }
    setState(() {
      imageFile = File(image.path);
    });
  }

  Future<void> sendMessage() async {
    setState(() {
      isLoading = true;
    });
    final response = SteganographyHelper.convertUploadedImageToData(imageFile!);
    final res = SteganographyHelper.encodeMessageIntoImage(
        image: response.editableImage,
        message: messageController.text.trim(),
        token: tokenController.text.trim());
    // log(res.displayableImage.toString());
    // setState(() {
    //   imageBytes = res.data;
    // });
    if (res == null) {
      return;
    }
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_image${Random().nextDouble() + Random().nextInt(1000)}.png');
    await file.writeAsBytes(res.data);
    final result =
        await ChatHelper.sendMessage('', 'encrypted', widget.receiver, file);
    setState(() {
      isLoading = false;
    });
    if (result) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        elevation: 0,
        title: const Text("Encode a Message",
            style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 15,
                right: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                        image: imageFile == null
                            ? null
                            : DecorationImage(
                                image: FileImage(imageFile!), fit: BoxFit.cover)),
                    child: imageFile == null
                        ? const Icon(
                            Icons.photo_album,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                // if(imageBytes!= null) Container(
                //     height: 280,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //         color: kPrimaryColor,
                //         borderRadius: BorderRadius.circular(10),
                //         ),
                //     child: Image.memory(imageBytes!, fit: BoxFit.cover,),
                //   ),
                TextField(
                    controller: messageController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: tokenController,
                    maxLength: 32,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Token',
                    )),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (tokenController.text.isEmpty ||
                          messageController.text.isEmpty ||
                          imageFile == null) {
                        return;
                      }
                      sendMessage();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.all(10),
                        elevation: 0),
                    child: isLoading ? const CircularProgressIndicator(color: Colors.white,): const Text(
                      "Send",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
