import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../util/SheetsColumn.dart';
import '../util/google_sheet.dart';

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

  static updateAddress(String text, String receiverName, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'address': text,
        'receiver_name': receiverName,
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

  static createTransaction(
      int transactionId,
      String uid,
      String name,
      String receiverName,
      String phone,
      String address,
      num totalTransaction,
      String dateTime,
      String status,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transactionId.toString())
          .set({
        'transaction_id': transactionId.toString(),
        'user_id': uid,
        'user_name': name,
        'receiver_name': receiverName,
        'user_phone': phone,
        'user_address': address,
        'totalTransaction': totalTransaction,
        'date_time': dateTime,
        'status': status,
        'notes': "",
      });

      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static createTransactionProduct(
    String transaction_product_id,
    String transaction_id,
    String product_id,
    String user_id,
    String name,
    num price,
    num stock_before,
    String description,
    String category,
    List image,
    num sold,
    num disc_percentage,
    num disc_price,
    num stock_buy,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction_product')
          .doc(transaction_product_id)
          .set({
        'transaction_product_id': transaction_product_id,
        'transaction_id': transaction_id,
        'product_id': product_id,
        'user_id': user_id,
        'name': name,
        'price': price,
        'stock_before': stock_before,
        'description': description,
        'category': category,
        'image': image,
        'sold': sold,
        'disc_percentage': disc_percentage,
        'disc_price': disc_price,
        'stock_buy': stock_buy,
        'notes': '',
      });

      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static deleteCartById(String cart_id) async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(cart_id).delete();
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static cancelTransaction(String transaction_id) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction_id)
          .update({
        'status': 'Transaksi Dibatalkan',
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static accTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transactionId)
          .update({
        'status': 'Siap Untuk COD',
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static updateTransactionNote(String notes, String transaction_id) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction_id)
          .update({
        'notes': notes,
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static finishTransaction(String transaction_id) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction_id)
          .update({
        'status': 'Transaksi Selesai',
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static cutStockAndIncrementSoldProduct(
    String transaction_id,
    List<DocumentSnapshot> documents,
    String dateTime,
    String userName,
    String receiverName,
    String userPhone,
    String address,
  ) async {
    try {
      var i = 0;
      await Future.forEach(documents, (element) async {
        num stock_buy = documents[i]["stock_buy"];
        num stock_before = 0;
        num sold = 0;
        String product_id = documents[i]["product_id"];

        await FirebaseFirestore.instance
            .collection('product')
            .doc(product_id)
            .get()
            .then((value) {
          stock_before = value.data()!["stock"];
          sold = value.data()!["sold"];
        });

        await DatabaseService.cutStockAddSold(
            product_id, stock_before - stock_buy, sold + stock_buy);
        i++;
      });

      i = 0;
      await Future.forEach(documents, (element) async {
        num stock_buy = documents[i]["stock_buy"];
        String product_name = documents[i]["name"];
        String product_category = documents[i]["category"];
        String product_description = documents[i]["description"];
        num total_price = documents[i]["price"];

        final transaction = {
          SheetsColumn.date_time: dateTime,
          SheetsColumn.user_name: userName,
          SheetsColumn.receiver_name: receiverName,
          SheetsColumn.phone: userPhone,
          SheetsColumn.product_name: product_name,
          SheetsColumn.product_category: product_category,
          SheetsColumn.product_description: "-",
          SheetsColumn.product_buy: stock_buy.toString(),
          SheetsColumn.total_price: total_price.toString(),
          SheetsColumn.address: address,
        };

        await SheetsFlutter.insert([transaction]);

        i++;
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static cutStockAddSold(String product_id, num stock_now, num sold) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .doc(product_id)
          .update({'stock': stock_now, 'sold': sold});
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static updateAdminToken(String? token, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'token': token});
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static addStock(String product_id, num stock, num newStock) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .doc(product_id)
          .update({'stock': stock + newStock});
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static deleteTransactionProduct(
    String transaction_id,
    List<DocumentSnapshot> documents,
  ) async {
    try {
      var i = 0;
      List<DocumentSnapshot> docTemp = [];
      docTemp.addAll(documents);

      await Future.forEach(docTemp, (element) async {
        String transactionProdId = docTemp[i]["transaction_product_id"];
        await FirebaseFirestore.instance
            .collection('transaction_product')
            .doc(transactionProdId)
            .delete();
        i++;
      });
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static deleteTransaction(
    String transaction_id,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction_id)
          .delete();
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  static saveAdditionalInfoTransaction(String address, String receiverName, String transaction_id) async {
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(transaction_id)
          .update({'user_address': address, 'receiver_name': receiverName});
      return true;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }
}
