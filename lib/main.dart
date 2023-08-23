import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geolocator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latitude = 'Fetching...';
  String _longitude = 'Fetching...';
  String _street = '';
  String _subLocality = '';
  String _locality = '';
  String _country = '';

  @override
  void initState() {
    super.initState();
    _getAndSetPosition();
  }

  Future<void> _getAndSetPosition() async {
    try {
      final Position position = await _determinePosition();
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _buildAddressString(placemarks.first);
      });
    } catch (error) {
      setState(() {
        _latitude = 'Error';
        _longitude = 'Error';
        _resetAddress();
      });
    }
  }

  void _buildAddressString(Placemark placemark) {
    setState(() {
      _street = placemark.street ?? '';
      _subLocality = placemark.subLocality ?? '';
      _locality = placemark.locality ?? '';
      _country = placemark.country ?? '';
    });
  }

  void _resetAddress() {
    setState(() {
      _street = '';
      _subLocality = '';
      _locality = '';
      _country = '';
    });
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  void _openMap(String latitude, String longitude) async {
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(mapUrl)) {
      await launch(mapUrl);
    } else {
      print('Error launching map');
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocator App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressTextBox("Street: $_street"),
            SizedBox(height: 10),
            _buildAddressTextBox("SubLocality: $_subLocality"),
            SizedBox(height: 10),
            _buildAddressTextBox("Locality: $_locality"),
            SizedBox(height: 10),
            _buildAddressTextBox("Country: $_country"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _openMap(_latitude, _longitude);
              },
              child: Text('View on Map'),
            ),
          ],
        ),
      ),

      /*body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latitude: $_latitude',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Longitude: $_longitude',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Street: $_street',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Sublocality: $_subLocality',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Locality: $_locality',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Country: $_country',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _openMap(_latitude, _longitude);
              },
              child: Text('View on Map'),
            ),
          ],
        ),
      ),
       */

    );
  }

  Widget _buildAddressTextBox(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

}
