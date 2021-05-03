import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Share Screenshot'),
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
  List<Offset> _points = <Offset>[];
  File _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
/*//        appBar: AppBar(
//        title: Text(widget.title),
//      ),*/

        body: new Container(

              child: new GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox object = context.findRenderObject();
                  Offset _localPosition =
                  object.globalToLocal(details.globalPosition);
                  _points = new List.from(_points)..add(_localPosition);
                });
              },
              onPanEnd: (DragEndDetails details) => _points.add(null),
              child: new CustomPaint(
                painter: new Signature(points: _points),
                size: Size.infinite,
              ),
          ),
            ),
        

        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                child: Icon(
                    Icons.share
                ),
                    onPressed: () async {
                      _takeScreenshotandShare();
                },
                heroTag: null,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                child: Icon(
                    Icons.delete
                ),
                onPressed: () => _points.clear(),
                heroTag: null,
              )
            ]



/*        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _takeScreenshotandShare();
          },
          tooltip: 'Increment',
          child: Icon(Icons.share),*/
        ),
      ),
    );
  }


  _takeScreenshotandShare() async {
    _imageFile = null;
    screenshotController
        .capture(delay: Duration(milliseconds: 10), pixelRatio: 2.0)
        .then((File image) async {
      setState(() {
        _imageFile = image;
      });
      final directory = (await getApplicationDocumentsDirectory()).path;
      Uint8List pngBytes = _imageFile.readAsBytesSync();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      print("File Saved to Gallery");
      await Share.file('Anupam', 'screenshot.png', pngBytes, 'image/png');
    }).catchError((onError) {
      print(onError);
    });
  }
}
class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;}