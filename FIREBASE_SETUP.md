# Firebase 설정 가이드

이 문서는 관리자 페이지 및 네이티브 광고 시스템을 위한 Firebase 설정 방법을 안내합니다.

## 📋 목차

1. [Firebase 프로젝트 생성](#1-firebase-프로젝트-생성)
2. [Authentication 설정](#2-authentication-설정)
3. [Firestore Database 설정](#3-firestore-database-설정)
4. [보안 규칙 설정](#4-보안-규칙-설정)
5. [앱 설정 파일 추가](#5-앱-설정-파일-추가)

---

## 1. Firebase 프로젝트 생성

### 1.1 Firebase Console 접속
1. [Firebase Console](https://console.firebase.google.com/) 접속
2. "프로젝트 추가" 클릭

### 1.2 프로젝트 기본 정보 입력
- **프로젝트 이름**: 원하는 이름 입력 (예: "Baro Market")
- **Google Analytics**: 필요에 따라 활성화/비활성화
- **프로젝트 생성** 클릭

### 1.3 플랫폼 등록
#### Android
1. 프로젝트 설정 → 내 앱 → Android 앱 추가
2. 패키지 이름 입력 (예: `com.example.flutter_sandbox`)
3. `google-services.json` 다운로드
4. `android/app/` 폴더에 저장

#### iOS
1. 프로젝트 설정 → 내 앱 → iOS 앱 추가
2. 번들 ID 입력
3. `GoogleService-Info.plist` 다운로드
4. `ios/Runner/` 폴더에 저장

---

## 2. Authentication 설정

### 2.1 이메일/비밀번호 로그인 활성화
1. Firebase Console → **Authentication** → **로그인 방법** 탭
2. "이메일/비밀번호" 항목 찾기
3. **사용 설정** 토글 ON
4. **저장** 클릭

### 2.2 관리자 계정 생성
1. Authentication → **사용자** 탭
2. **사용자 추가** 버튼 클릭
3. 이메일과 비밀번호 입력
   - **이메일**: 관리자 이메일 (예: `admin@example.com`)
   - **비밀번호**: 임시 비밀번호 설정
4. **추가** 클릭

> ⚠️ **중요**: 관리자 비밀번호는 반드시 기록해두세요. 나중에 비밀번호 재설정 이메일을 보낼 수도 있습니다.

---

## 3. Firestore Database 설정

### 3.1 Firestore Database 생성
1. Firebase Console → **Firestore Database**
2. **데이터베이스 만들기** 클릭
3. **프로덕션 모드** 또는 **테스트 모드** 선택
   - 테스트 모드: 30일간 모든 읽기/쓰기 허용
   - 프로덕션 모드: 보안 규칙 필요 (4단계 참고)
4. **위치 선택** (가까운 지역 선택)
5. **사용 설정** 클릭

### 3.2 admins 컬렉션 생성
1. Firestore Database → **데이터** 탭
2. **컬렉션 시작** 클릭
3. 컬렉션 ID: `admins` 입력
4. **다음** 클릭
5. 문서 ID에 **관리자 이메일 주소 그대로** 입력 (예: `admin@example.com`)
   - ⚠️ **주의**: 이메일 주소를 정확히 입력해야 합니다. 공백이나 대소문자 차이가 있으면 안 됩니다.
6. 필드는 비워도 되지만, 선택적으로 추가 가능:
   - `role`: `admin` (문자열)
   - `createdAt`: 서버 타임스탬프
7. **저장** 클릭

### 3.3 ads 컬렉션 구조
`ads` 컬렉션은 관리자 페이지에서 광고를 추가하면 자동으로 생성됩니다.

**컬렉션 구조:**
```
ads/
  {자동생성ID}/
    - title: string (광고 제목)
    - description: string (광고 설명)
    - imageUrl: string (광고 이미지 URL)
    - linkUrl: string (광고 링크 URL)
    - position: number (상품 목록 삽입 위치)
    - isActive: boolean (활성화 여부)
    - createdAt: timestamp (생성일)
    - updatedAt: timestamp (수정일)
```

---

## 4. 보안 규칙 설정

### 4.1 Firestore 보안 규칙 수정
1. Firebase Console → **Firestore Database** → **규칙** 탭
2. 아래 규칙으로 교체:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // admins 컬렉션: 인증된 사용자만 읽기 가능
    match /admins/{email} {
      allow read: if request.auth != null;
      allow write: if false; // 쓰기는 콘솔에서만 가능
    }
    
    // ads 컬렉션: 인증된 사용자만 읽기 가능, 관리자는 쓰기 가능
    match /ads/{adId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.token.email));
    }
    
    // 기타 컬렉션은 필요에 따라 설정
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. **게시** 버튼 클릭

### 4.2 규칙 설명
- **admins 컬렉션**: 
  - 인증된 사용자만 읽기 가능
  - 쓰기는 콘솔에서만 가능 (보안을 위해)
- **ads 컬렉션**:
  - 인증된 사용자만 읽기 가능
  - 관리자만 쓰기 가능 (admins 컬렉션에 이메일이 있는 경우)
- **기타 컬렉션**: 
  - 인증된 사용자만 읽기/쓰기 가능

---

## 5. 앱 설정 파일 추가

### 5.1 Android 설정
1. Firebase Console → 프로젝트 설정 → 내 앱 → Android 앱
2. `google-services.json` 다운로드
3. `android/app/google-services.json`에 저장

### 5.2 iOS 설정
1. Firebase Console → 프로젝트 설정 → 내 앱 → iOS 앱
2. `GoogleService-Info.plist` 다운로드
3. `ios/Runner/GoogleService-Info.plist`에 저장

### 5.3 Firebase Options 파일 생성
FlutterFire CLI를 사용하여 자동 생성:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

또는 수동으로 `lib/firebase_options.dart` 파일을 생성하고 Firebase Console에서 설정값을 복사하여 입력합니다.

---

## 🔍 설정 확인

### 관리자 권한 확인
1. 앱에서 관리자 이메일로 로그인
2. 프로필 페이지로 이동
3. 설정 아이콘(톱니바퀴)을 **10번 연속 탭**
4. 관리자 페이지(`AdminPage`)가 열리면 성공!

### 광고 추가 확인
1. 관리자 페이지에서 광고 추가
2. Firebase Console → Firestore Database → `ads` 컬렉션 확인
3. 상품 목록 페이지에서 광고가 표시되는지 확인

---

## ⚠️ 주의사항

1. **이메일 주소 정확성**: 
   - `admins` 컬렉션의 문서 ID와 Authentication의 이메일이 **완전히 동일**해야 합니다.
   - 공백이나 대소문자 차이가 있으면 관리자 권한이 인식되지 않습니다.

2. **보안 규칙**:
   - 프로덕션 환경에서는 반드시 보안 규칙을 설정해야 합니다.
   - 테스트 환경에서만 "테스트 모드" 사용 가능합니다.

3. **비밀번호 관리**:
   - 관리자 비밀번호는 안전하게 관리하세요.
   - 필요시 Firebase Console에서 비밀번호 재설정 이메일을 보낼 수 있습니다.

---

## 🐛 문제 해결

### "관리자 권한이 없습니다" 오류
- `admins` 컬렉션에 문서가 있는지 확인
- 문서 ID가 로그인 이메일과 정확히 일치하는지 확인
- Firestore 보안 규칙이 올바르게 설정되었는지 확인

### "PERMISSION_DENIED" 오류
- Firestore 보안 규칙을 확인하세요
- 인증된 사용자가 읽기 권한을 가지고 있는지 확인

### 로그인이 안 되는 경우
- Authentication에서 이메일/비밀번호 로그인이 활성화되어 있는지 확인
- 네트워크 연결 상태 확인
- 비밀번호가 올바른지 확인

---

## 📚 추가 리소스

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [Firestore 보안 규칙 가이드](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire 문서](https://firebase.flutter.dev/)

---

**작성일**: 2024-01-01  
**버전**: 1.0.0

