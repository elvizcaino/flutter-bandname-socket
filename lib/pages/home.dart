import "dart:io";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_name/services/socket_service.dart';
import 'package:band_name/models/band.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() { 
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on("active-bands", _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() { 
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Band Names", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _pieGraph(),
          Expanded(
          child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: _addNewBand
      ),
   );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.socket.emit("delete-band", {"id": band.id}),
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
        onTap: () => socketService.socket.emit("vote-band", {"id": band.id}),
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
        builder: (_) => CupertinoAlertDialog(
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
        )
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
      )
    );
  }
  
  void addBandToList(String name) {
    if(name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);

      socketService.socket.emit("add-band", {"name": name});
    }
    Navigator.pop(context);
  }

  Widget _pieGraph() {
    Map<String, double> dataMap = new Map();
    //dataMap.putIfAbsent("Flutter", () => 5);

    this.bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[200],
      Colors.red[400],
      Colors.yellow,
      Colors.pink[300],
      Colors.lime,
      Colors.green,
      Colors.indigo
    ];

    return Container(
      padding: EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        showChartValuesInPercentage: true,
        showChartValues: true,
        showChartValuesOutside: false,
        chartValueBackgroundColor: Colors.grey[200],
        colorList: colorList,
        showLegends: true,
        initialAngle: 0,
        chartValueStyle: defaultChartValueStyle.copyWith(
          color: Colors.blueGrey[900].withOpacity(0.9),
        ),
        chartType: ChartType.ring,
      )
    );
  }
}