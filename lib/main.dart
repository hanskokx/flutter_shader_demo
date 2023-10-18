// import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:window_manager/window_manager.dart';

late FragmentProgram fragmentProgram;

void main() async {
  fragmentProgram = await FragmentProgram.fromAsset(
    // 'assets/shaders/my_shader.frag',
    'assets/shaders/starfield.frag',
  );

  WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isWindows) {
  //   await windowManager.ensureInitialized();

  //   WindowOptions windowOptions = const WindowOptions(
  //     size: Size(800, 600),
  //     center: true,
  //     backgroundColor: Colors.transparent,
  //     skipTaskbar: false,
  //     titleBarStyle: TitleBarStyle.hidden,
  //   );
  //   windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.setAsFrameless();
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  late AnimationController _controller;

  int _startTime = 0;
  double get _elapsedTimeInSeconds =>
      (_startTime - DateTime.now().millisecondsSinceEpoch) / 1000;

  @override
  Widget build(BuildContext context) {
    final FragmentShader shader = fragmentProgram.fragmentShader();
    return ClipPath(
      // clipper: TrapeziumClipper(),
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: MyPainter(
                // color: const Color.fromRGBO(64, 224, 208, 0.4),
                shader: shader,
                time: _elapsedTimeInSeconds,
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _controller =
        AnimationController(duration: const Duration(days: 999), vsync: this)
          ..addListener(() => setState(() {}));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MyPainter extends CustomPainter {
  final Color? color;
  final FragmentShader shader;
  final double time;
  const MyPainter({
    this.color,
    required this.shader,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelColor = color ?? const Color.fromRGBO(0, 0, 0, 1);
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    shader.setFloat(2, pixelColor.red.toDouble() / 255);
    shader.setFloat(3, pixelColor.green.toDouble() / 255);
    shader.setFloat(4, pixelColor.blue.toDouble() / 255);
    shader.setFloat(5, pixelColor.alpha.toDouble() / 255);

    shader.setFloat(6, time);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) =>
      color != oldDelegate.color || time != oldDelegate.time;
}

class TrapeziumClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 2 / 3, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TrapeziumClipper oldClipper) => false;
}
