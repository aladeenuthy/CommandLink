import 'dart:developer';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as crypto;

class EncryptionHelper {
  static String encryptMessage({required String token, required String msg}) {
    crypto.Key key = crypto.Key.fromUtf8(padCryptionKey(token));
    crypto.IV iv = crypto.IV.fromLength(16);
    crypto.Encrypter encrypter = crypto.Encrypter(crypto.AES(key));
    crypto.Encrypted encrypted = encrypter.encrypt(msg, iv: iv);
    final message = encrypted.base64;
    return message;
  }

  static String padCryptionKey(String key) {
    //for when the encryption key does not meet up to length 32
    String paddedKey = key;
    if (key.length > 32) {
      paddedKey = paddedKey.substring(0, 32);
    } else {
      int padCnt = 32 - key.length;
      for (int i = 0; i < padCnt; ++i) {
        paddedKey += '.';
      }
    }

    return paddedKey;
  }

  static String decryptMessage({required String token, required String msg}) {
    crypto.Key key = crypto.Key.fromUtf8(padCryptionKey(token));
    crypto.IV iv = crypto.IV.fromLength(16);
    crypto.Encrypter encrypter = crypto.Encrypter(crypto.AES(key));
    crypto.Encrypted encryptedMsg = crypto.Encrypted.fromBase64(msg);
    final message = encrypter.decrypt(encryptedMsg, iv: iv);
    return message;
  }

 
}
