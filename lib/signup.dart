import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_err/login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  //pour stocker email et password
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  String? errorPassword;
  //String? errorCaractere;
  String? errorEmail;

  bool ConfirmedPassword() {
    if (passwordController.text.trim() == passwordConfirmController.text.trim())
      return true;
    else {
      return false;
    }
  }

  Future signUp() async {
    // Réinitialiser les erreurs
    setState(() {
      errorPassword = null;
      errorEmail = null;
    });

    try {
      if (!ConfirmedPassword()) {
        // Afficher une erreur si le mot de passe n'est pas confirmé
        setState(() => errorPassword = 'Votre mot de passe ne correspond pas');
      }

      if (passwordController.text.trim().length < 6) {
        // Afficher une erreur si le mot de passe a moins de six caractères
        setState(() => errorPassword =
            'Le mot de passe doit comporter au moins six caractères');
      }

      if (errorPassword == null) {
        // Si aucune erreur de mot de passe, vérifier l'unicité de l'email
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        // Rediriger vers la page de connexion une fois l'inscription réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Afficher une erreur si l'email est déjà utilisé
        setState(() =>
            errorEmail = 'L\'email que vous avez choisi est déjà utilisé');
      }
    } catch (e) {
      // Afficher un message d'erreur générique en cas d'échec de l'inscription
      print('Erreur lors de l\'inscription : $e');
    }
  }

  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
  }

  void openSignin() {
    Navigator.of(context).pushReplacementNamed('signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      //safearea pour faire espace entre le contenue et la bare
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          // Wrap the Column with SingleChildScrollView Cela garantira que si le contenu dépasse l’espace vertical disponible, les utilisateurs pourront faire défiler pour voir l’intégralité du contenu.
          child: SingleChildScrollView(
            //center pour centrer le contenu
            child: Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, //centrer les elements
                children: [
                  //image
                  

                  //title
                  Text(
                    'SIGN UP',
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  //subtitle
                  Text(
                    'Welcome ! Here you can sign up :-)',
                    style: GoogleFonts.robotoCondensed(fontSize: 18),
                  ),
                  //espace entre welcome back et label
                  SizedBox(
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
                        border: Border.all(
                            color: errorEmail != null
                                ? Colors.red
                                : Colors.transparent),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none, //no border ici
                            hintText: 'enter your email',
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (errorEmail != null)
                        Text(
                          errorEmail!,
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  //password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      //design de label
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: errorPassword != null
                                ? Colors.red
                                : Colors.transparent),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true, //pour masquer le code
                          decoration: InputDecoration(
                            border: InputBorder.none, //no border ici
                            hintText: 'enter password',
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  //confirm password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      //design de label
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: errorPassword != null
                                ? Colors.red
                                : Colors.transparent),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: passwordConfirmController,
                          obscureText: true, //pour masquer le code
                          decoration: InputDecoration(
                            border: InputBorder.none, //no border ici
                            hintText: ' confirm password',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (errorPassword != null)
                        Text(
                          errorPassword!,
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  //button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: GestureDetector(
                      onTap: () {
                        signUp();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.cyan[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text(
                          'Sign up',
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  //text sign in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member? ',
                        style: GoogleFonts.robotoCondensed(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: openSignin,
                        child: Text(
                          'sign in here',
                          style: GoogleFonts.robotoCondensed(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
