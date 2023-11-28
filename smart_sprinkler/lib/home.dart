import 'dart:async'; // Import the async library
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sprinkler/waterConsuption.dart';
import 'menu.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _flujo = "0.0";
  String espUrl = "http://192.168.4.1"; // Change to your ESP's IP address
  Timer? _timer; // Define a Timer variable
  bool isSwitched = false; // Initial value for the switch
  final double _consumoMes = 452.15;
  String dropdownValue = 'Cuadrado';

  @override
  void initState() {
    super.initState();
    _getCounterValue();
    _timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer t) => _getCounterValue());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  _getCounterValue() async {
    try {
      var response = await http.get(Uri.parse('$espUrl/counter'));
      if (response.statusCode == 200) {
        setState(() {
          _flujo = response.body;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _sendCommand(String command) async {
    try {
      var response =
          await http.get(Uri.parse('$espUrl/command?value=$command'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
            duration: Duration(seconds: 1), // Display for 1 second
            behavior: SnackBarBehavior.floating, // Make it floating
            margin: EdgeInsets.all(10), // Add margin around
            backgroundColor: Colors.blue, // Background color
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Menu(),
      appBar: AppBar(
          title: const Text(
            'Smart Sprinkler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
          backgroundColor: const Color.fromARGB(173, 42, 181, 246),
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Selección la forma del jardín: "),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.blueAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Cuadrado', 'Triangulo', 'Luneta']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Encender el aspersor manualmente"),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    _sendCommand(isSwitched
                        ? "1,$value"
                        : "2,$value"); // "1" for on, "2" for off
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Flujo de agua actual: $_flujo Lts/min',
              style: const TextStyle(fontSize: 15.0),
            ),
          ),
          Center(
            child: Text(
              'Agua consumida en el mes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Card(
                      elevation: 4.0,
                      color: const Color.fromARGB(172, 43, 184, 250),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Noviembre"),
                      )),
                ),
              ),
              Text(
                "Consumo del mes: $_consumoMes lts",
                style: const TextStyle(fontSize: 15.0),
              )
            ],
          ),
          AspectRatio(
            // Enforces the 1:1 aspect ratio for the chart
            aspectRatio: 1.0, // 1:1 aspect ratio
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: WaterConsumptionChart(), // Your custom chart widget
            ),
          ),
          const Center(
            child: Text(
                "Developed in collaboration with School of Engineering, Tec de Monterrey.",
                style: TextStyle(
                    fontSize: 10.0, color: Color.fromARGB(255, 170, 169, 169))),
          ),
        ],
      ),
    );
  }
}
