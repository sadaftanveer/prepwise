import 'package:flutter/material.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/questions/screens/add_question_screen.dart';
import '../../features/questions/screens/question_detail_screen.dart';
import '../../data/models/question_model.dart';
import '../../shared/widgets/app_shell_widget.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
      case RouteNames.login:
        return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
      case RouteNames.signup:
        return MaterialPageRoute<void>(builder: (_) => const SignupScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute<void>(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case RouteNames.addQuestion:
        final Object? args = settings.arguments;
        final QuestionModel? question = args is QuestionModel ? args : null;
        return MaterialPageRoute<void>(
          builder: (_) => AddQuestionScreen(initialQuestion: question),
        );
      case RouteNames.questionDetail:
        final Object? args = settings.arguments;
        final QuestionModel question =
            args is QuestionModel ? args : (throw ArgumentError('Question required'));
        return MaterialPageRoute<void>(
          builder: (_) => QuestionDetailScreen(question: question),
        );
      case RouteNames.shell:
      default:
        return MaterialPageRoute<void>(builder: (_) => const AppShell());
    }
  }
}
