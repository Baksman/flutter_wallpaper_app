import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double scrollPercent = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 20,
            width: double.infinity,
          ),
          Expanded(
            child: CardFlipper(onScroll: (double scrollPercent) {
              setState(() {
                this.scrollPercent = scrollPercent;
              });
            }),
          ),
          BottomBar(
            scrollPercent: scrollPercent,
            cardCount: 3,
          )
          // Container(
          //   height: 50,
          //   width: double.infinity,
          //   color: Colors.grey,
          // )
        ],
      ),
    );
  }
}

class Card extends StatelessWidget {
  final parallaxPercent;

  const Card({Key key, this.parallaxPercent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FractionalTranslation(
                translation: Offset(parallaxPercent * 2, 0),
                child: OverflowBox(
                    maxWidth: double.infinity,
                    child: Image.asset("assets/image2.jpeg")))),
        Padding(
          padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
          child: Column(
            children: [
              Text("10th street".toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "2-3",
                    style: TextStyle(
                        letterSpacing: -5, color: Colors.white, fontSize: 140),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, right: 3),
                    child: Text(
                      "FT",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wb_sunny, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "65.14",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                ],
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 50),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Mostly cloudly",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Icon(
                          Icons.cloud,
                          color: Colors.white,
                        ),
                        Text(
                          "11.25 mphr ENE",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.black.withOpacity(.3)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class CardFlipper extends StatefulWidget {
  final Function(double onScroll) onScroll;

  const CardFlipper({Key key, this.onScroll}) : super(key: key);
  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper>
    with SingleTickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragScrollPercent;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishAnimationController;

  @override
  void initState() {
    finishAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150))
          ..addListener(() {
            setState(() {
              scrollPercent = lerpDouble(finishScrollStart, finishScrollEnd,
                  finishAnimationController.value);
              if (widget.onScroll != null) {
                widget.onScroll(scrollPercent);
              }
            });
          });

    super.initState();
  }

  @override
  void dispose() {
    finishAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }

  Widget _buildCard(int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - cardIndex / cardCount;
    return FractionalTranslation(
        translation: Offset(cardIndex - cardScrollPercent, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Transform(
            transform: _buildCardProjection(cardScrollPercent - cardIndex),
            child: Card(
              parallaxPercent: parallax,
            ),
          ),
        ));
  }

  List<Widget> _buildCards() {
    return [
      _buildCard(0, 3, scrollPercent),
      _buildCard(1, 3, scrollPercent),
      _buildCard(2, 3, scrollPercent)
    ];
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragScrollPercent = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;
    final numCards = 3;
    setState(() {
      scrollPercent =
          (startDragScrollPercent + (-singleCardDragPercent / numCards))
              .clamp(0, 1 - (1 / numCards));
      if (widget.onScroll != null) {
        widget.onScroll(scrollPercent);
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    finishScrollStart = scrollPercent;
    final numCards = 3;

    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishAnimationController.forward(from: 0);

    setState(() {
      startDrag = null;
      startDragScrollPercent = null;
    });
  }

  _buildCardProjection(double d) {
    return Matrix4.skew(.2, .4);
  }
}

class BottomBar extends StatelessWidget {
  final scrollPercent;
  final cardCount;

  const BottomBar({Key key, this.scrollPercent, this.cardCount})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Expanded(
                child: Center(
              child: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            )),
            Expanded(
                child: Container(
              width: double.infinity,
              height: 5,
              child: ScrollIndicator(
                cardCount: cardCount,
                scrollPercent: scrollPercent,
              ),
            )),
            Expanded(
                child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final scrollPercent;
  final cardCount;

  const ScrollIndicator({Key key, this.scrollPercent, this.cardCount})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScrollIndicatorPainter(
        scrollPercent: scrollPercent,
        cardCount: cardCount,
      ),
      child: Container(),
    );
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final scrollPercent;
  final cardCount;
  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({
    this.scrollPercent,
    this.cardCount,
  })  : trackPaint = Paint()
          ..color = Color(0xff444444)
          ..style = PaintingStyle.fill,
        thumbPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(0, 0, size.width, size.height),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(3),
            topLeft: Radius.circular(3)),
        trackPaint);

    final thumbWidth = size.width / cardCount;
    final thumbLeft = scrollPercent * size.width;

// draw thumb
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(thumbLeft, 0, thumbWidth, size.height),
            topRight: Radius.circular(3),
            bottomLeft: Radius.circular(3),
            bottomRight: Radius.circular(3),
            topLeft: Radius.circular(3)),
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
