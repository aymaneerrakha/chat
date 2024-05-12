import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_application_err/genereimage.dart';
import 'package:flutter_application_err/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_err/home.dart';
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'Ayman', lastName: 'Errakha');
  final ChatUser _gptChatUser = ChatUser(id: '2', firstName: 'Chat', lastName: 'GBT');

  List<ChatMessage> _messages = <ChatMessage>[];
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText _speech = stt.SpeechToText();

  Color buttonColor = Colors.blue;

@override
void initState() {
  super.initState();
  // Appeler la fonction pour récupérer les anciens messages depuis Firestore
  fetchOldMessages();
}


Future<void> fetchOldMessages() async {
  try {
    // Récupérer l'utilisateur authentifié
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Récupérer la référence de la collection 'messages' dans Firestore
      CollectionReference messagesRef = FirebaseFirestore.instance.collection('message1');
      // Récupérer tous les documents dans la collection 'messages' pour l'utilisateur actuel, triés par date croissante
      QuerySnapshot querySnapshot = await messagesRef.where('userId', isEqualTo: currentUser.uid).orderBy('date').get();
      // Parcourir les documents récupérés
      querySnapshot.docs.forEach((doc) {
        // Récupérer les données de chaque document
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if(data['qui']==0){
          ChatMessage message = ChatMessage(
            text: data['texte'], // Récupérer le texte du message
            user: _currentUser, // Définir l'utilisateur comme l'utilisateur GPT
            createdAt: (data['date'] as Timestamp).toDate(), // Récupérer la date de création du message
          );
          _messages.insert(0, message); // Insérer le message au début de la liste
        } else {
          ChatMessage message = ChatMessage(
            text: data['texte'], // Récupérer le texte du message
            user: _gptChatUser, // Définir l'utilisateur comme l'utilisateur GPT
            createdAt: (data['date'] as Timestamp).toDate(), // Récupérer la date de création du message
          );
          _messages.insert(0, message); // Insérer le message au début de la liste
        }
        // Créer un objet ChatMessage à partir des données
        // Ajouter le message à la liste des messages
      });
      // Rafraîchir l'interface utilisateur pour refléter les changements
      setState(() {});
    }
  } catch (e) {
    print('Erreur lors de la récupération des anciens messages : $e');
  }
}


  


// /// Fonction pour ajouter un message à Firestore de chatbot avec l'ID de l'utilisateur
Future<void> ajouterMessage(String message) async {
  try {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    // Vérifier si l'utilisateur est authentifié
    if (user != null) {
      // Ajouter le message avec l'ID de l'utilisateur comme champ "utilisateur"
      await FirebaseFirestore.instance.collection('message1').add({
        'texte': message,
        'date': Timestamp.now(),
        'qui': 1,
        'utilisateur': user.uid, // ID de l'utilisateur actuel
      });
      print('Message ajouté avec succès');
  
    } else {
      print('Utilisateur non authentifié');
    }
  } catch (e) {
    print('Erreur lors de l\'ajout du message: $e');
  }
}
/// Fonction pour ajouter un message à Firestore de User avec l'ID de l'utilisateur
Future<void> ajouterMessageUser(String message) async {
  try {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    // Vérifier si l'utilisateur est authentifié
    if (user != null) {
      // Ajouter le message avec l'ID de l'utilisateur comme champ "utilisateur"
      await FirebaseFirestore.instance.collection('message1').add({
        'texte': message,
        'date': Timestamp.now(),
        'qui': 0,
        'utilisateur': user.uid, // ID de l'utilisateur actuel
      });
      print('Message ajouté avec succès');
  
    } else {
      print('Utilisateur non authentifié');
    }
  } catch (e) {
    print('Erreur lors de l\'ajout du message: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.cyan[200],
        title: const Text("ChatGBT"),
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


      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  // decoration: BoxDecoration(
                  //   color: Colors.white, // Couleur d'arrière-plan de la zone de chat
                  //   image: DecorationImage(
                  //     image: NetworkImage(
                  //         ""),
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  child: DashChat(
                    currentUser: _currentUser,
                    messageOptions: const MessageOptions(
                      currentUserContainerColor: Colors.blue, // Couleur de l'arrière-plan de vos messages
                    ),
                    onSend: (ChatMessage m) {
                      getChatResponse(m);
                    },
                    messages: _messages,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action à effectuer lorsque le bouton est pressé
                  speakLastMessage();
                },
                child: const Text('Lire le dernier message'),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.65, // 5% du haut de l'écran
            left: MediaQuery.of(context).size.width * 0.45, // 5% de la gauche de l'écran
            child: GestureDetector(
              onLongPress: () async {
                // Action à effectuer lorsque le long appui commence
                print("Début de la reconnaissance vocale...");
                setState(() {
                  buttonColor = Colors.red; // Changement de couleur en rouge
                });
                if (await _speech.initialize()) {
                  print("Initialisation réussie. Enregistrement...");
                  _speech.listen(
                    onResult: (result) {
                      if (result.finalResult) {
                        String text = result.recognizedWords;
                        print("Texte reconnu: $text");
                        setState(() {
                          _messages.insert(
                            0,
                            ChatMessage(
                              text: text,
                              user: _currentUser,
                              createdAt: DateTime.now(),
                            ),
                          );
                        });
                        getResponseForText(text);
                      }
                    },
                  );
                } else {
                  print("Impossible d'initialiser la reconnaissance vocale.");
                }
              },
              onLongPressEnd: (details) {
                // Action à effectuer lorsque le long appui se termine
                print("Fin de l'enregistrement vocal.");
                setState(() {
                  buttonColor = Colors.blue; // Retour à la couleur bleue
                });
                _speech.stop();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addResponseMessage(String text) {
    String modifiedResponse = text.replaceAll('*', '');
    ChatMessage responseMessage = ChatMessage(
      text: modifiedResponse,
      user: _gptChatUser,
      createdAt: DateTime.now(),
    );
       ajouterMessage(text);    //stocké messaage dans base de donne de chat
    setState(() {
      _messages.insert(0, responseMessage);
    });
  }

  Future<void> getChatResponse(ChatMessage m) async {
    ajouterMessageUser(m.text);   //ajoute message de user
    setState(() {
      _messages.insert(0, m);
    });
    print("voila 1");

    List<Map<String, dynamic>> messagesHistory = _messages.map((message) {
      return {'text': message.text};
    }).toList();
     print("voila 2");
       
    if (messagesHistory.isNotEmpty) {
      Map<String, dynamic> requestBody = {
        'contents': [
          {'parts': [{'text': messagesHistory.first['text']}]}
        ]
      };
    
    // Construire une requête Firestore pour récupérer les réponses
    // CollectionReference messagesRef = FirebaseFirestore.instance.collection('messages');
    // QuerySnapshot querySnapshot = await messagesRef
    //     .where('texte', whereIn: messagesHistory)
    //     .orderBy('date', descending: true)
    //     .limit(1)
    //     .get();
  //
 

      String jsonRequest = jsonEncode(requestBody);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      try {
        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCGR84XoLd1Q08Ysy84mKglW6UEFfbp_Uo'),
          headers: headers,
          body: jsonRequest,
        );
          print("voila 3");
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          List<dynamic> candidates = responseData['candidates'];
          if (candidates.isNotEmpty && candidates[0].containsKey('content')) {
            String responseText = candidates[0]['content']['parts'][0]['text'];
             
            addResponseMessage(responseText);
          

          }
        } else {
          print('Erreur lors de la requête au modèle : ${response.body}');
        }
      } catch (e) {
        print('Erreur lors de la requête au modèle : $e');
      }
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setPitch(1.5);
    await flutterTts.speak(text);
  }

  void speakLastMessage() {
    if (_messages.isNotEmpty) {
      speak(_messages.first.text);
    }
  }

  Future<void> getResponseForText(String text) async {
    if (text.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyCGR84XoLd1Q08Ysy84mKglW6UEFfbp_Uo'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'contents': [
              {'parts': [{'text': text}]}
            ]
          }),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          List<dynamic> candidates = responseData['candidates'];
          if (candidates.isNotEmpty && candidates[0].containsKey('content')) {
            String responseText = candidates[0]['content']['parts'][0]['text'];

            addResponseMessage(responseText);
            
          }
        } else {
          print('Erreur lors de la requête au modèle : ${response.body}');
        }
      } catch (e) {
        print('Erreur lors de la requête au modèle : $e');
      }
    }
  }
}


