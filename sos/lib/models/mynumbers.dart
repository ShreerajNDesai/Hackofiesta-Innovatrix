import 'package:cloud_firestore/cloud_firestore.dart';

class MyNumbers {
  String name;
  int phoneNo;

  MyNumbers({
    required this.name,
    required this.phoneNo,
  });

  // Factory constructor to create a MyNumbers instance from Firestore document
  factory MyNumbers.fromMap(Map<String, dynamic> data) {
    return MyNumbers(
      name: data['name'] ?? 'Unknown',
      phoneNo: data['phoneNo'] ?? 0,
    );
  }

  // Fetch contacts from Firestore
  static Future<List<MyNumbers>> getMyNumbers() async {
    List<MyNumbers> contacts = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('contacts').get();
      
      contacts = snapshot.docs
          .map((doc) => MyNumbers.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching contacts: $e");
    }
    return contacts;
  }
}
