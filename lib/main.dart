import 'dart:convert';

import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import './models/item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
    // items.add(Item(title: "Abacate", done: false));
    // items.add(Item(title: "Laranja", done: false));
    // items.add(Item(title: "Banana", done: false));
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  _HomePageState() {
    //tpda vez que a aplicação iniciar vai chamar o load
    load();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decode = jsonDecode(data);
      List<Item> result =
          decode.map((x) => Item.fromJson(x)).toList(); //Criando uma lista

      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.add),
        title: TextFormField(
          controller: newTaskCtrl,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title, style: TextStyle(fontSize: 18)),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = !item.done;
                  save();
                });
              },
            ),
            background: Container(
              color: Colors.pink,
              child: Icon(Icons.cancel),
            ),
            key: Key(item.title),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: add,
      ),
    );
  }
}
