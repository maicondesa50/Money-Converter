import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// Put the Link of the API
const request = 'https://api.hgbrasil.com/finance';

void main() async {
  runApp(
    MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

//Map to take the Json and return 
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller of what is type
  final _realController = TextEditingController();
  final _dolarController = TextEditingController();
  final _euroController = TextEditingController();

  double dolar;
  double euro;

  // Covert real to Dolar and Euro, if one of this is empty clear all.
  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    _dolarController.text = (real / dolar).toStringAsFixed(2);
    _euroController.text = (real / euro).toStringAsFixed(2);
  }

  // Covert Dolar to real and Euro, if one of this is empty clear all.
  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    _realController.text = (dolar * this.dolar).toStringAsFixed(2);
    _euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  // Covert Euro to Real and Dolar, if one of this is empty clear all.
  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    _realController.text = (euro * this.euro).toStringAsFixed(2);
    _dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  // Function to Clear all.
  void _clearAll(){
    _realController.text = "";
    _dolarController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Conversor de Moedas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),

      //Make a Builder until he get the response.
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              // If Conection is note done, return a text Waiting ...
                return Center(
                  child: Text(
                    'Carregando Dados...',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
                //If Has error on the Conection return a text with error
              default:
                if (snapshot.hasError) {
                  Center(
                    child: Text(
                      'Erro ao Carregar Dados :(',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                  // If everything Ok Receive the data and make a UI
                } else {
                  dolar = snapshot.data["results"]['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        _buildTextField(
                            'Reais', 'R\$', _realController, _realChanged),
                        Divider(),
                        _buildTextField(
                            'Dólares', 'UR\$', _dolarController, _dolarChanged),
                        Divider(),
                        _buildTextField(
                            'Euros', '€', _euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

//Builder template to Where put the quantity of coins.
Widget _buildTextField(String label, String prefix,
    TextEditingController controll, Function money) {
  return TextField(
    controller: controll,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25.0,
    ),
    onChanged: money,
  );
}
