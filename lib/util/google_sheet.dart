import 'package:agistaofficial/util/SheetsColumn.dart';
import 'package:gsheets/gsheets.dart';

class SheetsFlutter {
  static String _sheetId = "1N2yi6PIu8hpoknJ9MAvhSVaOVZ0Pdky8PGpV8xFisxg";
  static const _sheetCredentials = r'''
   {
  "type": "service_account",
  "project_id": "agista-official",
  "private_key_id": "3f466bf0af8d5830606c61852ee53bb756258e11",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCuqKAQuk+fsF5B\nPOLqh+90CuBRw0kSXKsltvrsZrHl+LczoWXBORoXEypUqjMRYB44frpYJX5YUFse\nxnCoZJ5NA0KwpoS9aAQod7oeJPr9iw71zEbn3+N51jzM+tnRPYNxax2g7Gi15WBY\njFeO6DtblNiA3Fi1naQdXbDZI+TFOf1qMz077rs78uFazcja+Hz+cxmRn81fuIVF\nXC5kFLath55c1qHmNAk9a972W419c+UIERT9ZofGQpNNd7EM+pyj/a81KAbHGCl7\nHlf591B8ImTb3vauGV4En0HECjIR0iphAstQa4kfKcjwXBbz7R3oox8ZbRLyz2/+\nFI9yLXYzAgMBAAECggEAVUKLoJ7Sb6mw2TfXrZVeFs+YYVFrQkNqaKbCJtSa0yBu\njg2jlodBbTI1386Vz02Ucw+p942V95aCZKuKIym6/O0yiPlAoxU7smV/vWdf/pT7\nYJGvq1FnwfoLBCUQX0wf9iXL+Npu4xxtw8v+kgxbrYEjjwQBaebiTlOGGPmkm4G8\nq9SZxBWLE/dW2YW78Wc0mxlbitwQoxt7FEdRezxZP8HFv5t3nbtTuHkdjx+7HeLE\nkSwxWICsTXut5JN/CkUdO+bUkrK9hXnHM5Lq55l6uWh/mQdpB/Xqt4Jmgp1aBRYK\nEN3TyYmcin3uWxrE08h2me1BhS4lvRC95AqUwe97gQKBgQDfMdOAW+RFKf50xeDK\n7239hUxwziWPHCFfzwcvZfZ5UnrCLkLTVa1nNvfkBVjOmrkiaQw8jZhPIWPA9ops\n+WmP97NJ+UAPGqRcU/pxJw+46Ke7XSa4C2JJUeZGoi2j7IzR8hzDvsc6SbCmUGOs\nb9r/Pl5FaQFTvcZfa+PxzlzBuwKBgQDIVIflIsBF+2bcuxtLtNidB7sfiyWFpgOa\nnQriKj4VcNsC9vAPZzZH/QEF80XhaMvE1Ie877GA7s8cVwsyTEBkr9fNkV97zQrH\nF7IHhBDdI2zj/k/BCo66tlSepy0M4LWSgSTbJZqHZCUjtHJNl54KKS6LkfOxi8oM\noLe/RrO56QKBgQDOCX4YaTvRiVGn1J+OVvavaWVGYVcUxEAe5MvaOoMMPlKqfPAd\njWMU/A5chX8UwooTNOwh3ghzS/x9PlpM/PUw/NWafShgiRSfUrrHx+pgpQ1qDjTX\nA1NJIfy0ybPeNllM2fcp0Cy0JyCWd3F71opQw+9cnfGmr3K31a5II1tHTwKBgQCq\nw+vHddUCkqf/NnuxECqpyOJIpDtK7tYZoQ6a9blQW5BFuauu5aNOwCt0IAiMeeFh\nGm3Or1/W8TqZBNXlfTxS19YURHxpMsKiLd+zKm+Zoc37l1fyzQYXwL7nMshjNtVw\nWifJqwdLrCFAi1v4KmssbChiDvr1eJy2IPYg1ar0qQKBgQCJFLOmr3hCVdl+NZcY\nWOINzagik/nXhnUNa6089SOWJgJK2JFxJc3iwOI8cElgdthbsFT37b0gtoAmyW4k\nPF8uXtNIr7if4k+fHlfAlil/wa0ePs2P3Pic/CmPihm+ybde7wJwtURETtucp2HO\nVt/Kjb5pkbER4olO7m+/3vlQ/w==\n-----END PRIVATE KEY-----\n",
  "client_email": "fluttersheets@agista-official.iam.gserviceaccount.com",
  "client_id": "109511287721305414137",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/fluttersheets%40agista-official.iam.gserviceaccount.com"
  }
  ''';

  static Worksheet? _userSheet;
  static final _gsheet = GSheets(_sheetCredentials);
  static Future init() async {
    try {
      final _spreadsheet = await _gsheet.spreadsheet(_sheetId);
      _userSheet = await _getWorkSheet(_spreadsheet, title: 'Transaction');
      final firstRow = SheetsColumn.getColumn();
      _userSheet!.values.insertRow(1, firstRow);

    } catch(err) {
      print(err);
    }
  }

  static Future<Worksheet> _getWorkSheet(
      Spreadsheet spreadsheet, {
        required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch(err) {
      return await spreadsheet.worksheetByTitle(title)!;
    }
  }

  static Future insert(List<Map<String, dynamic>>rowList) async {
    await _userSheet!.values.map.appendRows(rowList);
  }
}
