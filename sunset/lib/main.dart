import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunset',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sunset Notifier'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double lat;
  double lon;
  DateTime data;
  String address;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      lat = position.latitude;
      lon = position.longitude;
    });

    final coordinates = new Coordinates(lat, lon);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var first = addresses.first;
    setState(() {
      address = "${first.addressLine}";
    });
    getSunsetData();
  }

  getSunsetData() async {
    Uri uri = Uri(
      scheme: 'https',
      host: 'api.sunrise-sunset.org',
      path: '/json',
      queryParameters: {
        'lat': lat.toString(),
        'lng': lon.toString(),
        'formatted': '0'
      },
    );

    http.Response response;
    try {
      response = await http.get(uri);
    } on Exception catch (e) {
      print('Network Error: $e');
      throw e;
    }

    final jsonResponse = json.decode(response.body);

    setState(() {
      data = DateTime.parse(jsonResponse["results"]["sunset"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            data == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      Text(
                        "Detected location :",
                        style: myTextStyleBase.size_C,
                      ),
                      SizedBox(height: 20),
                      address == ""
                          ? Text("Unknown")
                          : Text(
                              address,
                              style: myTextStyleBase.size_C,
                            ),
                      SizedBox(height: 20),
                      Text(
                        DateFormat('EEE, MMM d').format(data.toLocal()),
                        style: myTextStyleBase.size_B,
                      ),
                      SizedBox(height: 20),
                      Text(DateFormat('h:mm a').format(data.toLocal()),
                          style: myTextStyleBase.size_A),
                      SizedBox(height: 20),
                      Text(data.toLocal().timeZoneName,
                          style: myTextStyleBase.size_B),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class myTextStyleBase {
  static const size_A = TextStyle(fontSize: 50);
  static const size_B = TextStyle(fontSize: 30);
  static const size_C = TextStyle(fontSize: 15);
}
