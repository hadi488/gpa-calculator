/// GPA/CGPA Calculator Application Entry Point
///
/// This is the main entry point for the GPA/CGPA Calculator app.
/// It initializes Hive for local storage and sets up Provider for state management.
///
/// Architecture follows Clean Architecture principles:
/// - Models (Domain Layer): Subject, Semester, Student
/// - Services (Data Layer): StorageService, GpaCalculatorService
/// - Providers (Application Layer): StudentProvider, GradeScaleProvider
/// - Screens/Widgets (Presentation Layer): UI components
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/models/subject.dart';
import 'data/models/semester.dart';
import 'data/models/student.dart';
import 'data/services/storage_service.dart';
import 'features/student_management/logic/student_provider.dart';
import 'features/settings/logic/grade_scale_provider.dart';
import 'features/settings/logic/theme_provider.dart';
import 'features/splash/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

/// Application entry point
///
/// Initializes Hive adapters and storage before running the app

import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep native splash until we explicitly remove it
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register Hive type adapters for custom models
  // Order matters: register in dependency order (Subject first, then Semester, then Student)
  if (!Hive.isAdapterRegistered(subjectTypeId)) {
    Hive.registerAdapter(SubjectAdapter());
  }
  if (!Hive.isAdapterRegistered(semesterTypeId)) {
    Hive.registerAdapter(SemesterAdapter());
  }
  if (!Hive.isAdapterRegistered(studentTypeId)) {
    Hive.registerAdapter(StudentAdapter());
  }

  // Initialize storage service and open boxes
  final storageService = StorageService();

  try {
    await storageService.init();
  } catch (e) {
    // If there's an error loading data (e.g., schema change), clear and retry
    debugPrint('Error initializing storage: $e');
    await Hive.deleteBoxFromDisk('students');
    await storageService.init();
  }

  // Initialize grade scale provider
  final gradeScaleProvider = GradeScaleProvider();
  await gradeScaleProvider.init();

  // Initialize theme provider
  final themeProvider = ThemeProvider(storageService: storageService);
  await themeProvider.loadTheme();

  // Run the application with Provider setup
  runApp(
    MultiProvider(
      providers: [
        // Provide StorageService as a singleton throughout the app
        Provider<StorageService>.value(value: storageService),

        // Provide GradeScaleProvider for customizable grading
        ChangeNotifierProvider<GradeScaleProvider>.value(
          value: gradeScaleProvider,
        ),

        // Provide ThemeProvider for theme management
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

        // Student Provider with Dependency Injection
        ChangeNotifierProxyProvider<GradeScaleProvider, StudentProvider>(
          create: (context) =>
              StudentProvider(storageService: context.read<StorageService>())
                ..loadStudents(), // Load students on initialization
          update: (context, gradeScaleProvider, studentProvider) {
            studentProvider?.updateGradeScaleProvider(gradeScaleProvider);
            return studentProvider!;
          },
        ),
      ],
      child: const GpaCalculatorApp(),
    ),
  );
}

/// Root application widget
///
/// Configures MaterialApp with theme, routes, and home screen
class GpaCalculatorApp extends StatelessWidget {
  const GpaCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GPA Calculator',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
