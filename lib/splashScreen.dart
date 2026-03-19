import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late Image image1;

  @override
  void initState() {
    super.initState();
    image1 = Image.asset(
      "assets/images/logo.png",
      height: 200,
      width: 200,
      fit: BoxFit.contain,

      // cacheHeight: 100,
      // cacheWidth: 100,
    );
  }

  @override
  void didChangeDependencies() {
    precacheImage(image1.image, context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          // alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: AlignmentGeometry.topCenter,
            //       end: AlignmentGeometry.bottomCenter,
            //       colors: [xColors.color1, Colors.white],
            //       stops: [0.2, 0.9],
            //     ),
            //   ),
            // ),
            // CustomPaint(
            //   size: Size.infinite,
            //   painter: SplashPainter(
            //       curveColor: xColors.color1.withOpacity(0.9),
            //   ),
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text(
                  'ยินดีตอนรับ',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge!.copyWith(color: Color(0xFF73ADDD), fontWeight: FontWeight.bold),
                ),
                Material(
                  color: CupertinoColors.white,
                  elevation: 10,
                  shadowColor: CupertinoColors.systemGrey6,
                  shape: CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    // decoration: ShapeDecoration(color: Colors.white, shape: CircleBorder()),
                    child: image1,
                  ),
                ),

                // Text(
                //   'WashLover Driver',
                //   style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: xColors.color1, fontWeight: FontWeight.normal,),
                // ),
                SizedBox(height: sizeH * .01),
                // if (!getUserData.isLoading)
                //   SizedBox(height: sizeH * .05, width: sizeH * .05),
                // if (getUserData.isLoading)
                SizedBox(
                  height: sizeH * .05,
                  width: sizeH * .05,
                  child:
                      CircularProgressIndicator(strokeCap: StrokeCap.round, color: Color(0xFF73ADDD), strokeWidth: 8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SplashPainter extends CustomPainter {
  final Color curveColor;

  SplashPainter({required this.curveColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Setup the paint properties
    final paint = Paint()
      ..color = curveColor // The color for the wave shape
      ..style = PaintingStyle.fill;

    // 2. Define the Path (The Wave/Curve)
    final path = Path();

    // Start drawing from the bottom-left corner of the screen
    path.moveTo(0, size.height);

    // Move up to a starting point for the curve (e.g., 75% of the screen height)
    path.lineTo(0, size.height * 0.75);

    // --- First Wave Section (Quadratic Bezier Curve) ---
    // Control Point 1: controls the curve's shape (outward or inward bend)
    final controlPoint1 = Offset(size.width * 0.25, size.height * 0.70);
    // End Point 1: where the first curve segment finishes
    final endPoint1 = Offset(size.width * 0.5, size.height * 0.80);
    path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    // --- Second Wave Section ---
    // Control Point 2: controls the second curve's shape
    final controlPoint2 = Offset(size.width * 0.75, size.height * 0.90);
    // End Point 2: finishes the entire curve
    final endPoint2 = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);

    // 3. Complete the Path (Close the shape to the bottom-right corner)
    path.lineTo(size.width, size.height);
    path.close();

    // 4. Draw the shape onto the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the color changes (for simplicity, we return false here)
    return false;
  }
}

@override
bool shouldRepaint(CustomPainter oldDelegate) {
  // Only repaint if the color changes (for simplicity, we return false here)
  return false;
}
