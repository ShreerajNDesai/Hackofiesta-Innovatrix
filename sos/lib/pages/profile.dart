import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sos/pages/editprofilepage.dart';
import 'package:sos/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/Edit.svg',
              height: 20,
            ),
          ),
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          //Profile Image
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundColor: const Color.fromARGB(255, 213, 212, 212),
              child: SvgPicture.asset(
                'assets/icons/Con Per.svg',
                height: 80,
              ),
            ),
          ),
          SizedBox(height: 20),

          //User Name
          Center(
            child: Column(
              children: [
                Text(
                  FirebaseAuth.instance.currentUser!.email!.split('@')[0],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(FirebaseAuth.instance.currentUser!.email!,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 75, 75, 75),
                      fontSize: 15,
                    )),
              ],
            ),
          ),
          SizedBox(height: 30),

          //Logout Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                    fontSize: 18, color: const Color.fromARGB(255, 255, 0, 0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
