import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_err/login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link sent! Check your email'),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'The email address entered does not exist.';
      } else {
        errorMessage = e.message ?? 'An error occurred.';
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(errorMessage),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.cyan[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const LoginPage())); // Revenir à la page précédente
          },
          //elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 270.0),
          // Wrap the Column with SingleChildScrollView Cela garantira que si le contenu dépasse l’espace vertical disponible, les utilisateurs pourront faire défiler pour voir l’intégralité du contenu.
          child: SingleChildScrollView(
            //center pour centrer le contenu
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, //centrer les elements
                children: [
                  Text(
                    'Enter Your Email and we will send you a password reset link',
                    style: GoogleFonts.robotoCondensed(
                      //fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  //email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      //design de label
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none, //no border ici
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  MaterialButton(
                    onPressed: passwordReset,
                    child: Text(
                      'Reset Password',
                      style: GoogleFonts.robotoCondensed(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.cyan[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5), // Bordure arrondie du bouton
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
