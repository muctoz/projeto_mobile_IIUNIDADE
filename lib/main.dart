
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF011E36),
        appBar: null,
        body: SafeArea(
          child: LoginPage(),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _email;
  String? _password;
  bool _isLoading = false;
  bool _isCredentialsSaved = false;

  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    if (email != null && password != null) {
      setState(() {
        _email = email;
        _password = password;
        _isCredentialsSaved = true;
      });
    }
  }

  Future<void> _openRegistrationModal() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? username;
        String? email;
        String? password;

        return AlertDialog(
          title: Text('Cadastro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  username = value.trim();
                },
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário',
                ),
              ),
              TextField(
                onChanged: (value) {
                  email = value.trim();
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                onChanged: (value) {
                  password = value.trim();
                },
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email!,
                    password: password!,
                  );

                  // Cadastro bem-sucedido
                  // Você pode fazer algo com o usuário registrado, se necessário
                  // Por exemplo, salvar o nome de usuário no Firestore
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userCredential.user!.uid)
                      .set({
                    'username': username,
                    'email': email,
                  });

                  // Criação de coleções para notas com senha e notas sem senha
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userCredential.user!.uid)
                      .collection('NotasComSenha')
                      .doc('senha')
                      .set({});
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userCredential.user!.uid)
                      .collection('NotasSemSenha')
                      .doc('semSenha')
                      .set({
                        'title':"Nota Padrão",
                        'content':"Conteúdo Padrão",
                        'documentId':'semSenha',
                      });

                  Navigator.of(context).pop();
                } catch (e) {
                  if (e is FirebaseAuthException) {
                    if (e.code == 'weak-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('A senha é muito fraca.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else if (e.code == 'email-already-in-use') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'O email já está sendo usado por outra conta.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Erro ao realizar o cadastro. Por favor, tente novamente mais tarde.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Erro ao realizar o cadastro. Por favor, verifique sua conexão com a internet.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text('Cadastrar'),
            ),
          ],
        );
      },
    );
  }

Future<void> _login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _email!,
      password: _password!,
    );

    // Login bem-sucedido
    // Você pode fazer algo com o usuário logado, se necessário

    if (_isCredentialsSaved) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _email!);
      await prefs.setString('password', _password!);
    }

    // Recupere as notas com senha do usuário
    QuerySnapshot notesWithPasswordSnapshot = await FirebaseFirestore
        .instance
        .collection('Users')
        .doc(userCredential.user!.uid)
        .collection('NotasComSenha')
        .get();

    List<Map<String, dynamic>> notesWithPassword = notesWithPasswordSnapshot
        .docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Recupere as notas sem senha do usuário
    QuerySnapshot notesWithoutPasswordSnapshot = await FirebaseFirestore
        .instance
        .collection('Users')
        .doc(userCredential.user!.uid)
        .collection('NotasSemSenha')
        .get();

    List<Map<String, dynamic>> notesWithoutPassword = notesWithoutPasswordSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    Provider.of<UserProvider>(context, listen: false).setUserCredential(userCredential);
    Provider.of<UserProvider>(context, listen: false).setUser(userCredential.user!);
    Provider.of<UserProvider>(context, listen: false).setNotesWithPassword(notesWithPassword);
    Provider.of<UserProvider>(context, listen: false).setNotesWithoutPassword(notesWithoutPassword);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  } on FirebaseAuthException catch (e) {
    // Tratamento de erros de login
    if (e.code == 'user-not-found') {
      print('Usuário não encontrado para o email fornecido.');
    } else if (e.code == 'wrong-password') {
      print('Senha incorreta para o email fornecido.');
    } else {
      print('Erro desconhecido: ${e.code}');
    }

    setState(() {
      _isLoading = false;
    });
  } catch (e) {
    print('Erro desconhecido: $e');
    setState(() {
      _isLoading = false;
    });
  }
}


  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    setState(() {
      _email = null;
      _password = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF011E36),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/Notes.png',
                          height: 150,
                        ),
                        SizedBox(height: 20),
                        if (_isCredentialsSaved)
                          Text(
                            'Usuário cadastrado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              _email = value.trim();
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              _password = value.trim();
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(120, 50),
                                primary: Color(0xFF01FFA9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Entrar'),
                            ),
                            ElevatedButton(
                              onPressed: _openRegistrationModal,
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF01FFA9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size(120, 50),
                              ),
                              child: Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Colors.white,
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
