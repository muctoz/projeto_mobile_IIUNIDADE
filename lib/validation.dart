import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notas_protected.dart';

class Validation extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Validation> {
  String? _password1;

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? password1 = prefs.getString('passwordUnlock');
    if (password1 == null) {
      _showPasswordDialog();
    } else {
      setState(() {
        _password1 = password1;
      });
    }
  }

  Future<void> _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastrar senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text == confirmPasswordController.text) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('passwordUnlock', passwordController.text);
                  setState(() {
                    _password1 = passwordController.text;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('As senhas não coincidem.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _signIn() async {
    
    if (_password1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A senha ainda não foi cadastrada.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Digite a senha'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == _password1) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotePageProtect()),);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Senha incorreta.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text('Entrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desbloquear Notas '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/Notes.png'
              ,
              height: 35, // altura desejada da imagem
            ),
            SizedBox(height: 20), // espaço entre a imagem e o botão
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // tamanho desejado do botão
              ),
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
