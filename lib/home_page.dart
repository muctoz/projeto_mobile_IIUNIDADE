import 'package:flutter/material.dart';
import 'package:projeto_mobile/validation.dart';
import 'Notas.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(''),
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Icon(
            Icons.menu,
          ),
        ),
        backgroundColor: Color(0xFF011E36), // Cor de fundo da AppBar
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF011E36), // Cor de fundo desejada
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Image.asset(
                'assets/images/Notes.png',
                height: 150,
              ),
              ListTile(
                title: Text(
                  'Notas',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage()),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Deslogar',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF011E36), // Cor de fundo da tela
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 120,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotePage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 100,
                          width: double
                              .infinity, // Defini a largura como infinita para evitar o esticamento
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note, size: 30),
                              SizedBox(height: 8),
                              Text(
                                'Notas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
