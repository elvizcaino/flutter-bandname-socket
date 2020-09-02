import "dart:io";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_name/models/band.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: "1", name: "Binomio de Oro", votes: 5),
    Band(id: "2", name: "Jean Carlos Centeno", votes: 5),
    Band(id: "3", name: "Diomedes Diaz", votes: 3),
    Band(id: "4", name: "Los Diablitos", votes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Band Names", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: _addNewBand
      ),
   );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print("direction: $direction");
      },
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Delete Band", style: TextStyle(color: Colors.white)),
        )
      ),
      child: ListTile(
        title: Text(band.name),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        trailing: Text("${band.votes}", style: TextStyle(fontSize: 20)),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();
    final textFocus = FocusNode();

    textFocus.requestFocus();

    if(Platform.isIOS) {
      return showCupertinoDialog(
        context: context, 
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text("New band name"),
            content: CupertinoTextField(
              controller: textController,
              focusNode: textFocus,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Add"),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("Dismiss"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
      );
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("New band name"),
          content: TextField(
            controller: textController,
            focusNode: textFocus,
          ),
          actions: [
            MaterialButton(
              elevation: 5,
              child: Text("Add"),
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            )
          ],
        );
      }
    );
  }
  void addBandToList(String name) {
    if(name.length > 1) {
      this.bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}