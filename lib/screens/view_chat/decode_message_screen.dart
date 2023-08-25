import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect/models/message.dart';
import 'package:connect/utils/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../helpers/steganography_helper.dart';
import '../../utils/constants.dart';

class DecodeMessageScreen extends StatefulWidget {
  const DecodeMessageScreen({super.key, required this.message});
  static const routeName = "/decode";
  final Message message;

  @override
  State<DecodeMessageScreen> createState() => _DecodeMessageScreenState();
}

class _DecodeMessageScreenState extends State<DecodeMessageScreen> {
  final tokenController = TextEditingController();
  String decodedMessage = '';
  bool isLoading = false;
  File? imageFile;
  @override
  void initState() {
    super.initState();
    downloadImage();
  }

  void decodeMessage() async {
    setState(() {
      isLoading = true;
    });
    bool result = true;
    log(imageFile.toString());
    if (imageFile == null) {
      result = await downloadImage();
    }
    if (result) {
      final response =
          SteganographyHelper.convertUploadedImageToData(imageFile!);
      final message = SteganographyHelper.decodeMessageFromImage(
          response.editableImage, tokenController.text.trim());
      setState(() {
        decodedMessage = message;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> downloadImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/commandlink/${widget.message.content}');
      await Dio().download(widget.message.content, file.path);
      imageFile = file;
      return true;
    } catch (e) {
      log(e.toString());
      showSnackBar('Check Your Internet Connection');
      return false;
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
        title: const Text("Decode Message",
            style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 15,
              right: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                  "Decoded Message: ${decodedMessage.isEmpty ? "---" : decodedMessage}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image:
                            CachedNetworkImageProvider(widget.message.content),
                        fit: BoxFit.cover)),
              ),
              const SizedBox(
                height: 35,
              ),
              TextField(
                  controller: tokenController,
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
                    if (tokenController.text.trim().isEmpty) {
                      return;
                    }
                    log('past her');
                    decodeMessage();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.all(10),
                      elevation: 0),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Decode",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
