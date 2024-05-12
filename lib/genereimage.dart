import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_err/Chat.dart';
import 'package:flutter_application_err/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class GenerateImagePage extends StatefulWidget {
  @override
  _GenerateImagePageState createState() => _GenerateImagePageState();
}

class _GenerateImagePageState extends State<GenerateImagePage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;
  Uint8List? imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[200],
        title: Text('Generate Image from Text'),
      ),
      drawer: Drawer(
  child: FutureBuilder<User?>(
    future: FirebaseAuth.instance.authStateChanges().first,
    builder: (context, AsyncSnapshot<User?> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else {
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.cyan[200],
                ),
                child: Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text(user.email ?? 'Email non disponible'),
                onTap: () {
                  // Action à effectuer lorsque l'utilisateur tape sur cette option
                },
              ),
                ListTile(
                title: Text('Chat'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()),
                      );
                    },
              ),
              ListTile(
                title: Text('Genere image'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenerateImagePage()),
                      );
                    },
              ),
              ListTile(
                title: Text('Déconnexion'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          );
        } else {
          return Text('Utilisateur non connecté');
        }
      }
    },
  ),
),
      body: Column(
        children: [
        TextField(
             controller: _textEditingController,
             decoration: InputDecoration(
             labelText: 'Enter your text',
             hintText: 'Type your text here...',
             border: OutlineInputBorder( // Ajouter une bordure autour du TextField
             borderRadius: BorderRadius.circular(10.0), // Définir le rayon de la bordure
             ),
           contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Ajouter du rembourrage au contenu du TextField
           labelStyle: TextStyle(color: Colors.blue), // Couleur du texte de l'étiquette
            hintStyle: TextStyle(color: Colors.grey), // Couleur du texte d'indice
         ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _generateImage(context);
            },
            child: Text('Generate Image'),
          ),
          if (isLoading)
            CircularProgressIndicator(),
          if (imageData != null)
            Expanded(
              child: Image.memory(imageData!),
            ),
        ],
      ),
    );
  }

  Future<void> _generateImage(BuildContext context) async {
    String prompt = _textEditingController.text;
    String engineId = "stable-diffusion-v1-6";
    String apiHost = 'https://api.stability.ai';
    String apiKey = 'sk-BMoqztqbhy0om6FSuci6lqhJ95dmqYt3JlZdwVogIAxJA83b';

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$apiHost/v1/generation/$engineId/text-to-image'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "image/png",
        "Authorization": "Bearer $apiKey"
      },
      body: jsonEncode({
        "text_prompts": [
          {
            "text": prompt,
            "weight": 1,
          }
        ],
        "cfg_scale": 7,
        "height": 1024,
        "width": 1024,
        "samples": 1,
        "steps": 30,
      }),
    );

    if (response.statusCode == 200) {
      try {
        setState(() {
          imageData = response.bodyBytes;
          isLoading = false;
        });
      } catch (e) {
        print("Failed to decode image: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("Failed to generate image. Status code: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }
}
