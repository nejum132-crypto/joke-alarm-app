# 삶은 계란 (JokeAlarm)

지정한 시간에 아재개그를 알림으로 보내주는 Flutter 앱.

## 주요 기능

- **홈 탭** — 계란 캐릭터를 탭하면 캐릭터가 갈라지면서(크랙 애니메이션, 크랙 범위는 캐릭터 테두리 안으로 제한) 표정이 놀란 얼굴로 바뀌고, 그 자리에 아재개그 문구와 즐겨찾기 버튼이 나타남. 1.25초 후 자동으로 다시 닫힘.
- **지정 시간 탭** — 시계를 든 계란 캐릭터를 탭해 알림 시각을 추가/삭제. 알림은 향후 14일치를 미리 스케줄링하며, 매번 앱을 열 때 창을 채워 넣음(rolling window). 앱바의 ON/OFF 토글과는 완전히 독립적으로 동작.
- **ON/OFF 토글 (앱바 우측 상단)** — 켜면 하루 2번, 랜덤한 시간(오전 9시~오후 9시 사이)에 아재개그 알림이 옴. 랜덤 시각은 매일 새로 뽑힘(고정되지 않음). 지정 시간 탭의 알림과는 별개 ID 대역(≥500000 vs 지정 시간의 `dayOffset*1000` 대역)으로 관리되어 서로 간섭 없이 독립적으로 켜고 끌 수 있음.
- **즐겨찾기 탭** — 카드 리스트 형식으로 저장한 개그를 보여주고 삭제 가능. 비어 있으면 계란 캐릭터가 시무룩해하는 일러스트가 표시됨.
- **알림 데이터셋** — 여러 공개 "아재개그 모음" 블로그에서 수집·중복 제거·정치적/민감 소재 필터링을 거친 383개의 개그가 `lib/data/local_jokes.dart`에 내장되어 있음(오프라인 동작, 외부 서버 없음).
- **알림 시간대 처리** — `flutter_timezone`으로 기기의 실제 시간대를 읽어와 스케줄링(하드코딩된 시간대 없음).
- **앱 아이콘 · 스플래시 · 로딩 화면** — 사용자가 제공한 계란 캐릭터 원화를 기반으로 런처 아이콘/스플래시를 생성했고, 앱 초기화 대기 중에는 캐릭터가 좌우로 갸웃거리는 로딩 화면을 보여줌. 앱바 좌측에는 턱을 괴고 누운 캐릭터 일러스트를 타이틀로 사용.

## 화면 구성 (탭)

| 탭 | 내용 |
|---|---|
| 홈 | 캐릭터 인터랙션 (크랙 애니메이션 + 개그 노출) |
| 지정 시간 | 시계 캐릭터 버튼으로 알림 시각 추가, 목록에서 삭제 |
| 즐겨찾기 | 저장한 개그 카드 목록 |

## 캐릭터 애셋 시스템

사용자가 제공한 손그림 캐릭터 PDF에서 원본 이미지를 추출해 다음 파생 이미지를 생성했습니다 (`assets/images/`):

| 파일 | 용도 |
|---|---|
| `character.png` | 원본 캐릭터(투명 배경) — 빈 화면 일러스트 등 |
| `character_tilt_left.png` / `character_tilt_right.png` | 앱 시작 로딩 화면 번갈아 표시 |
| `character_crack_top.png` | 크랙 시 위로 갈라지는 조각(왕관+이마) |
| `character_crack_bottom.png` | 평상시 얼굴(윙크) — 크랙 하단 조각 |
| `character_crack_bottom_surprised.png` | 크랙이 열렸을 때의 놀란 표정 — 크랙 하단 조각 |
| `character_clock.png` | 지정 시간 탭의 "시간 추가" 버튼 |
| `character_lying.png` | 앱바 타이틀(가로로 누워 턱을 괴고 있는 포즈) — 벡터(SVG) 기반으로 새로 그려 래스터화함 |
| `character_dejected.png` | 즐겨찾기 탭이 비어 있을 때 표시되는 시무룩한 표정 |

`assets/icon/character.png`는 런처 아이콘/스플래시 생성 전용 소스(앱 코드에서 직접 참조하지 않음, `pubspec.yaml`의 `flutter_launcher_icons`/`flutter_native_splash` 설정에서만 사용).

> 원본은 손그림 한 장뿐이라, 대부분의 파생 이미지는 잘라내기·회전·얼굴 패치 등 이미지 편집으로 만들었습니다. 다만 `character_lying`처럼 기존 편집으로 비율이 찌그러지는 한계가 있었던 포즈는 같은 캐릭터 컨셉을 유지한 손그림 스타일 SVG를 새로 그려서 대체했습니다.

## 기술 스택

- Flutter (Material 3), Riverpod (상태관리)
- `flutter_local_notifications` + `timezone` + `flutter_timezone` — 로컬 알림 스케줄링
- `hive` / `hive_flutter` — 알림 시각·즐겨찾기·설정 로컬 저장
- `flutter_launcher_icons`, `flutter_native_splash` — 아이콘/스플래시 생성 도구(빌드 타임 전용, 런타임 의존성 아님)

## 프로젝트 구조

```
lib/
  main.dart                      # 앱 진입점, 테마, 초기화 대기 화면 처리
  models/joke.dart               # Joke 데이터 모델
  data/local_jokes.dart          # 내장 개그 383개
  services/
    joke_repository.dart         # Hive 기반 설정/즐겨찾기 저장, isRandomEnabled, 중복 방지 랜덤 선택
    notification_service.dart    # 알림 스케줄링 — 지정 시간(manual)과 랜덤(random) 두 세트를 ID 대역으로 분리 관리
  state/
    schedule_controller.dart     # 지정 시간 목록 상태(Riverpod) — 랜덤 기능과 무관하게 항상 동작
    random_joke_controller.dart  # ON/OFF 토글 상태(Riverpod) — 하루 2번 랜덤 알림 on/off, 매번 재랜덤
    favorites_controller.dart    # 즐겨찾기 상태(Riverpod)
  providers.dart                  # Riverpod 프로바이더 정의
  screens/
    home_screen.dart             # 탭 구조, AppBar(ON/OFF 토글 포함)
    character_tab.dart           # 홈 탭 (크랙 애니메이션)
    schedule_tab.dart            # 지정 시간 탭 (시계 캐릭터로 시간 추가)
    favorites_tab.dart           # 즐겨찾기 탭 (카드 리스트)
  widgets/
    on_off_toggle.dart           # ON/OFF 커스텀 토글 버튼
    empty_state.dart             # 빈 목록 상태 (캐릭터 + 안내문구)
    loading_character.dart       # 앱 시작 대기 중 로딩 애니메이션
```

## 알림 스케줄링 구조

`NotificationService`는 두 알림 세트를 ID 대역으로 나눠 독립적으로 취소/재등록합니다 (`pendingNotificationRequests()`로 실제 등록된 알림을 확인한 뒤 매칭되는 것만 취소):

- **지정 시간(manual)**: ID `dayOffset*1000 + timeIndex` (500000 미만). 사용자가 지정 시간 탭에서 등록한 시각으로, 매일 동일한 시각에 반복.
- **랜덤(random)**: ID `500000 + dayOffset*10 + slot` (500000 이상). ON/OFF 토글이 켜져 있을 때 하루 2번(오전 9시~오후 9시 사이) 무작위 시각에 발송, 매번 새로고침 시 전체 재랜덤.

두 세트 모두 앞으로 14일치를 미리 스케줄링해두고(rolling window), 앱을 열 때마다 갱신합니다.

## 배포 준비 현황 (Android)

- 릴리스 서명 키 생성 완료 (`android/upload-keystore.jks`, alias `upload`) — **키스토어 파일과 `android/key.properties`의 비밀번호는 로컬에만 존재하므로 반드시 별도 백업 필요** (분실 시 동일 앱으로 업데이트 불가)
- `android/app/build.gradle.kts`에 릴리스 서명 설정 + R8 minify/shrink 활성화, `proguard-rules.pro`에 flutter_local_notifications keep 규칙 추가
- `flutter build appbundle --release` 성공 확인, 릴리스 APK를 에뮬레이터에 설치해 minify된 빌드에서도 알림 스케줄링이 정상 동작함을 검증함

## 남은 작업 (TODO)

- **Google Play 출시 절차** — 개발자 계정 등록($25), 스토어 등록정보(설명/스크린샷/개인정보처리방침 URL), 데이터 안전 설문(수집 데이터 없음으로 응답 가능), 콘텐츠 등급, 정확한 알람 권한 사용 목적 소명, `.aab` 업로드 후 테스트 트랙 배포
- **iOS 빌드 검증** — 아직 실기기/시뮬레이터에서 테스트 안 함 (Mac + Xcode + Apple Developer 계정 필요)
- **원격 개그 동기화** — 현재는 로컬 데이터셋만 사용. 필요 시 Firestore/Sheets 등으로 확장 가능(과거 Firebase 연동을 붙였다가 빌드 부담으로 제거한 이력 있음)
- **지정 시간 편집** — 현재는 추가/삭제만 가능, 기존 시각 수정 기능 없음
- **요일별 알림 제외** — 미구현
- **실제 알림 발동 테스트** — 에뮬레이터에서 OS 알람 등록까지는 확인했으나, 실제 발동 순간은 사용자가 직접 확인함

## 개발 노트

- Windows 환경에서 `flutter_timezone` 같은 최신 플러그인을 쓰려면 Kotlin Gradle 플러그인을 1.8.22 → 2.1.0으로 올려야 했음 (`android/settings.gradle.kts`).
- `dart run flutter_launcher_icons` / `flutter_native_splash:create` 실행에는 Git이 PATH에 있어야 함.
- 이 프로젝트는 아직 git 저장소로 초기화되어 있지 않음 — 버전 관리가 필요해지면 `git init` 필요.
