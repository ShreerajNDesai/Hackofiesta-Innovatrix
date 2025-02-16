import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TwilioFlutter twilioFlutter;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // Initialize Twilio
    twilioFlutter = TwilioFlutter(
      accountSid: 'ACb9d2864c07a27ca774f1a9bd84d2834d',
      authToken: '425da08d9d8004019c88f03616745da0',
      twilioNumber: '+19302122737',
    );
  }

  // Function to request location permission
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // Function to get the user's location
  Future<String> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled';
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied';
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  // Function to send SOS messages to emergency contacts
  // Function to send SOS messages to emergency contacts
Future<void> _sendSOS() async {
  print("Sending SOS...");
  String location = await _getUserLocation();
  String message = '🚨 SOS Alert! I need help! My current location: $location';

  print(message);

  String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  if (userEmail.isEmpty) {
    print("No user signed in!");
    return;
  }

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('contacts')
      .where('email', isEqualTo: userEmail)
      .get();

  print(userEmail);
  print(snapshot.docs);
  for (var doc in snapshot.docs) {
    print(snapshot);

    var data = doc.data() as Map<String, dynamic>;
    String phoneNumber = data['phoneNo'].toString();

    try {
      await twilioFlutter.sendSMS(
        toNumber: phoneNumber,
        messageBody: message,
      );
      print("SOS sent to $phoneNumber");
    } catch (e) {
      print("Failed to send SOS to $phoneNumber: $e");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xffFFFFFF),
        toolbarHeight: 80,
        title: Text(
          'Emergency',
          style: TextStyle(
            color: Color.fromRGBO(241, 80, 62, 100),
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: GestureDetector(
            onDoubleTap: () async {
                await _sendSOS();
              }, // Trigger SOS on double tap  
            // onTap: () => setState(() async {
            //   String location = await _getUserLocation();
            //   await twilioFlutter.sendSMS(
            //   toNumber : '+917021763289',
            //   messageBody : 'hello you have a message from the SOS app. $location',
            //   );
            // }), // Trigger SOS on tap
            child: RiveAnimation.asset('assets/icons/sos_animation1.riv'),
          ),
        ),
      ),
    );
  }
}
