import 'dart:ui';

import 'package:mindgames/widgets/puzzle/jigsaw_block_widget.dart';

class BlockClass {
  Offset offset;
  Offset offsetDefault;
  JigsawBlockWidget jigsawBlockWidget;

  BlockClass({
    required this.offset,
    required this.jigsawBlockWidget,
    required this.offsetDefault,
  });
}
