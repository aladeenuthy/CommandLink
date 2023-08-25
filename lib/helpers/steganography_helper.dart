import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:connect/helpers/encryption_helper.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../models/encoded_response.dart';
import '../models/uploaded_image_conversion_response.dart';
import '../utils/services.dart';

class SteganographyHelper {
  static const int byteSize = 8;
  static const int byteCnt = 2;
  static const int dataLength = byteSize * byteCnt;
  static int getMsgSize(String msg) {
    Uint16List byteMsg = msg2bytes(msg);
    return byteMsg.length * dataLength;
  }

  static int encodeOnePixel(int pixel, int msg) {
    if (msg != 1 && msg != 0) {
      log('msg_encode_bit_more_than_1_bit');
    }
    int lastBitMask = 254;
    int encoded = (pixel & lastBitMask) | msg;
    return encoded;
  }

  static Uint16List padMsg(int capacity, Uint16List msg) {
    Uint16List padded = Uint16List(capacity);
    for (int i = 0; i < msg.length; ++i) {
      padded[i] = msg[i];
    }
    return padded;
  }

  static Uint16List expandMsg(Uint16List msg) {
    Uint16List expanded = Uint16List(msg.length * dataLength);
    for (int i = 0; i < msg.length; ++i) {
      int msgByte = msg[i];
      for (int j = 0; j < dataLength; ++j) {
        int lastBit = msgByte & 1;
        expanded[i * dataLength + (dataLength - j - 1)] = lastBit;
        msgByte = msgByte >> 1;
      }
    }
    return expanded;
  }

  static EncodeResponse? encodeMessageIntoImage(
      {required imglib.Image image,
      required String message,
      required String token}) {
    try {
      Uint16List img = Uint16List.fromList(image.getBytes().toList());
      String msg = EncryptionHelper.encryptMessage(token: token, msg: message);
      Uint16List encodedImg = img;
      if (getEncoderCapacity(img) < getMsgSize(msg)) {
        log('image capacity not enough');
      }
      Uint16List expandedMsg = expandMsg(msg2bytes(msg));
      Uint16List paddedMsg = padMsg(getEncoderCapacity(img), expandedMsg);
      if (paddedMsg.length != getEncoderCapacity(img)) {
        log('msg_container_size_not_match');
      }
      for (int i = 0; i < getEncoderCapacity(img); ++i) {
        encodedImg[i] = encodeOnePixel(img[i], paddedMsg[i]);
      }
      imglib.Image editableImage = imglib.Image.fromBytes(
          image.width, image.height, encodedImg.toList());
      Uint8List data = Uint8List.fromList(imglib.encodePng(editableImage));
      Image displayableImage = Image.memory(data, fit: BoxFit.fitWidth);
      EncodeResponse response =
          EncodeResponse(editableImage, displayableImage, data);
      return response;
    } catch (e) {
      showSnackBar(e.toString());
    }
    return null;
  }

  static UploadedImageConversionResponse convertUploadedImageToData(File file) {
    imglib.Image? editableImage = imglib.decodeImage(file.readAsBytesSync());
    Image displayableImage = Image.file(file, fit: BoxFit.fitWidth);
    int imageByteSize = getEncoderCapacity(
        Uint16List.fromList(editableImage!.getBytes().toList()));
    UploadedImageConversionResponse response = UploadedImageConversionResponse(
        editableImage, displayableImage, imageByteSize);
    return response;
  }

  static Uint16List msg2bytes(String msg) {
    return Uint16List.fromList(msg.codeUnits);
  }

  static int getEncoderCapacity(Uint16List img) {
    return img.length;
  }

  ////decodingg ==========

  static int extractLastBit(int pixel) {
    int lastBit = pixel & 1;
    return lastBit;
  }

  static int assembleBits(Uint16List byte) {
    if (byte.length != dataLength) {
      throw FlutterError('byte_incorrect_size');
    }
    int assembled = 0;
    for (int i = 0; i < dataLength; ++i) {
      if (byte[i] != 1 && byte[i] != 0) {
        throw FlutterError('bit_not_0_or_1');
      }
      assembled = assembled << 1;
      assembled = assembled | byte[i];
    }
    return assembled;
  }

  static Uint16List bits2bytes(Uint16List bits) {
    if ((bits.length % dataLength) != 0) {
      throw FlutterError('bits_contain_incomplete_byte');
    }
    int byteCnt = bits.length ~/ dataLength;
    Uint16List byteMsg = Uint16List(byteCnt);
    for (int i = 0; i < byteCnt; ++i) {
      Uint16List bitsOfByte = Uint16List.fromList(
          bits.getRange(i * dataLength, i * dataLength + dataLength).toList());
      int byte = assembleBits(bitsOfByte);
      byteMsg[i] = byte;
    }
    return byteMsg;
  }

  static Uint16List extractBitsFromImg(Uint16List img) {
    Uint16List extracted = Uint16List(img.length);
    for (int i = 0; i < img.length; i++) {
      extracted[i] = extractLastBit(img[i]);
    }
    return extracted;
  }

  static Uint16List sanitizePaddingZeros(Uint16List msg) {
    int lastNonZeroIdx = msg.length - 1;
    while (msg[lastNonZeroIdx] == 0) {
      --lastNonZeroIdx;
    }
    Uint16List sanitized =
        Uint16List.fromList(msg.getRange(0, lastNonZeroIdx + 1).toList());
    return sanitized;
  }

  static String decodeMessageFromImage(imglib.Image image, String token) {
    try {
      Uint16List img = Uint16List.fromList(image.getBytes().toList());
      Uint16List extracted = extractBitsFromImg(img);
      Uint16List padded = padToBytes(extracted);
      Uint16List byteMsg = bits2bytes(padded);
      Uint16List sanitized = sanitizePaddingZeros(byteMsg);
      String msg = bytes2msg(sanitized);
      final message = EncryptionHelper.decryptMessage(token: token, msg: msg);
      return message;
    } catch (e) {
      showSnackBar('Incorrect Token');
      return "";
    }
  }

  static String bytes2msg(Uint16List bytes) {
    return String.fromCharCodes(bytes);
  }

  static Uint16List padToBytes(Uint16List msg) {
    int padSize = dataLength - msg.length % dataLength;
    Uint16List padded = Uint16List(msg.length + padSize);
    for (int i = 0; i < msg.length; ++i) {
      padded[i] = msg[i];
    }
    for (int i = 0; i < padSize; ++i) {
      padded[msg.length + i] = 0;
    }
    return padded;
  }
}
