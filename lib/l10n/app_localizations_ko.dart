// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutConfirmTitle => '로그아웃';

  @override
  String get signOutConfirmMessage => '로그아웃 하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get appearance => '화면';

  @override
  String get darkMode => '다크 모드';

  @override
  String get on => '켜짐';

  @override
  String get off => '꺼짐';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get notifications => '알림';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get enabled => '켜짐';

  @override
  String get disabled => '꺼짐';

  @override
  String get notificationHistory => '알림 기록';

  @override
  String get viewPastNotifications => '이전 알림 보기';

  @override
  String get markAllRead => '모두 읽음';

  @override
  String get noNotifications => '알림이 없습니다';

  @override
  String get failedToLoadNotifications => '알림을 불러오지 못했습니다';

  @override
  String get timeNow => '지금';

  @override
  String get about => '정보';

  @override
  String get aboutAppName => 'August Chat 정보';

  @override
  String version(String version) {
    return '버전 $version';
  }

  @override
  String get appDescription => 'Flutter로 만든 현대적인 채팅 앱입니다.';

  @override
  String get rooms => '채팅방';

  @override
  String get newDirectChat => '새 1:1 대화';

  @override
  String get newGroup => '새 그룹';

  @override
  String get noChatsYet => '아직 채팅이 없습니다. 시작해보세요!';

  @override
  String get failedToLoadRooms => '채팅방을 불러오지 못했습니다';

  @override
  String get users => '친구';

  @override
  String get failedToLoadUsers => '친구를 불러오지 못했습니다';

  @override
  String get createGroup => '새 그룹';

  @override
  String get groupName => '그룹 이름';

  @override
  String get groupNameRequired => '그룹 이름을 입력하세요';

  @override
  String get selectAtLeastOneMember => '최소 1명 이상 선택하세요';

  @override
  String get message => '메시지';

  @override
  String get chatError => '채팅 오류';

  @override
  String get gallery => '갤러리';

  @override
  String get camera => '카메라';

  @override
  String get file => '파일';

  @override
  String get location => '위치';

  @override
  String get voiceRecordingNotImplemented => '음성 녹음은 아직 지원되지 않습니다';

  @override
  String get welcomeSignIn => 'Wallabie에 오신 것을 환영합니다. 로그인 해주세요!';

  @override
  String get welcomeSignUp => 'Wallabie에 오신 것을 환영합니다. 회원가입 해주세요!';

  @override
  String get termsAgreement => '로그인하면 이용약관에 동의하는 것으로 간주됩니다.';
}
