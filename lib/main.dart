import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/services.dart';
import './consts.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
      ),*/
      home: HomePage(title: 'Security System'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List<double> acceleros = [];
  AssetsAudioPlayer aap = AssetsAudioPlayer();
  bool activated = false;
  double x;
  double y;
  double z;
  bool initDone = false;
  bool alarmOn = false;

  _HomePageState();

  @override
  Widget build(BuildContext context) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (activated && !initDone) {
        x = event.x;
        y = event.y;
        z = event.z;
        initDone = true;
      } else if (activated && !alarmOn) {
        if (event.x > x + delta ||
            event.x < x - delta ||
            event.y > y + delta ||
            event.y < y - delta ||
            event.z > z + delta ||
            event.z < z - delta) {
          _soundAlarm();
        }
      }
      /*setState(() {
        acceleros = <double>[event.x, event.y, event.z];
      });
      //print('Accelero: x=${event.x}, y=${event.y}, z=${event.z}');*/
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style:
              TextStyle(fontSize: appFontSizeHuge, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*acceleros.isEmpty
                ? Container()
                : Text(
                    'Acceleros:\n x: ${acceleros[0].toStringAsFixed(appDigits)}\n y: ${acceleros[1].toStringAsFixed(appDigits)}\n z: ${acceleros[2].toStringAsFixed(appDigits)}\n',
                    style: Theme.of(context).textTheme.display1,
                  ),*/
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(appButBorderRad)),
              color: Color(appActButCol),
              padding: EdgeInsets.symmetric(
                  vertical: appMargin, horizontal: appButMargin),
              child: Text(
                'Activate Alarm',
                style: TextStyle(
                    fontSize: appFontSizeHuge, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _showDialog();
              },
            ),
            Container(
              height: appMargin,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(appButBorderRad)),
              color: Color(appDeActButCol),
              padding: EdgeInsets.symmetric(
                  vertical: appMargin, horizontal: appButMargin - 14),
              child: Text(
                'Deactivate Alarm',
                style: TextStyle(
                    fontSize: appFontSizeHuge, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _resetAlarm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _soundAlarm() {
    alarmOn = true;
    aap.open(AssetsAudio(
      asset: appAlarmFileName,
      folder: "assets/",
    ));
  }

  void _resetAlarm() {
    aap.stop();
    activated = false;
    initDone = false;
    alarmOn = false;
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Activate Alarm'),
          content: Text(
              'Alarm will be activated in $delaySecs. Turn off the screen and place device on a stable surface.'),
          actions: <Widget>[
            RaisedButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              child: Text(
                "Activate Alarm",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _resetAlarm();
                Future.delayed(const Duration(seconds: delaySecs), () {
                  activated = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    aap.dispose();
  }
}
