import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart';

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
    _initializeFCM();

    // Initialize Twilio
    twilioFlutter = TwilioFlutter(
      accountSid: 'ACb9d2864c07a27ca774f1a9bd84d2834d',
      authToken: '425da08d9d8004019c88f03616745da0',
      twilioNumber: '+19302122737',
    );

    updateUserLocation();
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // Initialize Firebase Messaging
  Future<void> _initializeFCM() async {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        _saveFCMToken(token);
      }
    });
  }

  // Save FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  // Get user's current location
  Future<String> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  // Update user's location in Firestore
  Future<void> updateUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'email': user.email,
      }, SetOptions(merge: true));
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  // Get FCM tokens of nearby users within 3km
  Future<List<String>> getNearbyUserTokens(Position senderPosition) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    List<String> fcmTokens = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('latitude') && data.containsKey('longitude')) {
        double lat = data['latitude'];
        double lon = data['longitude'];
        double distance = calculateDistance(
            senderPosition.latitude, senderPosition.longitude, lat, lon);

        if (distance <= 3 && data.containsKey('fcmToken')) {
          fcmTokens.add(data['fcmToken']);
        }
      }
    }
    print(fcmTokens);
    return fcmTokens;
  }

  // Send SOS message via Twilio and FCM
  Future<void> _sendSOS() async {
    print("Sending SOS...");
    String location = await _getUserLocation();
    String message = '🚨 SOS Alert! Someone nearby needs help! Location: $location';

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user signed in!");
      return;
    }

    Position senderPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Fetch emergency contacts
    QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
        .collection('contacts')
        .where('email', isEqualTo: user.email)
        .get();

    List<String> emergencyNumbers = contactsSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['phoneNo'].toString())
        .toList();

    // Send SOS message via Twilio SMS
    for (String phoneNumber in emergencyNumbers) {
      try {
        await twilioFlutter.sendSMS(
          toNumber: phoneNumber,
          messageBody: message,
        );
        print("SOS sent to $phoneNumber via SMS");
      } catch (e) {
        print("Failed to send SMS to $phoneNumber: $e");
      }
    }

    // Fetch nearby users' FCM tokens
    List<String> fcmTokens = await getNearbyUserTokens(senderPosition);

    if (fcmTokens.isNotEmpty) {
      await _sendFCMNotification(fcmTokens, message);
    }
  }

  // Send notification via Firebase HTTP v1 API
  Future<void> _sendFCMNotification(List<String> tokens, String message) async {
    const String projectId = "sos-app-a03fb"; // Replace with your Firebase project ID
    const String fcmUrl = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

    String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print("Failed to get access token.");
      return;
    }

    for (String token in tokens) {
      print(token);
      final body = json.encode({
        "message": {
          "token": token,
          "notification": {
            "title": "SOS Alert 🚨",
            "body": message,
          }
        }
      });

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      };

      try {
        final response = await http.post(Uri.parse(fcmUrl), headers: headers, body: body);
        if (response.statusCode == 200) {
          print("FCM Notification sent successfully!");
        } else {
          print("Failed to send FCM Notification: ${response.body}");
        }
      } catch (e) {
        print("Error sending FCM notification: $e");
      }
    }
  }

  // Function to get OAuth 2.0 access token
Future<String?> _getAccessToken() async {
  try {
    // Load service account JSON file from assets
    final serviceAccountJson =
        await rootBundle.loadString("assets/icons/serviceAccountKey.json");

    final Map<String, dynamic> credentialsMap = json.decode(serviceAccountJson);
    final ServiceAccountCredentials credentials =
        ServiceAccountCredentials.fromJson(credentialsMap);

    final List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await clientViaServiceAccount(credentials, scopes);
    
    return client.credentials.accessToken.data;
  } catch (e) {
    print("Failed to get access token: $e");
    return null;
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
