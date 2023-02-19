import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Future<XFile?> getImageGallery() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      return image;
    } else {
      return null;
    }
  }

  static Future<XFile?> getImageCamera() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (image != null) {
      return image;
    } else {
      return null;
    }
  }

  static uploadImage(XFile imageFile) async {
    String filename = basename(imageFile.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    final Reference reference = storage.ref().child('upload_image/$filename');
    await reference.putFile(File(imageFile.path));

    String downloadUrl = await reference.getDownloadURL();
    if (downloadUrl != null) {
      return downloadUrl;
    } else {
      return null;
    }
  }

  static uploadProduct(
    String name,
    String price,
    String description,
    String stock,
    List<XFile> images,
    String category,
  ) async {
    try {
      List<String> imageUrl = [];
      await Future.forEach(images, (element) async {
        String url = await DatabaseService.uploadImage(element as XFile);
        imageUrl.add(url);
      });

      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('product')
          .doc(timestamp.toString())
          .set({
        'product_id': timestamp.toString(),
        'name': name,
        'price': int.parse(price),
        'stock': int.parse(stock),
        'description': description,
        'category': category,
        'image': imageUrl,
        'sold': 0,
        'disc_percentage': 0,
        'disc_price': 0,
      });

      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static updateAddress(String text, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'address': text,
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static editProduct(
    String productId,
    String percent,
    double discountPrice,
    String name,
    String price,
    String description,
    String stock,
    List<String> images,
    String category,
  ) async {
    try {

      print(productId);


      await FirebaseFirestore.instance
          .collection('product')
          .doc(productId)
          .update({
        'name': name,
        'price': int.parse(price),
        'stock': int.parse(stock),
        'description': description,
        'category': category,
        'image': images,
        'disc_percentage': (percent != "") ? int.parse(percent) : 0,
        'disc_price': int.parse(discountPrice.toString().replaceAll(".0", "")),
      });

      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static addToCart(product, String text) async {
    try {
      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(timestamp.toString())
          .set({
        'product_id': product["product_id"],
        'cart_id': timestamp.toString(),
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'name': product["name"],
        'price': product["price"],
        'stock_before': product["stock"],
        'description': product["description"],
        'category': product["category"],
        'image': product["image"],
        'sold': product["sold"],
        'disc_percentage': product["disc_percentage"],
        'disc_price': product["disc_price"],
        'stock_buy': int.parse(text)
      });

      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }
}
