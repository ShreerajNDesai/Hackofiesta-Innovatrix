import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sos/pages/bottomnavpage.dart';
import 'package:sos/pages/login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  String? emailError;
  String? passwordError;

  void newuser() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (emailcontroller.text.isEmpty) {
      setState(() {
        emailError = "Email cannot be empty";
      });
      return;
    }

    if (passwordcontroller.text.isEmpty) {
      setState(() {
        passwordError = "Password cannot be empty";
      });
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing dialog manually
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      Navigator.pop(context); // Dismiss loading dialog

      // Navigate to home page or show success message
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNavPage()));
    } on FirebaseAuthException catch (e) {
      Navigator.pop(
          context); // Ensure the loading dialog is dismissed before showing errors

      setState(() {
        if (e.code == 'weak-password') {
          passwordError = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          emailError = 'The account already exists for that email.';
        } else {
          emailError = "Failed to sign up. Try again.";
        }
      });
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        emailError = "An unexpected error occurred.";
      });
    }
  }

  siginwithgoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    try {
      await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
              accessToken: googleAuth?.accessToken,
              idToken: googleAuth?.idToken));

    showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing dialog manually
    builder: (context) {
      return const Center(child: CircularProgressIndicator());
    });


      if (googleUser == null) {
        return;
      }
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNavPage()));
    } on FirebaseAuthException {
      setState(() {
        emailError = "Authentication failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffFFFFFF),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      'SignUp',
                      style: TextStyle(fontSize: 36, color: Color(0xff000000)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 69,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 230, 230, 230),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: siginwithgoogle,
                      child: Container(
                        height: 47,
                        width: 345,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 239, 239, 239),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(width: 1, color: Colors.black)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/Google.svg'),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                "Continue with Google",
                                style: TextStyle(fontFamily: 'Mplus'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                Text(
                  'or',
                  style: TextStyle(fontFamily: 'Mplus', fontSize: 17),
                ),
                SizedBox(
                  height: 13,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 260,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 230, 230, 230),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: emailcontroller,
                        style: TextStyle(fontFamily: 'Mplus'),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          filled: true,
                          fillColor: Color.fromARGB(255, 239, 239, 239),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff000000)),
                              borderRadius: BorderRadius.circular(18)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff000000)),
                              borderRadius: BorderRadius.circular(18)),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                              color: Color(0xff8F8F8F), fontFamily: 'Mplus'),
                          errorText: emailError,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: passwordcontroller,
                        style: TextStyle(fontFamily: 'Mplus'),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          filled: true,
                          fillColor: Color.fromARGB(255, 239, 239, 239),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff000000)),
                              borderRadius: BorderRadius.circular(18)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff000000)),
                              borderRadius: BorderRadius.circular(18)),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: Color(0xff8F8F8F), fontFamily: 'Mplus'),
                          errorText: passwordError,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TextButton(
                          onPressed: newuser,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.black),
                              minimumSize:
                                  WidgetStatePropertyAll(Size(246, 57))),
                          child: Text(
                            'SignUp',
                            style: TextStyle(fontSize: 26, color: Colors.white),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                Text("Have an Account",
                    style: TextStyle(
                        fontFamily: 'Mplus', color: Color(0xff868686))),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text("Login?",
                        style: TextStyle(
                            fontFamily: 'Mplus', color: Color(0xff000000)))),
              ],
            ),
          ),
        ));
  }
}
