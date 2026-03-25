import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/profile/profile_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'bloc/workout_plan/workout_plan_bloc.dart';
import 'bloc/progress/progress_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('workouts');
  await Hive.openBox('progress');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => ProfileBloc()..add(ProfileLoaded())),
        BlocProvider(create: (_) => ChatBloc()..add(ChatInitialized())),
        BlocProvider(create: (_) => WorkoutPlanBloc()),
        BlocProvider(create: (_) => ProgressBloc()..add(ProgressLoaded())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Workout Coach',
        theme: AppTheme.dark(),
        home: const SplashScreen(),
      ),
    );
  }
}