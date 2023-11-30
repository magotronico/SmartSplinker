import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sprinkler/waterConsuption.dart';
import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _flujo = "0.0";
  String espUrl = "http://192.168.4.1"; // Change to your ESP's IP address
  Timer? _timer; // Define a Timer variable
  bool isSwitched = false; // Initial value for the switch
  bool isAlarm = false;
  Timer? _alarmTimer;
  TimeOfDay _selectedTime =
      TimeOfDay.now(); // State variable to store the selected time
  final double _consumoMes = 963.86;
  String dropdownValue = 'Cuadrado';

  @override
  void initState() {
    super.initState();
    _loadSelectedTime();
    _getCounterValue();
    _timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer t) => _getCounterValue());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _alarmTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedTime() async {
    final prefs = await SharedPreferences.getInstance();
    int hour = prefs.getInt('selectedHour') ?? TimeOfDay.now().hour;
    int minute = prefs.getInt('selectedMinute') ?? TimeOfDay.now().minute;
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSelectedTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedHour', time.hour);
    await prefs.setInt('selectedMinute', time.minute);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      _saveSelectedTime(pickedTime);
    }
  }

  void _checkAlarm() {
    if (isAlarm &&
        _selectedTime.hour == TimeOfDay.now().hour &&
        _selectedTime.minute == TimeOfDay.now().minute) {
      _sendCommand("1,$dropdownValue"); // Send the "on" command
      // Optional: if you want the alarm to trigger only once, cancel it after firing
      // _alarmTimer?.cancel();
      // setState(() => isAlarm = false);
    }
  }

  void _toggleAlarm(bool value) {
    if (value) {
      // Turn on the alarm
      _alarmTimer =
          Timer.periodic(Duration(minutes: 1), (Timer t) => _checkAlarm());
    } else {
      // Turn off the alarm
      _alarmTimer?.cancel();
      _sendCommand("2,$dropdownValue"); // Send the "off" command
    }
    setState(() => isAlarm = value);
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
            backgroundColor:
                const Color.fromARGB(172, 37, 180, 246), // Background color
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
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text(
              'Smart Sprinkler',
              style: TextStyle(
                  color: Color.fromARGB(173, 42, 181, 246),
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0),
            ),
          ),
          backgroundColor: Color.fromARGB(207, 255, 255, 255),
          elevation: 0,
          iconTheme:
              const IconThemeData(color: Color.fromARGB(173, 42, 181, 246))),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 4.0,
                color: const Color.fromARGB(255, 215, 243, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
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
                            color: const Color.fromARGB(255, 68, 183, 255),
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
                                  ? "1,$dropdownValue"
                                  : "2,$dropdownValue"); // "1" for on, "2" for off
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Card(
                elevation: 4.0,
                color: Color.fromARGB(255, 215, 243, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _selectTime(context),
                                child: Row(
                                  children: [
                                    Text(
                                      '${_selectedTime.format(context)}',
                                      style: const TextStyle(
                                          fontSize: 25.0,
                                          color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: [
                              const Text(
                                "Todos los días",
                                style: TextStyle(fontSize: 10.0),
                              ),
                              Switch(
                                value: isAlarm,
                                onChanged: _toggleAlarm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 4.0,
                color: const Color.fromARGB(255, 215, 243, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Agua consumida en el mes',
                          style: TextStyle(
                              color: Color.fromARGB(172, 37, 180, 246),
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
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
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Noviembre"),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Consumo del mes: ${_consumoMes.toStringAsFixed(2)} lts",
                            style: const TextStyle(fontSize: 15.0),
                          ),
                        )
                      ],
                    ),
                    AspectRatio(
                      // Enforces the chart's aspect ratio
                      aspectRatio: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            WaterConsumptionChart(), // Your custom chart widget
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
