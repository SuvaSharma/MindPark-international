import 'dart:developer';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as ui;
import 'package:mindgames/widgets/puzzle/block_class.dart';
import 'package:mindgames/widgets/puzzle/class_jigsaw_pos.dart';
import 'package:mindgames/widgets/puzzle/image_box.dart';
import 'package:mindgames/widgets/puzzle/jigsaw_block_widget.dart';
import 'package:mindgames/widgets/puzzle/jigsaw_painter_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class JigsawWidget extends StatefulWidget {
  final Widget child;
  final int xSplitCount;
  final int ySplitCount;
  final Function() callbackSuccess;
  final Function() callbackFinish;
  const JigsawWidget({
    super.key,
    required this.child,
    required this.xSplitCount,
    required this.ySplitCount,
    required this.callbackFinish,
    required this.callbackSuccess,
  });

  @override
  JigsawWidgetState createState() => JigsawWidgetState();
}

class JigsawWidgetState extends State<JigsawWidget> with ChangeNotifier {
  final GlobalKey _globalKey = GlobalKey();
  late ui.Image fullImage;
  late Size size = const Size(0, 0);
  bool _vibrationEnabled = false;

  List<List<BlockClass>> images = [];
  ValueNotifier<List<BlockClass>> blocksNotifier =
      ValueNotifier<List<BlockClass>>([]);

  _getImageFromWidget() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();

    return ui.decodeImage(pngBytes!);
  }

  resetJigsaw() {
    images.clear();
    blocksNotifier = ValueNotifier<List<BlockClass>>([]);
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  Future<void> generateJigsawCropImage() async {
    images = [];

    fullImage = await _getImageFromWidget();

    double widthPerBlock = (fullImage.width / widget.xSplitCount);
    double heightPerBlock = (fullImage.height / widget.ySplitCount);

    for (var y = 0; y < widget.ySplitCount; y++) {
      List<BlockClass> tempImages = [];
      images.add(tempImages);
      for (var x = 0; x < widget.xSplitCount; x++) {
        int randomPosRow = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;
        int randomPosCol = math.Random().nextInt(2) % 2 == 0 ? 1 : -1;

        Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

        ClassJigsawPos jigsawPosSide = ClassJigsawPos(
          bottom: y == widget.ySplitCount - 1 ? 0 : randomPosCol,
          left: x == 0
              ? 0
              : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
          right: x == widget.xSplitCount - 1 ? 0 : randomPosRow,
          top: y == 0
              ? 0
              : -images[y - 1][x].jigsawBlockWidget.imageBox.posSide.bottom,
        );

        double xAxis = widthPerBlock * x;
        double yAxis = heightPerBlock * y;

        log('width per block: $widthPerBlock\nheight per block: $heightPerBlock');

        double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

        offsetCenter = Offset(
          (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
          (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
        );

        xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
        yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

        double widthPerBlockTemp = widthPerBlock +
            (jigsawPosSide.left == 1 ? minSize : 0) +
            (jigsawPosSide.right == 1 ? minSize : 0);
        double heightPerBlockTemp = heightPerBlock +
            (jigsawPosSide.top == 1 ? minSize : 0) +
            (jigsawPosSide.bottom == 1 ? minSize : 0);

        ui.Image temp = ui.copyCrop(
          fullImage,
          x: xAxis.round(),
          y: yAxis.round(),
          width: widthPerBlockTemp.round(),
          height: heightPerBlockTemp.round(),
        );

        Offset offset = Offset(size.width / 2 - widthPerBlockTemp / 2,
            size.height / 2 - heightPerBlockTemp / 2);

        ImageBox imageBox = ImageBox(
          image: Image.memory(
            ui.encodePng(temp),
            fit: BoxFit.contain,
          ),
          isDone: false,
          offsetCenter: offsetCenter,
          posSide: jigsawPosSide,
          radiusPoint: minSize,
          size: Size(widthPerBlockTemp, heightPerBlockTemp),
        );

        images[y].add(
          BlockClass(
              jigsawBlockWidget: JigsawBlockWidget(
                imageBox: imageBox,
              ),
              offset: offset,
              offsetDefault: Offset(xAxis, yAxis)),
        );
      }
    }

    blocksNotifier.value = images.expand((image) => image).toList();
    blocksNotifier.value.shuffle();
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  @override
  void initState() {
    _loadVibrationSetting();
    super.initState();
  }

  Future<void> _loadVibrationSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size sizeBox = MediaQuery.of(context).size;

    return ValueListenableBuilder(
      valueListenable: blocksNotifier,
      builder: (context, List<BlockClass> blocks, child) {
        List<BlockClass> blockNotDone = blocks
            .where((block) => !block.jigsawBlockWidget.imageBox.isDone)
            .toList();
        List<BlockClass> blockDone = blocks
            .where((block) => block.jigsawBlockWidget.imageBox.isDone)
            .toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: sizeBox.width * 0.7,
              width: sizeBox.width * 0.7,
              child: Stack(
                children: [
                  if (blocks.isEmpty) ...[
                    RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.02),
                        ),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: widget.child,
                      ),
                    )
                  ],
                  Offstage(
                    offstage: !(blocks.isNotEmpty),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                        color: Colors.white,
                      ),
                      width: size.width,
                      height: size.height,
                      child: CustomPaint(
                        painter: JigsawPainterBackground(blocks),
                        child: Stack(
                          children: [
                            // Display placed (done) blocks
                            if (blockDone.isNotEmpty)
                              ...blockDone.map(
                                (map) {
                                  return Positioned(
                                    left: map.offset.dx,
                                    top: map.offset.dy,
                                    child: map.jigsawBlockWidget,
                                  );
                                },
                              ),
                            // Drag Targets for each block position
                            ...images.expand((row) => row).map((block) {
                              return Positioned(
                                left: block.offsetDefault.dx,
                                top: block.offsetDefault.dy,
                                child: DragTarget<BlockClass>(
                                  onAcceptWithDetails: (receivedBlock) {
                                    setState(() {
                                      // Ensure the block is dropped in the correct position
                                      if (receivedBlock.data.offsetDefault ==
                                          block.offsetDefault) {
                                        if (_vibrationEnabled) {
                                          Vibration.vibrate(
                                            duration: 100,
                                            amplitude: 50,
                                          );
                                        }

                                        receivedBlock.data.offset =
                                            receivedBlock.data.offsetDefault;
                                        receivedBlock.data.jigsawBlockWidget
                                            .imageBox.isDone = true;
                                        blocksNotifier.notifyListeners();

                                        widget.callbackSuccess.call();

                                        // Check if all blocks are in their correct positions
                                        if (blocks.every((block) => block
                                            .jigsawBlockWidget
                                            .imageBox
                                            .isDone)) {
                                          resetJigsaw();
                                          widget.callbackFinish.call();
                                        }
                                      } else {
                                        // If not placed correctly, move it back to the original position
                                        receivedBlock.data.offset = Offset(
                                            size.width / 5 -
                                                receivedBlock
                                                        .data
                                                        .jigsawBlockWidget
                                                        .imageBox
                                                        .size
                                                        .width /
                                                    5,
                                            size.height / 5 -
                                                receivedBlock
                                                        .data
                                                        .jigsawBlockWidget
                                                        .imageBox
                                                        .size
                                                        .height /
                                                    5);
                                      }
                                    });
                                  },
                                  onWillAcceptWithDetails: (data) {
                                    // Optionally, add logic to highlight target
                                    return true;
                                  },
                                  builder:
                                      (context, candidateData, rejectedData) {
                                    return SizedBox(
                                      width: block.jigsawBlockWidget.imageBox
                                          .size.width,
                                      height: block.jigsawBlockWidget.imageBox
                                          .size.height,
                                      // Optionally, add visual feedback
                                      // color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Container(
              color: Colors.black.withOpacity(0.1),
              height: size.height * 0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: blockNotDone.map((block) {
                    Size sizeBlock = block.jigsawBlockWidget.imageBox.size;

                    return Draggable<BlockClass>(
                      data: block,
                      feedback: Opacity(
                        opacity: 0.7,
                        child: Transform.translate(
                          offset: Offset(
                            -block.jigsawBlockWidget.imageBox.size.width / 2,
                            -block.jigsawBlockWidget.imageBox.size.height / 2,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: size.width * 0.1,
                              bottom: size.width * 0.1,
                            ),
                            child: FittedBox(
                              child: SizedBox(
                                width:
                                    block.jigsawBlockWidget.imageBox.size.width,
                                height: block
                                    .jigsawBlockWidget.imageBox.size.height,
                                child: block.jigsawBlockWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.width * 0.08,
                            bottom: size.width * 0.08,
                          ),
                          child: Opacity(
                            opacity: 0.0,
                            child: FittedBox(
                              child: SizedBox(
                                width:
                                    block.jigsawBlockWidget.imageBox.size.width,
                                height: block
                                    .jigsawBlockWidget.imageBox.size.height,
                                child: block.jigsawBlockWidget,
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: size.width * 0.08,
                          bottom: size.width * 0.08,
                          right: size.width * 0.08,
                        ),
                        child: FittedBox(
                          child: SizedBox(
                            width: sizeBlock.width,
                            height: sizeBlock.height,
                            child: block.jigsawBlockWidget,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
