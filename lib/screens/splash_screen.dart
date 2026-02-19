// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../core/theme/app_theme.dart';
// import '../../services/storage_service.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//   late Animation<double> _scaleAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animController, curve: Curves.easeIn),
//     );
//     _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
//       CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
//     );

//     _animController.forward();
//     _navigate();
//   }

//   Future<void> _navigate() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (StorageService.isLoggedIn()) {
//       Get.offAllNamed('/home');
//     } else {
//       Get.offAllNamed('/login');
//     }
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: AppTheme.gradientDecoration,
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _animController,
//             builder: (_, __) => FadeTransition(
//               opacity: _fadeAnim,
//               child: ScaleTransition(
//                 scale: _scaleAnim,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 110,
//                       height: 110,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(28),
//                       ),
//                       child: const Icon(
//                         Icons.fingerprint,
//                         size: 64,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Attendance App',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Track. Verify. Manage.',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white.withOpacity(0.8),
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     const SizedBox(height: 60),
//                     SizedBox(
//                       width: 36,
//                       height: 36,
//                       child: CircularProgressIndicator(
//                         color: Colors.white.withOpacity(0.7),
//                         strokeWidth: 2.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (StorageService.isLoggedIn()) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Attendance App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track. Verify. Manage.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Developed by Gaurav',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}