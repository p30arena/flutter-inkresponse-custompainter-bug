import 'dart:ui' as UI;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

const String imageLink =
    "https://cdn.omlet.co.uk/images/originals/worlds_most_popular_pet_bird.jpg";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: MyWidget(),
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  int n = 1;

  Future _f;
  UI.Image netImage;

  loadImage() async {
    try {
      final data =
          (await (await (await HttpClient().getUrl(Uri.parse(imageLink)))
                      .close())
                  .toList())
              .expand((item) => item)
              .toList();

      netImage =
          (await (await UI.instantiateImageCodec(Uint8List.fromList(data)))
                  .getNextFrame())
              .image;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  initState() {
    super.initState();

    _f = loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder(
          future: _f,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("error");
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }

            double ratio = netImage.width / netImage.height;
            double nW = 300;
            double nH = nW / ratio;

            return CustomPaint(
              size: Size(nW, nH),
              painter: MyPaint(
                nCircles: n,
                netImage: netImage,
              ),
            );
          },
        ),
        RaisedButton(
          onPressed: () => setState(() {
            n++;
            print(n);
          }),
          child: Text("+"),
        ),
      ],
    );
  }
}

class MyPaint extends CustomPainter {
  final int nCircles;
  final UI.Image netImage;

  MyPaint({
    this.nCircles: 1,
    @required this.netImage,
  }) : assert(netImage != null);

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
    //     Paint()..color = Colors.amber);
    canvas.drawImageRect(
        netImage,
        Rect.fromLTWH(
            0, 0, netImage.width.toDouble(), netImage.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint());
    for (int i = 0; i < nCircles; i++) {
      final double x = Random().nextInt(size.width.truncate()).toDouble();
      final double y = Random().nextInt(size.height.truncate()).toDouble();

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.black87);
    }
  }

  @override
  bool shouldRepaint(MyPaint old) => old.nCircles != nCircles ? true : false;
}
