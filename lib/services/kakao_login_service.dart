/// 카카오 로그인 서비스 클래스
///
/// 카카오 SDK를 사용하여 로그인/로그아웃 기능을 제공하는 서비스 클래스입니다.
/// 이 클래스는 순수한 비즈니스 로직만을 담당하며, UI와는 완전히 분리되어 있습니다.
///
/// 주요 기능:
/// - 카카오톡 설치 여부 확인
/// - 카카오톡 또는 카카오계정을 통한 로그인
/// - 사용자 정보 조회
/// - 로그아웃 처리
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 관련 서비스를 제공하는 클래스
class KakaoLoginService {
  /// 카카오 로그인을 수행합니다.
  ///
  /// 카카오톡이 설치되어 있으면 카카오톡으로 로그인하고,
  /// 설치되어 있지 않으면 카카오계정으로 로그인합니다.
  ///
  /// Returns:
  /// - [User?]: 로그인 성공 시 사용자 정보, 실패 시 null
  ///
  /// Throws:
  /// - 로그인 실패 시 예외가 발생할 수 있지만, 내부에서 처리하여 null을 반환합니다.
  Future<User?> login() async {
    try {
      // 카카오톡 앱이 설치되어 있는지 확인
      bool isInstalled = await isKakaoTalkInstalled();

      // 카카오톡 설치 여부에 따라 다른 로그인 방식 사용
      if (isInstalled) {
        // 카카오톡이 설치되어 있으면 카카오톡으로 로그인
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡이 설치되어 있지 않으면 카카오계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 로그인 성공 후 사용자 정보 조회
      return await UserApi.instance.me();
    } catch (error) {
      // 로그인 실패 시 에러 로그 출력
      print('카카오 로그인 실패 $error');
      return null; // 실패 시 null 반환
    }
  }

  /// 카카오 로그아웃을 수행합니다.
  ///
  /// 현재 로그인된 사용자의 세션을 종료하고 SDK에서 토큰을 삭제합니다.
  ///
  /// Throws:
  /// - 로그아웃 실패 시 예외가 발생할 수 있지만, 내부에서 처리합니다.
  Future<void> logout() async {
    try {
      // 카카오 SDK에서 로그아웃 처리
      await UserApi.instance.logout();
      print('로그아웃 성공');
    } catch (error) {
      // 로그아웃 실패 시 에러 로그 출력
      print('로그아웃 실패 $error');
    }
  }
}
