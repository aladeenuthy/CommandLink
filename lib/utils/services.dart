
import 'package:connect/models/user.dart';
import 'package:connect/screens/view_chat/encode_message_screen.dart';
import 'package:connect/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect/helpers/key_helper.dart';

double getDeviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top;
}

void showLoadingSpinner() {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: const [
        CircularProgressIndicator(color: kPrimaryColor),
        SizedBox(width: 10),
        Text("Loading"),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: KeyHelper.navKey.currentContext!,
    builder: (context) {
      return alert;
    },
  );
}

void showSnackBar(String message,[bool error = true]) {
  KeyHelper.scafKey.currentState!.showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: error ? Colors.redAccent : Colors.greenAccent,
  ));
}

bool isMe(String id, String userId) {
  return id == userId;
}

String getConvoId(String id1, id2) {
  if (id1.hashCode <= id2.hashCode) {
    return '$id1-$id2';
  }
  return '$id2-$id1';
}

void showImageOptions(Function imageCallBack, ChatUser? receiver) {
  AlertDialog alert = AlertDialog(
    content: SizedBox(
      height: receiver ==null ? 130 : 200,
      child: Column(children: [
        ListTile(
            minLeadingWidth: 8,
            leading: const Icon(
              Icons.camera,
              color: kPrimaryColor,
            ),
            title: const Text(
              "Camera",
              style: TextStyle(color: kPrimaryColor, fontSize: 17),
            ),
            onTap: () {
              KeyHelper.navKey.currentState!.pop();
              imageCallBack(ImageSource.camera);
            }),
        const Divider(
          color: kPrimaryColor,
        ),
        ListTile(
            leading: const Icon(Icons.photo_album, color: kPrimaryColor),
            minLeadingWidth: 8,
            title: const Text(
              "Gallery",
              style: TextStyle(color: kPrimaryColor, fontSize: 17),
            ),
            onTap: () {
              KeyHelper.navKey.currentState!.pop();
              imageCallBack(ImageSource.gallery);
            }),
             if(receiver!= null)    const Divider(
          color: kPrimaryColor,
        ),
        if(receiver!= null)
        ListTile(
            minLeadingWidth: 8,
            leading: const Icon(Icons.security, color: kPrimaryColor),
            title: const Text(
              "Encrypt Message",
              style: TextStyle(color: kPrimaryColor, fontSize: 17),
            ),
            onTap: () {
              KeyHelper.navKey.currentState!.pop();
                KeyHelper.navKey.currentState!.pushNamed(EncodeMessageScreen.routeName, arguments: receiver);
            })
      ]),
    ),
  );
  showDialog(
    barrierDismissible: true,
    context: KeyHelper.navKey.currentContext!,
    builder: (ctx) {
      return alert;
    },
  );
}


