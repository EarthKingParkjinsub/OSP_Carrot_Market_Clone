/// Flutter 앱의 진입점
///
/// 이 파일은 앱의 시작점으로, 다음과 같은 역할을 합니다:
/// 1. Flutter 바인딩 초기화
/// 2. 카카오 SDK 초기화
/// 3. Provider를 사용한 상태 관리 설정
/// 4. 메인 앱 위젯 실행
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:flutter_sandbox/providers/kakao_login_provider.dart';
import 'package:flutter_sandbox/pages/home_page.dart';

/// 앱의 메인 진입점
///
/// Flutter 앱이 시작될 때 가장 먼저 실행되는 함수입니다.
/// 카카오 SDK를 초기화하고 Provider를 설정한 후 앱을 실행합니다.
// Firebase 기능 사용 여부 플래그 (false면 Firebase 비활성화)
const bool kUseFirebase = false;

Future<void> main() async {
  // Flutter 바인딩을 초기화합니다.
  // 이는 Flutter 엔진과의 통신을 위한 필수 단계입니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (비활성화 시 건너뜀)
  if (kUseFirebase) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // 초기화 실패 시에도 앱이 구동되도록 무시
      // print('Firebase init skipped/error: $e');
    }
  }

  // 카카오 SDK를 초기화합니다.
  // 네이티브 앱 키와 자바스크립트 앱 키를 설정합니다.
  KakaoSdk.init(
    nativeAppKey: 'ccfc6bfb577d47dc5ab4a502b03ed075', // 네이티브 앱 키
    javaScriptAppKey: '5812bc6645f94d3381a7c2fbc8c7ce3d', // 웹 앱 키
  );

  // 앱을 실행합니다.
  // ChangeNotifierProvider로 KakaoLoginProvider를 앱 전체에 제공합니다.
  runApp(
    ChangeNotifierProvider(
      create: (context) => KakaoLoginProvider(), // Provider 인스턴스 생성
      child: const MyApp(), // 하위 위젯으로 MyApp 전달
    ),
  );
}

/// 메인 앱 위젯
///
/// MaterialApp을 반환하여 앱의 기본 구조를 설정합니다.
/// 테마와 홈 화면을 지정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Login Test', // 앱 제목
      theme: ThemeData(primarySwatch: Colors.yellow), // 기본 테마 (노란색)
      home: const HomePage(), // 홈 화면으로 HomePage 설정
    );
  }
}
