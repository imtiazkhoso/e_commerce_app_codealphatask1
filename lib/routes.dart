import 'package:flutter/material.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/payments/presentation/pages/payment_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String payment = '/payment';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case emailVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: args?['email'] as String? ?? '',
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersPage());
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 