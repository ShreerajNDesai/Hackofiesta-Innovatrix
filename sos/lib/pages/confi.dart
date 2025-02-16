import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sos/models/mynumbers.dart';
import 'package:sos/models/pernumber.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Numbers> numbers = [];
  bool isEditMode = false;
  String? userEmail;
  String countryCode = "+1"; // Default country code

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    getInitialInfo();
  }

  Future<void> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  Future<void> getInitialInfo() async {
    numbers = Numbers.getNumbers();
    setState(() {});
  }

 void _showAddContactDialog({String? docId, String? currentName, String? currentPhone}) {
  TextEditingController nameController = TextEditingController(text: currentName ?? "");
  TextEditingController phoneController = TextEditingController();

  // Country code list (default +91, removed +1)
  List<String> countryCodes = ["+91", "+44", "+61", "+49"];

  String selectedCountryCode = "+91"; // Default
  String extractedPhoneNumber = "";

  if (currentPhone != null && currentPhone.isNotEmpty) {
    RegExp regex = RegExp(r'^(\+\d+)(\d+)$');
    Match? match = regex.firstMatch(currentPhone);
    
    if (match != null) {
      selectedCountryCode = match.group(1) ?? "+91";
      extractedPhoneNumber = match.group(2) ?? "";
    } else {
      extractedPhoneNumber = currentPhone; // Fallback if no match
    }
  }

  phoneController.text = extractedPhoneNumber;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(docId == null ? "Add Emergency Contact" : "Edit Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Country Code: "),
                DropdownButton<String>(
                  value: countryCodes.contains(selectedCountryCode) ? selectedCountryCode : "+91",
                  items: countryCodes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCountryCode = newValue!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String name = nameController.text.trim();
              String phone = phoneController.text.trim();

              if (name.isNotEmpty && phone.isNotEmpty && userEmail != null) {
                String formattedPhone = "$selectedCountryCode$phone";

                if (docId == null) {
                  // Add new contact
                  await FirebaseFirestore.instance.collection('contacts').add({
                    'name': name,
                    'phoneNo': formattedPhone,
                    'email': userEmail,
                  });
                } else {
                  // Update existing contact
                  await FirebaseFirestore.instance.collection('contacts').doc(docId).update({
                    'name': name,
                    'phoneNo': formattedPhone,
                  });
                }

                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}

  Future<void> _deleteContact(String docId) async {
    await FirebaseFirestore.instance.collection('contacts').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Emergency Contacts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Numbers',
                style: TextStyle(
                  color: Color.fromRGBO(136, 135, 135, 1),
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(1),
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: numbers[index].boxColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: SvgPicture.asset('assets/icons/Con Per.svg',
                          height: 40),
                      title: Text(
                        numbers[index].name,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(numbers[index].phoneNo.toString()),
                      onTap: () {},
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    'My Emergency Numbers',
                    style: TextStyle(
                      color: Color.fromRGBO(136, 135, 135, 1),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 70),
                  IconButton(
                    icon: Icon(isEditMode ? Icons.check : Icons.edit,
                        color: Colors.black),
                    onPressed: () {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: userEmail != null
                    ? FirebaseFirestore.instance
                        .collection('contacts')
                        .where('email', isEqualTo: userEmail)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final myContacts = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(1),
                    itemCount: myContacts.length,
                    itemBuilder: (context, index) {
                      var contactData =
                          myContacts[index].data() as Map<String, dynamic>;
                      String docId = myContacts[index].id;

                      return Container(
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(23, 62, 62, 63),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: SvgPicture.asset('assets/icons/Con Per.svg',
                              height: 40),
                          title: Text(
                            contactData['name'],
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(contactData['phoneNo'].toString()),
                          trailing: isEditMode
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        'assets/icons/Edit_con.svg',
                                        height: 24,
                                      ),
                                      onPressed: () => _showAddContactDialog(
                                        docId: docId,
                                        currentName: contactData['name'],
                                        currentPhone: contactData['phoneNo']
                                            .toString()
                                            .replaceAll(RegExp(r'^\+\d+'), ''),
                                      ),
                                    ),
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        'assets/icons/Delete_btn.svg',
                                        height: 8,
                                      ),
                                      onPressed: () => _deleteContact(docId),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
