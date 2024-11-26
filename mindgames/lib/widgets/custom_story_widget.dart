import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Duration MomentDurationGetter(int? index);
typedef Widget ProgressSegmentBuilder(
    BuildContext context, int index, double progress, double gap);

class CustomStory extends StatefulWidget {
  const CustomStory({
    super.key,
    required this.momentBuilder,
    required this.momentDurationGetter,
    required this.momentCount,
    this.onFlashForward,
    this.onFlashBack,
    this.progressSegmentBuilder = CustomStory.instagramProgressSegmentBuilder,
    this.progressSegmentGap = 2.0,
    this.progressOpacityDuration = const Duration(milliseconds: 300),
    this.momentSwitcherFraction = 0.33,
    this.startAt = 0,
    this.topOffset,
    this.fullscreen = true,
  })  : assert(momentCount > 0),
        assert(momentSwitcherFraction >= 0),
        assert(momentSwitcherFraction < double.infinity),
        assert(progressSegmentGap >= 0),
        assert(momentSwitcherFraction < double.infinity),
        assert(startAt >= 0),
        assert(startAt < momentCount);

  final IndexedWidgetBuilder momentBuilder;
  final MomentDurationGetter momentDurationGetter;
  final int momentCount;
  final VoidCallback? onFlashForward;
  final VoidCallback? onFlashBack;
  final double momentSwitcherFraction;
  final ProgressSegmentBuilder progressSegmentBuilder;
  final double progressSegmentGap;
  final Duration progressOpacityDuration;
  final int startAt;
  final double? topOffset;
  final bool fullscreen;

  static Widget instagramProgressSegmentBuilder(
      BuildContext context, int index, double progress, double gap) {
    return Container(
      height: 3.0,
      margin: EdgeInsets.symmetric(horizontal: gap / 1),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.7), // Changed color to black
        borderRadius: BorderRadius.circular(1.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          color: Colors.white, // Final progress color is black
        ),
      ),
    );
  }

  @override
  State<CustomStory> createState() => _CustomStoryState();
}

class _CustomStoryState extends State<CustomStory>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIdx;
  bool _isInFullscreenMode = false;

  void _switchToNextOrFinish() {
    _controller.stop();
    if (_currentIdx + 1 >= widget.momentCount &&
        widget.onFlashForward != null) {
      widget.onFlashForward!();
    } else if (_currentIdx + 1 < widget.momentCount) {
      _controller.reset();
      setState(() => _currentIdx += 1);
      _controller.duration = widget.momentDurationGetter(_currentIdx);
      _controller.forward();
    }
  }

  void _switchToPrevOrFinish() {
    _controller.stop();
    if (_currentIdx - 1 < 0 && widget.onFlashBack != null) {
      widget.onFlashBack!();
    } else {
      _controller.reset();
      if (_currentIdx - 1 >= 0) {
        setState(() => _currentIdx -= 1);
      }
      _controller.duration = widget.momentDurationGetter(_currentIdx);
      _controller.forward();
    }
  }

  void _onTapDown(TapDownDetails details) => _controller.stop();

  void _onTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width * widget.momentSwitcherFraction) {
      _switchToPrevOrFinish();
    } else {
      _switchToNextOrFinish();
    }
  }

  void _onLongPress() {
    _controller.stop();
    setState(() => _isInFullscreenMode = true);
  }

  void _onLongPressEnd() {
    setState(() => _isInFullscreenMode = false);
    _controller.forward();
  }

  Future<void> _hideStatusBar() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  Future<void> _showStatusBar() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);

  @override
  void initState() {
    if (widget.fullscreen) {
      _hideStatusBar();
    }
    _currentIdx = widget.startAt;
    _controller = AnimationController(
      vsync: this,
      duration: widget.momentDurationGetter(_currentIdx),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _switchToNextOrFinish();
        }
      });
    _controller.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(CustomStory oldWidget) {
    if (widget.fullscreen != oldWidget.fullscreen) {
      if (widget.fullscreen) {
        _hideStatusBar();
      } else {
        _showStatusBar();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.fullscreen) {
      _showStatusBar();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.momentBuilder(
          context,
          _currentIdx < widget.momentCount
              ? _currentIdx
              : widget.momentCount - 1,
        ),
        Positioned(
          top: widget.topOffset ?? MediaQuery.of(context).padding.top,
          left: 8.0 - widget.progressSegmentGap / 2,
          right: 8.0 - widget.progressSegmentGap / 2,
          child: AnimatedOpacity(
            opacity: _isInFullscreenMode ? 0.0 : 1.0,
            duration: widget.progressOpacityDuration,
            child: Row(
              children: List.generate(
                widget.momentCount,
                (idx) {
                  return Expanded(
                    child: idx == _currentIdx
                        ? AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return widget.progressSegmentBuilder(
                                context,
                                idx,
                                _controller.value,
                                widget.progressSegmentGap,
                              );
                            },
                          )
                        : widget.progressSegmentBuilder(
                            context,
                            idx,
                            idx < _currentIdx ? 1.0 : 0.0,
                            widget.progressSegmentGap,
                          ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onLongPress: _onLongPress,
            onLongPressUp: _onLongPressEnd,
          ),
        ),
      ],
    );
  }
}
