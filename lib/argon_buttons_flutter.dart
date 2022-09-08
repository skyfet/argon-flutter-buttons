library argon_buttons_flutter;

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

enum ButtonState { Busy, Idle }

class ArgonButton extends StatefulWidget {
  final double height;
  final double width;
  final double minWidth;
  final Widget? loader;
  final Duration animationDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Widget child;
  final Function(
      Function startLoading, Function stopLoading, ButtonState btnState)? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final MaterialTapTargetSize? tapTargetSize;
  final bool roundLoadingShape;
  final double borderRadius;
  final BorderSide borderSide;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  ArgonButton(
      {required this.height,
      required this.width,
      this.minWidth: 0,
      this.loader,
      this.animationDuration: const Duration(milliseconds: 450),
      this.curve: Curves.easeInOutCirc,
      this.reverseCurve: Curves.easeInOutCirc,
      required this.child,
      this.onTap,
      this.backgroundColor,
      this.foregroundColor,
      this.elevation,
      this.padding: const EdgeInsets.all(0),
      this.borderRadius: 0.0,
      this.clipBehavior: Clip.none,
      this.focusNode,
      this.tapTargetSize,
      this.roundLoadingShape: true,
      this.borderSide: const BorderSide(color: Colors.transparent, width: 0),
      this.disabledBackgroundColor,
      this.disabledForegroundColor})
      : assert(elevation == null || elevation >= 0.0);

  @override
  _ArgonButtonState createState() => _ArgonButtonState();
}

class _ArgonButtonState extends State<ArgonButton>
    with TickerProviderStateMixin {
  double? loaderWidth;

  late Animation<double> _animation;
  late AnimationController _controller;
  ButtonState btn = ButtonState.Idle;

  GlobalKey _buttonKey = GlobalKey();
  double _minWidth = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);

    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          btn = ButtonState.Idle;
        });
      }
    });

    minWidth = widget.height;
    loaderWidth = widget.height;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animateForward() {
    setState(() {
      btn = ButtonState.Busy;
    });
    _controller.forward();
  }

  void animateReverse() {
    _controller.reverse();
  }

  lerpWidth(a, b, t) {
    if (a == 0.0 || b == 0.0) {
      return null;
    } else {
      return a + (b - a) * t;
    }
  }

  double get minWidth => _minWidth;
  set minWidth(double w) {
    if (widget.minWidth == 0) {
      _minWidth = w;
    } else {
      _minWidth = widget.minWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return buttonBody();
      },
    );
  }

  Widget buttonBody() {
    return Container(
      height: widget.height,
      width: lerpWidth(widget.width, minWidth, _animation.value),
      child: ButtonTheme(
        height: widget.height,
        shape: RoundedRectangleBorder(
          side: widget.borderSide,
          borderRadius: BorderRadius.circular(widget.roundLoadingShape
              ? lerpDouble(
                  widget.borderRadius, widget.height / 2, _animation.value)!
              : widget.borderRadius),
        ),
        child: ElevatedButton(
            key: _buttonKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor, // background
              foregroundColor: widget.foregroundColor, // foreground
              elevation: widget.elevation,
              padding: widget.padding,
              tapTargetSize: widget.tapTargetSize,
              disabledBackgroundColor: widget.disabledBackgroundColor,
              disabledForegroundColor: widget.disabledForegroundColor,
            ),
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            onPressed: () {
              widget.onTap!(
                  () => animateForward(), () => animateReverse(), btn);
              // btnClicked();
            },
            child: btn == ButtonState.Idle ? widget.child : widget.loader),
      ),
    );
  }
}

class ArgonTimerButton extends StatefulWidget {
  final double height;
  final double width;
  final double minWidth;
  final Function(int time)? loader;
  final Duration animationDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Widget child;
  final Function(Function startTimers, ButtonState? btnState)? onTap;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final MaterialTapTargetSize? tapTargetSize;
  final bool roundLoadingShape;
  final double borderRadius;
  final BorderSide borderSide;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  final int initialTimer;

  ArgonTimerButton(
      {required this.height,
      required this.width,
      this.minWidth: 0,
      this.loader,
      this.animationDuration: const Duration(milliseconds: 450),
      this.curve: Curves.easeInOutCirc,
      this.reverseCurve: Curves.easeInOutCirc,
      required this.child,
      this.onTap,
      this.elevation,
      this.backgroundColor,
      this.foregroundColor,
      this.padding: const EdgeInsets.all(0),
      this.borderRadius: 0.0,
      this.clipBehavior: Clip.none,
      this.focusNode,
      this.tapTargetSize,
      this.roundLoadingShape: true,
      this.borderSide: const BorderSide(color: Colors.transparent, width: 0),
      this.disabledBackgroundColor,
      this.disabledForegroundColor,
      this.initialTimer: 0});

  @override
  _ArgonTimerButtonState createState() => _ArgonTimerButtonState();
}

class _ArgonTimerButtonState extends State<ArgonTimerButton>
    with TickerProviderStateMixin {
  double? loaderWidth;

  late Animation<double> _animation;
  late AnimationController _controller;
  ButtonState? btn;
  int secondsLeft = 0;
  Timer? _timer;
  Stream emptyStream = Stream.empty();
  double _minWidth = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);

    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          btn = ButtonState.Idle;
        });
      }
    });

    if (widget.initialTimer == 0) {
      btn = ButtonState.Idle;
    } else {
      startTimer(widget.initialTimer);
      btn = ButtonState.Busy;
    }

    minWidth = widget.height;
    loaderWidth = widget.height;
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    _controller.dispose();
    super.dispose();
  }

  void animateForward() {
    setState(() {
      btn = ButtonState.Busy;
    });
    _controller.forward();
  }

  void animateReverse() {
    _controller.reverse();
  }

  lerpWidth(a, b, t) {
    if (a == 0.0 || b == 0.0) {
      return null;
    } else {
      return a + (b - a) * t;
    }
  }

  double get minWidth => _minWidth;
  set minWidth(double w) {
    if (widget.minWidth == 0) {
      _minWidth = w;
    } else {
      _minWidth = widget.minWidth;
    }
  }

  void startTimer(int newTime) {
    if (newTime == 0) {
      throw ("Count Down Time can not be null");
    }

    animateForward();

    setState(() {
      secondsLeft = newTime;
    });

    if (_timer != null) {
      _timer!.cancel();
    }

    var oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (secondsLeft < 1) {
            timer.cancel();
          } else {
            secondsLeft = secondsLeft - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return buttonBody();
      },
    );
  }

  Widget buttonBody() {
    return Container(
      height: widget.height,
      width: lerpWidth(widget.width, minWidth, _animation.value),
      child: ButtonTheme(
        height: widget.height,
        shape: RoundedRectangleBorder(
          side: widget.borderSide,
          borderRadius: BorderRadius.circular(widget.roundLoadingShape
              ? lerpDouble(
                  widget.borderRadius, widget.height / 2, _animation.value)!
              : widget.borderRadius),
        ),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor, // background
              foregroundColor: widget.foregroundColor, // foreground
              elevation: widget.elevation,
              padding: widget.padding,
              tapTargetSize: widget.tapTargetSize,
              disabledBackgroundColor: widget.disabledBackgroundColor,
              disabledForegroundColor: widget.disabledForegroundColor,
            ),
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            onPressed: () {
              widget.onTap!((newCounter) => startTimer(newCounter), btn);
            },
            child: btn == ButtonState.Idle
                ? widget.child
                : StreamBuilder(
                    stream: emptyStream,
                    builder: (context, snapshot) {
                      if (secondsLeft == 0) {
                        animateReverse();
                      }
                      return widget.loader!(secondsLeft);
                    })),
      ),
    );
  }
}
