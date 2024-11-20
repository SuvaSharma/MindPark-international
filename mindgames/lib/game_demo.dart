import 'package:flutter/material.dart';

class GameWithHandDemo extends StatefulWidget {
  @override
  _GameWithHandDemoState createState() => _GameWithHandDemoState();
}

class _GameWithHandDemoState extends State<GameWithHandDemo> {
  bool isDropped = false;
  double handX = 50;
  double handY = 400;
  bool showHand = true;

  @override
  void initState() {
    super.initState();
    startHandAnimation();
  }

  void startHandAnimation() async {
    while (!isDropped && mounted) {
      // Move the hand to the draggable item
      await Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          handX = 50;
          handY = 400;
        });
      });

      // Move the hand to the target
      await Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          handX = 200;
          handY = 500;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drag and Drop Demo")),
      body: Stack(
        children: [
          // Drag-and-Drop UI
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Drag the square into the target circle."),
              const SizedBox(height: 20),
              isDropped
                  ? const Icon(Icons.check, color: Colors.green, size: 50)
                  : Draggable(
                      data: "square",
                      feedback: Container(
                        width: 50,
                        height: 50,
                        color: Colors.blue,
                      ),
                      childWhenDragging: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                      ),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.blue,
                      ),
                    ),
              const SizedBox(height: 50),
              DragTarget(
                builder: (context, accepted, rejected) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accepted.isNotEmpty ? Colors.green : Colors.red,
                    ),
                  );
                },
                onAccept: (data) {
                  if (data == "square") {
                    setState(() {
                      isDropped = true;
                      showHand = false; // Stop hand animation
                    });
                  }
                },
              ),
            ],
          ),

          // Animated Hand Glove
          if (showHand)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              left: handX,
              top: handY,
              child: Image.asset(
                'assets/images/pointer.png',
                width: 50,
                height: 50,
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GameWithHandDemo(),
  ));
}
