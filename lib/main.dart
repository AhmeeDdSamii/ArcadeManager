import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'splash_screen.dart';

// CRITICAL: Remove hardcoded shopId - it causes listeners to monitor wrong Firestore path
// The shopId must be set dynamically based on the logged-in user's storeCode
const _shopId = ''; // Empty placeholder - will be set dynamically

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // CRITICAL: Initialize Firebase BEFORE accessing Firestore to prevent FirebaseException
  // This is done before creating the store to ensure proper initialization
  bool firebaseInitialized = false;
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCvB9azStlcC_af6iZSC8uH9eeJgfqGoNI",
          authDomain: "playcontrol-53ec1.firebaseapp.com",
          projectId: "playcontrol-53ec1",
          storageBucket: "playcontrol-53ec1.firebasestorage.app",
          messagingSenderId: "624369480168",
          appId: "1:624369480168:web:eb31a36bfe9070763cf45d",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    firebaseInitialized = true;
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization error: $e - running in offline mode");
    // App continues to work in offline mode if Firebase fails
    firebaseInitialized = false;
  }
  
  // CRITICAL: Initialize CloudSync with proper error handling
  // We need to handle the case where Firestore might throw FirebaseException
  CloudSync sync;
  try {
    // Only attempt to access Firestore if Firebase was initialized
    if (firebaseInitialized) {
      sync = CloudSync(FirebaseFirestore.instance, _shopId, online: false);
    } else {
      // Firebase failed to initialize, but we still need to create CloudSync
      // Try to create it with Firestore instance, but expect it might fail
      sync = CloudSync(FirebaseFirestore.instance, _shopId, online: false);
    }
  } catch (e) {
    debugPrint("Critical error in Firebase/Firestore initialization: $e");
    // Show user-friendly error and prevent app from crashing
    debugPrint("Please check Firebase configuration in pubspec.yaml and ensure Firebase is properly set up for web platform");
    rethrow;
  }
  
  final store = PosStore(sync);
  
  // CRITICAL: Set ready immediately to show login screen without any blocking
  store._ready = true;
  store.notifyListeners();

  runApp(PosScope(notifier: store, child: const ArcadeApp()));
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class AppColors {
  static const bg = Color(0xFF0D0E15);
  static const card = Color(0xFF161822);
  static const cardInner = Color(0xFF12141C);
  static const elevated = Color(0xFF1C1F2B);
  static const border = Color(0xFF2A2D3A);
  static const purple = Color(0xFF7C3AED);
  static const purpleDim = Color(0xFF3B2466);
  static const green = Color(0xFF10B981);
  static const greenDim = Color(0xFF064E3B);
  static const cyan = Color(0xFF22D3EE);
  static const gold = Color(0xFFEAB308);
  static const red = Color(0xFFEF4444);
  static const redDim = Color(0xFF7F1D1D);
  static const orange = Color(0xFFF59E0B);
  static const orangeDim = Color(0xFF92400E);
  static const text = Color(0xFFF3F4F6);
  static const muted = Color(0xFF9CA3AF);
  static const faint = Color(0xFF6B7280);
}

class AppBranding {
  static const name = 'PlayControl';
  static const version = '1.0.0';
  static const developer = 'Ahmed Sami';
  static const developerCreditAr = 'تطوير وإعداد: Ahmed Sami';
  static const developerCreditEn = 'Developed with ❤️ by Ahmed Sami';
  static const descriptionAr =
      'نظام إدارة متكامل لإدارة صالات البلايستيشن والكافيهات مع المزامنة السحابية اللحظية وتقارير الورديات.';
  static const featuresAr = [
    'إدارة أجهزة البلايستيشن والجلسات.',
    'نظام الكافيه والمخزون والتكاليف.',
    'تقارير الأرباح وسجل تسجيل الدخول.',
    'نظام صلاحيات الموظفين والأكواد المشفرة.',
  ];
}

class PlayControlTitle extends StatelessWidget {
  const PlayControlTitle({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppBranding.name,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: AppColors.text,
        shadows: [
          Shadow(
            color: AppColors.purple.withValues(alpha: 0.95),
            blurRadius: 16,
          ),
          Shadow(
            color: AppColors.purple.withValues(alpha: 0.55),
            blurRadius: 32,
          ),
          Shadow(
            color: AppColors.purple.withValues(alpha: 0.25),
            blurRadius: 48,
          ),
        ],
      ),
    );
  }
}

class DeveloperFooter extends StatelessWidget {
  const DeveloperFooter({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 8 : 16, 16, compact ? 12 : 20),
      child: Text(
        AppBranding.developerCreditAr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.faint.withValues(alpha: 0.9),
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class AboutAppPanel extends StatelessWidget {
  const AboutAppPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purpleDim,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'معلومات التطبيق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PlayControlTitle(fontSize: 24),
          const SizedBox(height: 4),
          Text(
            'الإصدار ${AppBranding.version}',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.purpleDim.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              AppBranding.developerCreditAr,
              style: const TextStyle(
                color: Color(0xFFDDD6FE),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppBranding.descriptionAr,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'المميزات:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...AppBranding.featuresAr.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.text,
                        height: 1.45,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArcadeApp extends StatelessWidget {
  const ArcadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.name,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purple,
          secondary: AppColors.green,
          surface: AppColors.card,
        ),
        fontFamily: 'Segoe UI',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.elevated,
          contentTextStyle: const TextStyle(color: AppColors.text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onComplete: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppRoot()),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum AppTab { devices, invoices, inventory, reports, settings, loginLogs }

enum UserRole { admin, staff, worker }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.admin => 'صاحب المحل / المدير',
    UserRole.staff => 'العاملين / الكاشير',
    UserRole.worker => 'عامل',
  };

  String get shortTag => switch (this) {
    UserRole.admin => 'مدير',
    UserRole.staff => 'كاشير',
    UserRole.worker => 'عامل',
  };
}

enum PlayMode { single, multi, matchSingle, matchMulti }

extension PlayModeX on PlayMode {
  String get label {
    switch (this) {
      case PlayMode.single:
        return 'فردي';
      case PlayMode.multi:
        return 'زوجي';
      case PlayMode.matchSingle:
        return 'ماتش فردي';
      case PlayMode.matchMulti:
        return 'ماتش زوجي';
    }
  }

  String get name {
    switch (this) {
      case PlayMode.single:
        return 'single';
      case PlayMode.multi:
        return 'multi';
      case PlayMode.matchSingle:
        return 'matchSingle';
      case PlayMode.matchMulti:
        return 'matchMulti';
    }
  }
}

class Device {
  Device({
    required this.id,
    required this.name,
    required this.singleRate,
    required this.multiRate,
    this.matchSingleRate = 5.0,
    this.matchMultiRate = 8.0,
    this.preferredMode = PlayMode.single,
    this.session,
  });

  String id;
  String name;
  double singleRate;
  double multiRate;
  double matchSingleRate;
  double matchMultiRate;
  PlayMode preferredMode;
  Session? session;

  bool get isBusy => session != null;

  double rateFor(PlayMode mode) {
    switch (mode) {
      case PlayMode.single:
        return singleRate;
      case PlayMode.multi:
        return multiRate;
      case PlayMode.matchSingle:
        return matchSingleRate;
      case PlayMode.matchMulti:
        return matchMultiRate;
    }
  }

  Device copyWith({
    String? id,
    String? name,
    double? singleRate,
    double? multiRate,
    double? matchSingleRate,
    double? matchMultiRate,
    PlayMode? preferredMode,
    Session? session,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      singleRate: singleRate ?? this.singleRate,
      multiRate: multiRate ?? this.multiRate,
      matchSingleRate: matchSingleRate ?? this.matchSingleRate,
      matchMultiRate: matchMultiRate ?? this.matchMultiRate,
      preferredMode: preferredMode ?? this.preferredMode,
      session: session ?? this.session,
    );
  }
}

class Session {
  Session({
    required this.startedAt,
    required this.mode,
    required this.customer,
    this.customDurationMinutes,
    this.numberOfMatches = 1,
    List<OrderLine>? orders,
  }) : orders = orders ?? [];

  DateTime startedAt;
  PlayMode mode;
  String customer;
  int? customDurationMinutes; // Custom timer duration in minutes
  int numberOfMatches; // Number of matches for match-based billing
  List<OrderLine> orders;

  int get cafeQty => orders.fold(0, (a, o) => a + o.qty);
  double get cafeTotal => orders.fold(0.0, (a, o) => a + o.lineTotal);

  Map<String, dynamic> toMap() => {
    'startedAt': startedAt.toIso8601String(),
    'mode': mode.name,
    'customer': customer,
    'customDurationMinutes': customDurationMinutes,
    'numberOfMatches': numberOfMatches,
    'orders': orders.map((o) => o.toMap()).toList(),
  };

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      startedAt: DateTime.parse(map['startedAt'] as String),
      mode: PlayMode.values.firstWhere(
        (m) => m.name == map['mode'],
        orElse: () => PlayMode.single,
      ),
      customer: map['customer'] as String,
      customDurationMinutes: map['customDurationMinutes'] as int?,
      numberOfMatches: map['numberOfMatches'] as int? ?? 1,
      orders: (map['orders'] as List?)
              ?.map((o) => OrderLine.fromMap(o as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderLine {
  OrderLine({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.qty,
  });

  String itemId;
  String name;
  double unitPrice;
  int qty;

  double get lineTotal => unitPrice * qty;

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'name': name,
    'unitPrice': unitPrice,
    'qty': qty,
  };

  factory OrderLine.fromMap(Map<String, dynamic> m) => OrderLine(
    itemId: m['itemId'] as String,
    name: m['name'] as String,
    unitPrice: (m['unitPrice'] as num).toDouble(),
    qty: m['qty'] as int,
  );
}

class CafeItem {
  CafeItem({
    required this.id,
    required this.name,
    required this.sell,
    required this.buy,
    required this.stock,
    required this.alert,
  });

  String id;
  String name;
  double sell;
  double buy;
  int stock;
  int alert;
}

class Invoice {
  Invoice({
    required this.id,
    required this.deviceName,
    required this.customer,
    required this.from,
    required this.to,
    required this.billedMinutes,
    required this.timeCost,
    required this.cafeCost,
    required this.discount,
    required this.total,
    required this.staffName,
    required this.mode,
    this.cafeLines = const [],
    this.createdAt,
    this.createdBy, // CRITICAL: Explicit field for user attribution
  });

  final String id;
  final String deviceName;
  final String customer;
  final DateTime from;
  final DateTime to;
  final int billedMinutes;
  final double timeCost;
  final double cafeCost;
  final double discount;
  final double total;
  final String staffName;
  final PlayMode mode;
  final List<OrderLine> cafeLines;
  final DateTime? createdAt;
  final String? createdBy; // CRITICAL: Explicit field for user attribution

  factory Invoice.fromMap(Map<String, dynamic> m) => Invoice(
    id: m['id'] as String,
    deviceName: m['deviceName'] as String,
    customer: m['customer'] as String,
    from: DateTime.parse(m['from'] as String),
    to: DateTime.parse(m['to'] as String),
    billedMinutes: m['billedMinutes'] as int,
    timeCost: (m['timeCost'] as num).toDouble(),
    cafeCost: (m['cafeCost'] as num).toDouble(),
    discount: (m['discount'] as num).toDouble(),
    total: (m['total'] as num).toDouble(),
    staffName: m['staffName'] as String,
    mode: PlayMode.values.firstWhere((e) => e.name == m['mode']),
    cafeLines: (m['cafeLines'] as List<dynamic>)
        .map((e) => OrderLine.fromMap(e as Map<String, dynamic>))
        .toList(),
    createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt'] as String) : null,
    createdBy: m['createdBy'] as String?, // CRITICAL: Read createdBy field
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'deviceName': deviceName,
    'customer': customer,
    'from': from.toIso8601String(),
    'to': to.toIso8601String(),
    'billedMinutes': billedMinutes,
    'timeCost': timeCost,
    'cafeCost': cafeCost,
    'discount': discount,
    'total': total,
    'staffName': staffName,
    'mode': mode.name,
    'cafeLines': cafeLines.map((e) => e.toMap()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'createdBy': createdBy, // CRITICAL: Include createdBy field in Firestore
  };
}

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.at,
  });

  String id;
  String title;
  double amount;
  DateTime at;
}

class Employee {
  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.code,
    this.isOwner = false,
  });

  String id;
  String name;
  String role;
  String code;
  bool isOwner;
}

class ClosedShift {
  ClosedShift({
    required this.at,
    required this.invoices,
    required this.timeRevenue,
    required this.cafeRevenue,
    required this.discounts,
    required this.collected,
    required this.expenses,
    required this.net,
  });

  final DateTime at;
  final int invoices;
  final double timeRevenue;
  final double cafeRevenue;
  final double discounts;
  final double collected;
  final double expenses;
  final double net;

  Map<String, dynamic> toMap() => {
    'at': at.toIso8601String(),
    'invoices': invoices,
    'timeRevenue': timeRevenue,
    'cafeRevenue': cafeRevenue,
    'discounts': discounts,
    'collected': collected,
    'expenses': expenses,
    'net': net,
  };

  factory ClosedShift.fromMap(Map<String, dynamic> m) => ClosedShift(
    at: DateTime.parse(m['at'] as String),
    invoices: m['invoices'] as int? ?? 0,
    timeRevenue: (m['timeRevenue'] as num?)?.toDouble() ?? 0,
    cafeRevenue: (m['cafeRevenue'] as num?)?.toDouble() ?? 0,
    discounts: (m['discounts'] as num?)?.toDouble() ?? 0,
    collected: (m['collected'] as num?)?.toDouble() ?? 0,
    expenses: (m['expenses'] as num?)?.toDouble() ?? 0,
    net: (m['net'] as num?)?.toDouble() ?? 0,
  );
}

enum ShiftEvent { login, shiftEnd }

class LoginAuditEntry {
  LoginAuditEntry({
    required this.id,
    required this.employeeName,
    required this.role,
    required this.at,
    required this.event,
    this.isOwner = false,
  });

  final String id;
  final String employeeName;
  final String role;
  final DateTime at;
  final ShiftEvent event;
  final bool isOwner;

  String get statusLabel =>
      event == ShiftEvent.login ? 'بدء وردية' : 'تقفيل اليوم';

  Map<String, dynamic> toMap() => {
    'id': id,
    'employeeName': employeeName,
    'role': role,
    'at': at.toIso8601String(),
    'event': event.name,
    'isOwner': isOwner,
  };

  factory LoginAuditEntry.fromMap(Map<String, dynamic> m) => LoginAuditEntry(
    id: m['id'] as String? ?? '',
    employeeName: m['employeeName'] as String? ?? '',
    role: m['role'] as String? ?? '',
    at: DateTime.parse(m['at'] as String),
    event: m['event'] == 'shiftEnd' ? ShiftEvent.shiftEnd : ShiftEvent.login,
    isOwner: m['isOwner'] as bool? ?? false,
  );
}

class StoreAuth {
  StoreAuth({
    required this.storeCode,
    required this.ownerPassword,
    required this.createdAt,
    this.securityQuestion,
    this.securityAnswer,
    this.expiryDate,
  });

  final String storeCode;
  final String ownerPassword;
  final DateTime createdAt;
  final String? securityQuestion;
  final String? securityAnswer;
  final DateTime? expiryDate;

  Map<String, dynamic> toMap() => {
    'storeCode': storeCode,
    'ownerPassword': ownerPassword,
    'createdAt': createdAt.toIso8601String(),
    'securityQuestion': securityQuestion,
    'securityAnswer': securityAnswer,
    'expiryDate': expiryDate?.toIso8601String(),
  };

  factory StoreAuth.fromMap(Map<String, dynamic> m) => StoreAuth(
    storeCode: m['storeCode'] as String,
    ownerPassword: m['ownerPassword'] as String,
    createdAt: DateTime.parse(m['createdAt'] as String),
    securityQuestion: m['securityQuestion'] as String?,
    securityAnswer: m['securityAnswer'] as String?,
    expiryDate: m['expiryDate'] != null
        ? DateTime.parse(m['expiryDate'] as String)
        : null,
  );
}

class WorkerSession {
  WorkerSession({
    required this.workerName,
    required this.storeCode,
    required this.deviceId,
    required this.loginTime,
    this.shiftEndTime,
  });

  final String workerName;
  final String storeCode;
  final String deviceId;
  final DateTime loginTime;
  DateTime? shiftEndTime;

  bool get isShiftActive => shiftEndTime == null;

  Map<String, dynamic> toMap() => {
    'workerName': workerName,
    'storeCode': storeCode,
    'deviceId': deviceId,
    'loginTime': loginTime.toIso8601String(),
    'shiftEndTime': shiftEndTime?.toIso8601String(),
  };

  factory WorkerSession.fromMap(Map<String, dynamic> m) => WorkerSession(
    workerName: m['workerName'] as String,
    storeCode: m['storeCode'] as String,
    deviceId: m['deviceId'] as String,
    loginTime: DateTime.parse(m['loginTime'] as String),
    shiftEndTime: m['shiftEndTime'] != null
        ? DateTime.parse(m['shiftEndTime'] as String)
        : null,
  );
}

class SecurityQuestion {
  SecurityQuestion({
    required this.id,
    required this.questionAr,
    required this.questionEn,
  });

  final String id;
  final String questionAr;
  final String questionEn;
}

final List<SecurityQuestion> securityQuestions = [
  SecurityQuestion(
    id: 'pet_name',
    questionAr: 'ما هو اسم حيوانك الأليف الأول؟',
    questionEn: 'What is your first pet\'s name?',
  ),
  SecurityQuestion(
    id: 'mother_maiden',
    questionAr: 'ما هو اسم والدتك قبل الزواج؟',
    questionEn: 'What is your mother\'s maiden name?',
  ),
  SecurityQuestion(
    id: 'first_school',
    questionAr: 'ما هو اسم أول مدرسة درست فيها؟',
    questionEn: 'What is the name of your first school?',
  ),
  SecurityQuestion(
    id: 'birth_city',
    questionAr: 'في أي مدينة ولدت؟',
    questionEn: 'In which city were you born?',
  ),
  SecurityQuestion(
    id: 'favorite_color',
    questionAr: 'ما هو لونك المفضل؟',
    questionEn: 'What is your favorite color?',
  ),
];

// ---------------------------------------------------------------------------
// Cloud sync (Firestore)
// ---------------------------------------------------------------------------

class CloudSync {
  CloudSync(this._db, this.shopId, {required this.online});

  final FirebaseFirestore _db;
  String shopId;
  bool online; // CRITICAL: Made mutable to enable after login

  FirebaseFirestore get firestore => _db;

  // CRITICAL: Make collection references dynamic to always use current shopId
  // This ensures bidirectional sync works when shopId changes during login
  DocumentReference<Map<String, dynamic>> _storeDoc(String storeCode) =>
      _db.collection('stores').doc(storeCode);

  DocumentReference<Map<String, dynamic>> _stateDoc(String storeCode) =>
      _storeDoc(storeCode).collection('meta').doc('state');

  CollectionReference<Map<String, dynamic>> _logsCol(String storeCode) =>
      _storeDoc(storeCode).collection('loginLogs');

  CollectionReference<Map<String, dynamic>> _workerSessionsCol(String storeCode) =>
      _storeDoc(storeCode).collection('workerSessions');

  CollectionReference<Map<String, dynamic>> _employeesCol(String storeCode) =>
      _storeDoc(storeCode).collection('employees');

  CollectionReference<Map<String, dynamic>> _inventoryCol(String storeCode) =>
      _storeDoc(storeCode).collection('inventory');

  CollectionReference<Map<String, dynamic>> _devicesCol(String storeCode) =>
      _storeDoc(storeCode).collection('devices');

  CollectionReference<Map<String, dynamic>> _invoicesCol(String storeCode) =>
      _storeDoc(storeCode).collection('invoices');

  Future<void> ensureShopDoc(String storeCode, Map<String, dynamic> initial) async {
    if (!online) return;
    final snap = await _stateDoc(storeCode).get();
    if (!snap.exists) await _stateDoc(storeCode).set(initial);
  }

  Stream<Map<String, dynamic>?> watchState(String storeCode) {
    if (!online) return const Stream.empty();
    return _stateDoc(storeCode).snapshots().map((s) => s.data());
  }

  Stream<List<LoginAuditEntry>> watchLoginLogs(String storeCode) {
    if (!online) return const Stream.empty();
    return _logsCol(storeCode)
        .orderBy('at', descending: true)
        .limit(200)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => LoginAuditEntry.fromMap(d.data())).toList(),
        );
  }

  Stream<List<Device>> watchDevices(String storeCode) {
    if (!online) return const Stream.empty();
    return _devicesCol(storeCode).snapshots().map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final device = Device(
                id: doc.id,
                name: data['name'] as String,
                singleRate: (data['singleRate'] as num).toDouble(),
                multiRate: (data['multiRate'] as num).toDouble(),
                matchSingleRate: (data['matchSingleRate'] as num?)?.toDouble() ?? 5.0,
                matchMultiRate: (data['matchMultiRate'] as num?)?.toDouble() ?? 8.0,
              );
              
              // Handle session data if present
              if (data['session'] != null && data['isBusy'] == true) {
                final sessionData = data['session'] as Map<String, dynamic>;
                device.session = Session(
                  startedAt: DateTime.parse(sessionData['startedAt'] as String),
                  mode: PlayMode.values.firstWhere(
                    (m) => m.name == sessionData['mode'],
                    orElse: () => PlayMode.single,
                  ),
                  customer: sessionData['customer'] as String,
                  customDurationMinutes: sessionData['customDurationMinutes'] as int?,
                  numberOfMatches: sessionData['numberOfMatches'] as int? ?? 1,
                  orders: (sessionData['orders'] as List?)
                          ?.map((o) => OrderLine.fromMap(o as Map<String, dynamic>))
                          .toList() ??
                      [],
                );
              }
              
              return device;
            }).toList());
  }

  Stream<List<Invoice>> watchInvoices(String storeCode) {
    if (!online) return const Stream.empty();
    return _invoicesCol(storeCode)
        .orderBy('from', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invoice.fromMap(doc.data()))
            .toList());
  }

  Stream<List<CafeItem>> watchInventory(String storeCode) {
    if (!online) return const Stream.empty();
    return _inventoryCol(storeCode)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => cafeItemFromMap(doc.data()))
            .toList());
  }

  Future<void> saveState(String storeCode, Map<String, dynamic> data) async {
    if (!online) return;
    await _stateDoc(storeCode).set(data, SetOptions(merge: true));
  }

  Future<void> saveSettings(String storeCode, Map<String, dynamic> settings) async {
    if (!online) return;
    // CRITICAL: Use the explicit storeCode parameter to ensure writes go to the correct store
    // This prevents issues where internal shopId might not match the logged-in storeCode
    await _db
        .collection('stores')
        .doc(storeCode)
        .set(settings, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchSettings(String storeCode) {
    if (!online) return const Stream.empty();
    return _db
        .collection('stores')
        .doc(storeCode)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Future<void> appendLoginLog(String storeCode, LoginAuditEntry entry) async {
    if (!online) return;
    await _logsCol(storeCode).doc(entry.id).set(entry.toMap());
  }

  Future<bool> checkStoreCodeExists(String storeCode) async {
    if (!online) return false;
    try {
      final doc = await _db.collection('storeAuth').doc(storeCode).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking store code: $e');
      return false;
    }
  }

  Future<void> createStoreAuth(StoreAuth storeAuth) async {
    if (!online) return;
    await _db
        .collection('storeAuth')
        .doc(storeAuth.storeCode)
        .set(storeAuth.toMap());
  }

  Future<StoreAuth?> getStoreAuth(String storeCode) async {
    if (!online) return null;
    try {
      final doc = await _db.collection('storeAuth').doc(storeCode).get();
      if (doc.exists) {
        return StoreAuth.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting store auth: $e');
      return null;
    }
  }

  Future<bool> updateStorePassword(String storeCode, String newPassword) async {
    if (!online) return false;
    try {
      await _db.collection('storeAuth').doc(storeCode).update({
        'ownerPassword': newPassword,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating store password: $e');
      return false;
    }
  }

  Future<bool> verifySecurityAnswer(String storeCode, String answer) async {
    if (!online) return false;
    try {
      final doc = await _db.collection('storeAuth').doc(storeCode).get();
      if (doc.exists) {
        final storeAuth = StoreAuth.fromMap(doc.data()!);
        return storeAuth.securityAnswer?.toLowerCase() == answer.toLowerCase();
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying security answer: $e');
      return false;
    }
  }

  Future<void> logWorkerLogin(String storeCode, WorkerSession session) async {
    if (!online) return;
    await _workerSessionsCol(storeCode)
        .doc('${session.deviceId}_${session.loginTime.millisecondsSinceEpoch}')
        .set(session.toMap());
  }

  Future<void> updateWorkerShiftEnd(String storeCode, String sessionId, DateTime endTime) async {
    if (!online) return;
    await _workerSessionsCol(storeCode).doc(sessionId).update({
      'shiftEndTime': endTime.toIso8601String(),
    });
  }

  Future<List<WorkerSession>> getActiveWorkerSessions(String storeCode) async {
    if (!online) return [];
    try {
      final snapshot = await _workerSessionsCol(storeCode)
          .where('storeCode', isEqualTo: storeCode)
          .where('shiftEndTime', isNull: true)
          .get();
      return snapshot.docs
          .map((doc) => WorkerSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting active worker sessions: $e');
      return [];
    }
  }

  Future<List<WorkerSession>> getWorkerLoginHistory(
    String storeCode, {
    int limit = 50,
  }) async {
    if (!online) return [];
    try {
      final snapshot = await _workerSessionsCol(storeCode)
          .where('storeCode', isEqualTo: storeCode)
          .orderBy('loginTime', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => WorkerSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting worker login history: $e');
      return [];
    }
  }

  Future<void> saveEmployees(String storeCode, List<Employee> employees) async {
    if (!online) return;
    for (final employee in employees) {
      await _employeesCol(storeCode).doc(employee.id).set(employeeToMap(employee));
    }
  }

  Future<void> saveEmployee(String storeCode, Employee employee) async {
    if (!online) return;
    await _employeesCol(storeCode).doc(employee.id).set(employeeToMap(employee));
  }

  Future<void> deleteEmployee(String storeCode, String employeeId) async {
    if (!online) return;
    await _employeesCol(storeCode).doc(employeeId).delete();
  }

  Future<List<Employee>> loadEmployees(String storeCode) async {
    if (!online) return [];
    try {
      final snapshot = await _employeesCol(storeCode).get();
      return snapshot.docs.map((doc) => employeeFromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading employees: $e');
      return [];
    }
  }

  Future<List<Employee>> loadEmployeesFresh(String storeCode) async {
    if (!online) return [];
    try {
      // Force fresh fetch without caching
      final snapshot = await _employeesCol(storeCode).get();
      return snapshot.docs.map((doc) => employeeFromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading fresh employees: $e');
      return [];
    }
  }

  Future<List<Employee>> loadEmployeesForStore(String storeCode) async {
    if (!online) return [];
    try {
      // Force fresh fetch for specific store
      final snapshot = await _employeesCol(storeCode).get();
      return snapshot.docs.map((doc) => employeeFromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading employees for store $storeCode: $e');
      return [];
    }
  }

  void updateShopId(String newShopId) {
    shopId = newShopId;
  }

  Future<void> saveInventory(String storeCode, List<CafeItem> items) async {
    if (!online) return;
    for (final item in items) {
      await _inventoryCol(storeCode).doc(item.id).set(cafeItemToMap(item));
    }
  }

  Future<void> saveInvoice(Invoice invoice, String storeCode) async {
    if (!online) return;
    final invoiceData = invoice.toMap();
    // Use server timestamp if createdAt is not already set
    if (invoiceData['createdAt'] == null) {
      invoiceData['createdAt'] = FieldValue.serverTimestamp();
    }
    // CRITICAL: Use the explicit storeCode parameter to ensure writes go to the correct store
    // This prevents issues where internal shopId might not match the logged-in storeCode
    await _db
        .collection('stores')
        .doc(storeCode)
        .collection('invoices')
        .doc(invoice.id)
        .set(invoiceData);
  }

  Future<void> saveDevice(Device device, String storeCode) async {
    if (!online) return;
    final deviceData = <String, dynamic>{
      'name': device.name,
      'singleRate': device.singleRate,
      'multiRate': device.multiRate,
      'matchSingleRate': device.matchSingleRate,
      'matchMultiRate': device.matchMultiRate,
      'isBusy': device.isBusy,
    };
    
    // CRITICAL: Explicitly handle session null to ensure device becomes "فاضي" (idle) across windows
    if (device.session != null) {
      deviceData['session'] = device.session!.toMap();
    } else {
      // Explicitly set session to null to clear it in Firestore
      deviceData['session'] = FieldValue.delete();
    }
    
    // CRITICAL: Use the explicit storeCode parameter to ensure writes go to the correct store
    // This prevents issues where internal shopId might not match the logged-in storeCode
    await _db
        .collection('stores')
        .doc(storeCode)
        .collection('devices')
        .doc(device.id)
        .set(deviceData, SetOptions(merge: true));
  }

  Future<void> deleteDevice(String deviceId, String storeCode) async {
    if (!online) return;
    // CRITICAL: Use the explicit storeCode parameter to ensure writes go to the correct store
    // This prevents issues where internal shopId might not match the logged-in storeCode
    await _db
        .collection('stores')
        .doc(storeCode)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }

  Future<List<CafeItem>> loadInventory(String storeCode) async {
    if (!online) return [];
    try {
      final snapshot = await _inventoryCol(storeCode).get();
      return snapshot.docs.map((doc) => cafeItemFromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading inventory: $e');
      return [];
    }
  }

  Map<String, dynamic> employeeToMap(Employee e) => {
    'id': e.id,
    'name': e.name,
    'role': e.role,
    'code': e.code,
    'isOwner': e.isOwner,
  };

  Employee employeeFromMap(Map<String, dynamic> m) => Employee(
    id: m['id'] as String,
    name: m['name'] as String,
    role: m['role'] as String,
    code: m['code'] as String,
    isOwner: m['isOwner'] as bool? ?? false,
  );

  Map<String, dynamic> cafeItemToMap(CafeItem c) => {
    'id': c.id,
    'name': c.name,
    'sell': c.sell,
    'buy': c.buy,
    'stock': c.stock,
    'alert': c.alert,
  };

  CafeItem cafeItemFromMap(Map<String, dynamic> m) => CafeItem(
    id: m['id'] as String,
    name: m['name'] as String,
    sell: (m['sell'] as num).toDouble(),
    buy: (m['buy'] as num).toDouble(),
    stock: m['stock'] as int,
    alert: m['alert'] as int,
  );

  // Monthly revenue analytics - query invoices from last 30 days
  Stream<List<Invoice>> watchMonthlyRevenue(String storeCode) {
    if (!online) return const Stream.empty();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _invoicesCol(storeCode)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invoice.fromMap(doc.data()))
            .where((invoice) => 
                invoice.createdAt != null && 
                invoice.createdAt!.isAfter(thirtyDaysAgo))
            .toList());
  }

  Future<double> calculateMonthlyRevenue(String storeCode) async {
    if (!online) return 0.0;
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final snapshot = await _invoicesCol(storeCode).get();
      
      final invoices = snapshot.docs
          .map((doc) => Invoice.fromMap(doc.data()))
          .where((invoice) => 
              invoice.createdAt != null && 
              invoice.createdAt!.isAfter(thirtyDaysAgo))
          .toList();
      
      double totalRevenue = 0.0;
      for (final invoice in invoices) {
        totalRevenue += invoice.total;
      }
      return totalRevenue;
    } catch (e) {
      debugPrint('Error calculating monthly revenue: $e');
      return 0.0;
    }
  }
}

// ---------------------------------------------------------------------------
// Store
// ---------------------------------------------------------------------------

class PosStore extends ChangeNotifier {
  PosStore(this._sync) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (devices.any((d) => d.isBusy)) {
        _checkDeviceTimers();
        notifyListeners();
      }
    });
    // Update owner state asynchronously after prefs are available
    _updateOwnerFromPrefs();
  }

  final CloudSync _sync;
  CloudSync get sync => _sync;
  late final Timer _ticker;
  final Set<String> _alarmedDevices = {};
  final Map<String, DateTime> _alarmTimestamps = {}; // Track when alarms were triggered
  StreamSubscription<Map<String, dynamic>?>? _stateSub;
  StreamSubscription<List<LoginAuditEntry>>? _logsSub;
  StreamSubscription<List<Device>>? _devicesSub;
  StreamSubscription<List<Invoice>>? _invoicesSub;
  StreamSubscription<List<CafeItem>>? _inventorySub;
  StreamSubscription<Map<String, dynamic>?>? _settingsSub;
  bool _applyingRemote = false;
  bool _ready = false; // CRITICAL: Made accessible for immediate startup
  
  // CRITICAL: Provide setter for _ready to allow immediate startup
  set ready(bool value) {
    _ready = value;
    notifyListeners();
  }

  String shopName = 'Dos X';
  String currency = 'ج';
  String adminPin = '1234';
  String? storeCode;
  AppTab tab = AppTab.devices;
  UserRole? activeRole;

  bool get isLoggedIn => activeRole != null;
  bool get isAdmin => activeRole == UserRole.admin;
  bool get isStaff => activeRole == UserRole.staff;
  bool get isWorker => activeRole == UserRole.worker;
  bool get isOwner {
    // CRITICAL: Check multiple conditions to ensure Owner always gets full access
    // Priority order: activeRole -> currentUser -> SharedPreferences -> persistent session
    return activeRole == UserRole.admin ||
        currentUser?.isOwner == true ||
        currentUser?.role == 'owner' ||
        currentUser?.role == 'صاحب المحل' ||
        isOwnerFromPrefsSync;
  }

  // Synchronous check for owner status from SharedPreferences for immediate UI updates
  bool isOwnerFromPrefsSync = false;
  Future<void> _updateOwnerFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isOwnerFlag = prefs.getBool('is_owner') ?? false;
    final userRole = prefs.getString('user_role')?.toLowerCase() ?? '';
    final persistentOwnerSession = prefs.getBool('owner_session_persistent') ?? false;
    
    isOwnerFromPrefsSync = isOwnerFlag ||
        userRole == 'owner' ||
        userRole == 'admin' ||
        persistentOwnerSession;
  }
  
  // CRITICAL: Synchronous update of owner state for immediate UI response
  void updateOwnerFromPrefsSync() {
    // This is called immediately after SharedPreferences are set in login methods
    // to ensure UI shows correct tabs without waiting for async update
    isOwnerFromPrefsSync = true; // Owner just logged in, set to true immediately
  }
  bool get canViewRevenue => isAdmin || isOwner;
  bool get canViewReports => isAdmin || isOwner;
  bool get canAccessSettings => isAdmin || isOwner;
  bool get canModifyInventory => isAdmin || isOwner;
  bool get canViewBuyPrices => isAdmin || isOwner;
  bool get canManageExpenses => isAdmin || isOwner;
  bool get canCloseShift => isLoggedIn;

  // Enhanced owner check that also reads SharedPreferences for forced state
  Future<bool> getIsOwnerFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isOwnerFlag = prefs.getBool('is_owner') ?? false;
    final userRole = prefs.getString('user_role') ?? '';
    final persistentOwnerSession = prefs.getBool('owner_session_persistent') ?? false;
    return isOwnerFlag ||
        userRole.toLowerCase() == 'owner' ||
        userRole.toLowerCase() == 'admin' ||
        persistentOwnerSession;
  }

  List<AppTab> get allowedTabs {
    // CRITICAL: FORCE ALL 5 TABS FOR OWNER - Unconditional access
    // Use multiple redundant checks to ensure owner ALWAYS gets full access
    // This is the authoritative source for tab permissions
    if (isOwner || isAdmin || isOwnerFromPrefsSync || activeRole == UserRole.admin) {
      return [
        AppTab.devices,
        AppTab.invoices,
        AppTab.inventory,
        AppTab.reports,
        AppTab.settings,
      ];
    }
    // Other roles get restricted access
    return isWorker
        ? const [AppTab.devices, AppTab.invoices]
        : const [AppTab.devices, AppTab.invoices, AppTab.reports];
  }

  bool get syncOnline => _sync.online;
  bool get ready => _ready;

  Employee? currentUser;
  String? currentWorkerName;
  String? currentDeviceId;
  WorkerSession? currentWorkerSession;
  bool isShiftLocked = false;
  bool hideRevenueFromStaff = true;
  bool staffSeeBuyPrices = false;
  bool allowCancelInvoices = false;
  double maxStaffDiscount = 5;

  // Subscription expiry
  DateTime? expiryDate;

  bool get isSubscriptionExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return 0;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    return difference.inDays;
  }

  bool get isSubscriptionNearExpiry {
    if (expiryDate == null) return false;
    return daysUntilExpiry <= 7 && !isSubscriptionExpired;
  }

  // Match-based billing settings (disabled - UI removed, kept for backward compatibility)
  bool useMatchBilling = false; // Disabled by default
  int matchDurationMinutes = 30;
  double matchPrice = 5.0;
  double defaultMatchSinglePrice = 5.0;
  double defaultMatchMultiPrice = 8.0;

  final List<Device> devices = [];
  final List<CafeItem> cafeItems = [];
  final List<Invoice> invoices = [];
  final List<Expense> expenses = [];
  final List<Employee> employees = [];
  final List<ClosedShift> closedShifts = [];
  final List<LoginAuditEntry> loginLogs = [];

  int get activeCount => devices.where((d) => d.isBusy).length;
  int get sessionsToday => invoices.length + activeCount;
  double get todayRevenue => invoices.fold(0.0, (a, i) => a + i.total);
  double get timeRevenue => invoices.fold(0.0, (a, i) => a + i.timeCost);
  double get cafeRevenue => invoices.fold(0.0, (a, i) => a + i.cafeCost);
  double get discountsTotal => invoices.fold(0.0, (a, i) => a + i.discount);
  double get expensesTotal => expenses.fold(0.0, (a, e) => a + e.amount);
  double get cogs {
    final sold = <String, int>{};
    for (final inv in invoices) {
      for (final line in inv.cafeLines) {
        sold[line.itemId] = (sold[line.itemId] ?? 0) + line.qty;
      }
    }
    var total = 0.0;
    for (final item in cafeItems) {
      total += (sold[item.id] ?? 0) * item.buy;
    }
    return total;
  }

  double get netProfit => todayRevenue - cogs - expensesTotal;

  @override
  void dispose() {
    _ticker.cancel();
    _stateSub?.cancel();
    _logsSub?.cancel();
    _devicesSub?.cancel();
    _invoicesSub?.cancel();
    _inventorySub?.cancel();
    _settingsSub?.cancel();
    _alarmTimestamps.clear();
    super.dispose();
  }

  void _checkDeviceTimers() {
    for (final device in devices) {
      if (device.isBusy && device.session != null) {
        final elapsed = DateTime.now().difference(device.session!.startedAt);

        // Check for custom timer alarm
        if (device.session!.customDurationMinutes != null) {
          final totalSeconds = device.session!.customDurationMinutes! * 60;
          final remaining = totalSeconds - elapsed.inSeconds;

          // Alarm when countdown reaches zero
          if (remaining <= 0 &&
              remaining > -5 &&
              !_alarmedDevices.contains(device.id)) {
            _playAlarmForDevice(device.id);
          }

          // Auto-end session 15 seconds after alarm
          if (_alarmTimestamps.containsKey(device.id)) {
            final alarmTime = _alarmTimestamps[device.id]!;
            final timeSinceAlarm = DateTime.now().difference(alarmTime);
            
            if (timeSinceAlarm.inSeconds >= 15) {
              // Auto-end the session
              _autoEndSession(device);
              _alarmTimestamps.remove(device.id);
              _alarmedDevices.remove(device.id);
            }
          }
        }
      }
    }
  }

  Future<void> _playAlarmForDevice(String deviceId) async {
    if (_alarmedDevices.contains(deviceId)) return;

    _alarmedDevices.add(deviceId);
    _alarmTimestamps[deviceId] = DateTime.now(); // Track alarm time

    try {
      // Play system beep sound
      await SystemSound.play(SystemSoundType.alert);

      // Play multiple beeps for better attention
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        await SystemSound.play(SystemSoundType.alert);
      }

      // Remove from alarmed set after some time to allow re-alarm
      Future.delayed(const Duration(minutes: 5), () {
        _alarmedDevices.remove(deviceId);
        _alarmTimestamps.remove(deviceId);
      });
    } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  void _autoEndSession(Device device) {
    if (!device.isBusy || device.session == null) return;

    // Generate invoice and end session
    final preview = previewCheckout(device);
    final err = confirmCheckout(device, preview);
    
    if (err != null) {
      debugPrint('Auto-end session failed: $err');
    } else {
      debugPrint('Auto-ended session for device: ${device.name}');
    }
  }

  Future<void> initialize() async {
    await _clearLegacySessionData();
    _initCleanLocal();
    
    // CRITICAL: Set ready immediately to prevent app from hanging on loading screen
    // Real-time listeners will be set up after login when storeCode is available
    _ready = true;
    notifyListeners();
    
    // CRITICAL: Don't ensureShopDoc yet - wait until storeCode is set during login
    // _stateSub = _sync.watchState(storeCode).listen(_onRemoteState);
    // _logsSub = _sync.watchLoginLogs(storeCode).listen((logs) {
    //   loginLogs
    //     ..clear()
    //     ..addAll(logs);
    //   notifyListeners();
    // });
    
    // CRITICAL: Don't setup real-time listeners yet - wait until storeCode is set during login
    // _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    // Cancel existing listeners first
    _cancelRealtimeListeners();
    
    // CRITICAL: Only proceed if we're online AND storeCode is properly set and not empty
    // This prevents timing issues where listeners are set up before storeCode is initialized
    if (!_sync.online || storeCode == null || storeCode!.isEmpty) {
      debugPrint('Skipping realtime listener setup: online=${_sync.online}, storeCode=$storeCode');
      return;
    }
    
    // Update sync shopId for streams
    _sync.shopId = storeCode!;
    
    // Listen to device changes in real-time
    // CRITICAL: This fetches ALL devices under stores/{storeCode} regardless of user
    // Ensures cross-account session sync between Owner and Worker
    _devicesSub = _sync.watchDevices(storeCode!).listen((remoteDevices) {
      if (_applyingRemote) return;
      _mergeDevices(remoteDevices);
    });
    
    // Listen to invoice changes in real-time
    // CRITICAL: This fetches ALL invoices under stores/{storeCode} regardless of user
    _invoicesSub = _sync.watchInvoices(storeCode!).listen((remoteInvoices) {
      if (_applyingRemote) return;
      _mergeInvoices(remoteInvoices);
    });
    
    // Listen to inventory changes in real-time
    _inventorySub = _sync.watchInventory(storeCode!).listen((remoteInventory) {
      if (_applyingRemote) return;
      _mergeInventory(remoteInventory);
    });
    
    // Listen to settings changes in real-time
    _settingsSub = _sync.watchSettings(storeCode!).listen((remoteSettings) {
      if (_applyingRemote) return;
      if (remoteSettings != null) {
        _mergeSettings(remoteSettings);
      }
    });
    
    // Also set up state and logs listeners with the correct storeCode
    _stateSub = _sync.watchState(storeCode!).listen(_onRemoteState);
    _logsSub = _sync.watchLoginLogs(storeCode!).listen((logs) {
      loginLogs
        ..clear()
        ..addAll(logs);
      notifyListeners();
    });
  }

  void _cancelRealtimeListeners() {
    _devicesSub?.cancel();
    _invoicesSub?.cancel();
    _inventorySub?.cancel();
    _settingsSub?.cancel();
    _devicesSub = null;
    _invoicesSub = null;
    _inventorySub = null;
    _settingsSub = null;
  }

  void _mergeDevices(List<Device> remoteDevices) {
    // Safe merge: update existing devices, add new ones, remove deleted ones
    // CRITICAL: Always trust Firestore session state for real-time sync across windows
    // This ensures session ending on Worker window immediately updates Owner window to "فاضي"
    final remoteIds = remoteDevices.map((d) => d.id).toSet();
    
    // Update or add devices from remote
    for (final remoteDevice in remoteDevices) {
      final existingIndex = devices.indexWhere((d) => d.id == remoteDevice.id);
      if (existingIndex != -1) {
        // ALWAYS use remote session state for real-time sync across browser windows
        // This ensures session ending on one account immediately reflects on others
        devices[existingIndex] = remoteDevice;
      } else {
        devices.add(remoteDevice);
      }
    }
    
    // Remove devices that no longer exist remotely (only if not busy)
    devices.removeWhere((d) => !remoteIds.contains(d.id) && !d.isBusy);
    
    notifyListeners();
  }

  void _mergeInvoices(List<Invoice> remoteInvoices) {
    // CRITICAL: Always trust Firestore invoice state for real-time sync across windows
    // This ensures invoices created on Worker window immediately appear on Owner window
    final remoteIds = remoteInvoices.map((i) => i.id).toSet();
    
    // Add or update invoices from remote
    for (final remoteInvoice in remoteInvoices) {
      final existingIndex = invoices.indexWhere((i) => i.id == remoteInvoice.id);
      if (existingIndex == -1) {
        invoices.add(remoteInvoice);
      } else {
        // Always update with remote invoice data for real-time sync
        invoices[existingIndex] = remoteInvoice;
      }
    }
    
    // Remove invoices that no longer exist remotely
    invoices.removeWhere((i) => !remoteIds.contains(i.id));
    
    // Sort by date (newest first)
    invoices.sort((a, b) => b.from.compareTo(a.from));
    
    notifyListeners();
  }

  void _mergeInventory(List<CafeItem> remoteInventory) {
    // Safe merge: update existing items, add new ones, remove deleted ones
    final remoteIds = remoteInventory.map((i) => i.id).toSet();
    
    // Update or add items from remote
    for (final remoteItem in remoteInventory) {
      final existingIndex = cafeItems.indexWhere((i) => i.id == remoteItem.id);
      if (existingIndex != -1) {
        cafeItems[existingIndex] = remoteItem;
      } else {
        cafeItems.add(remoteItem);
      }
    }
    
    // Remove items that no longer exist remotely
    cafeItems.removeWhere((i) => !remoteIds.contains(i.id));
    
    notifyListeners();
  }

  void _mergeSettings(Map<String, dynamic> remoteSettings) {
    // Safe merge: update settings from remote
    if (remoteSettings['shopName'] != null) {
      shopName = remoteSettings['shopName'] as String;
    }
    if (remoteSettings['currency'] != null) {
      currency = remoteSettings['currency'] as String;
    }
    if (remoteSettings['hideRevenueFromStaff'] != null) {
      hideRevenueFromStaff = remoteSettings['hideRevenueFromStaff'] as bool;
    }
    if (remoteSettings['staffSeeBuyPrices'] != null) {
      staffSeeBuyPrices = remoteSettings['staffSeeBuyPrices'] as bool;
    }
    if (remoteSettings['allowCancelInvoices'] != null) {
      allowCancelInvoices = remoteSettings['allowCancelInvoices'] as bool;
    }
    if (remoteSettings['maxStaffDiscount'] != null) {
      maxStaffDiscount = (remoteSettings['maxStaffDiscount'] as num).toDouble();
    }
    
    notifyListeners();
  }

  Future<void> _clearLegacySessionData() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear only legacy/conflicting role data that might interfere with proper owner detection
    await prefs.remove('role'); // Legacy role field
    await prefs.remove('isOwner'); // Legacy isOwner field
    // Keep user_role, is_logged_in, store_code, and owner_password as they are needed for auto-login
  }

  void _initCleanLocal() {
    shopName = 'Dos X';
    currency = 'ج';
    adminPin = '1234';
    activeRole = null;
    currentUser = null;
    hideRevenueFromStaff = true;
    staffSeeBuyPrices = false;
    allowCancelInvoices = false;
    maxStaffDiscount = 5;
    
    // Only add default owner if not already present
    if (!employees.any((e) => e.isOwner)) {
      employees.add(
        Employee(
          id: 'owner',
          name: 'صاحب المحل',
          role: 'صاحب المحل',
          code: '12345',
          isOwner: true,
        ),
      );
    }
    
    // Only add default devices if devices list is empty
    if (devices.isEmpty) {
      devices.addAll([
        Device(id: 'd1', name: 'شاشة 1', singleRate: 40, multiRate: 70, matchSingleRate: 10, matchMultiRate: 20),
        Device(id: 'd2', name: 'شاشة 2', singleRate: 40, multiRate: 70, matchSingleRate: 10, matchMultiRate: 20),
        Device(id: 'd3', name: 'شاشة 3', singleRate: 40, multiRate: 70, matchSingleRate: 10, matchMultiRate: 20),
        Device(id: 'd4', name: 'شاشة 4', singleRate: 40, multiRate: 70, matchSingleRate: 10, matchMultiRate: 20),
        Device(id: 'd5', name: 'شاشة 5', singleRate: 50, multiRate: 80, matchSingleRate: 15, matchMultiRate: 25),
        Device(id: 'd6', name: 'شاشة 6', singleRate: 50, multiRate: 80, matchSingleRate: 15, matchMultiRate: 25),
        Device(id: 'd7', name: 'VIP 1', singleRate: 60, multiRate: 90, matchSingleRate: 20, matchMultiRate: 30),
        Device(id: 'd8', name: 'VIP 2', singleRate: 60, multiRate: 90, matchSingleRate: 20, matchMultiRate: 30),
      ]);
    }
  }

  Future<void> _onRemoteState(Map<String, dynamic>? data) async {
    if (data == null) {
      _ready = true;
      notifyListeners();
      return;
    }
    _applyingRemote = true;
    await _fromMap(data);
    _applyingRemote = false;
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_applyingRemote) return;
    notifyListeners();
    // CRITICAL: Only save state if storeCode is set
    if (storeCode != null && storeCode!.isNotEmpty) {
      await _sync.saveState(storeCode!, _toMap());
    }
  }

  Map<String, dynamic> _toMap() => {
    'shopName': shopName,
    'currency': currency,
    'adminPin': adminPin,
    'hideRevenueFromStaff': hideRevenueFromStaff,
    'staffSeeBuyPrices': staffSeeBuyPrices,
    'allowCancelInvoices': allowCancelInvoices,
    'maxStaffDiscount': maxStaffDiscount,
    'devices': devices.map(_deviceToMap).toList(),
    'cafeItems': cafeItems.map(_cafeToMap).toList(),
    'invoices': invoices.map(_invoiceToMap).toList(),
    'expenses': expenses.map(_expenseToMap).toList(),
    'employees': employees.map(_employeeToMap).toList(),
    'closedShifts': closedShifts.map((s) => s.toMap()).toList(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  Future<void> _fromMap(Map<String, dynamic> m) async {
    shopName = m['shopName'] as String? ?? shopName;
    currency = m['currency'] as String? ?? currency;
    adminPin = m['adminPin'] as String? ?? adminPin;
    hideRevenueFromStaff =
        m['hideRevenueFromStaff'] as bool? ?? hideRevenueFromStaff;
    staffSeeBuyPrices = m['staffSeeBuyPrices'] as bool? ?? staffSeeBuyPrices;
    allowCancelInvoices =
        m['allowCancelInvoices'] as bool? ?? allowCancelInvoices;
    maxStaffDiscount =
        (m['maxStaffDiscount'] as num?)?.toDouble() ?? maxStaffDiscount;
    devices
      ..clear()
      ..addAll(
        ((m['devices'] as List?) ?? []).map(
          (e) => _deviceFromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    cafeItems
      ..clear()
      ..addAll(
        ((m['cafeItems'] as List?) ?? []).map(
          (e) => _cafeFromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    invoices
      ..clear()
      ..addAll(
        ((m['invoices'] as List?) ?? []).map(
          (e) => _invoiceFromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    expenses
      ..clear()
      ..addAll(
        ((m['expenses'] as List?) ?? []).map(
          (e) => _expenseFromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    employees
      ..clear()
      ..addAll(
        ((m['employees'] as List?) ?? []).map(
          (e) => _employeeFromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    closedShifts
      ..clear()
      ..addAll(
        ((m['closedShifts'] as List?) ?? []).map(
          (e) => ClosedShift.fromMap(Map<String, dynamic>.from(e as Map)),
        ),
      );
    if (currentUser != null) {
      final match = employees.where((e) => e.id == currentUser!.id);
      if (match.isNotEmpty) {
        // Preserve owner status when syncing from Firestore by checking SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final isOwnerSession = prefs.getBool('is_owner') ?? false;
        final userRole = prefs.getString('user_role') ?? '';

        if (isOwnerSession ||
            userRole.toLowerCase() == 'owner' ||
            userRole.toLowerCase() == 'admin') {
          currentUser = match.first;
          if (!currentUser!.isOwner) {
            currentUser = Employee(
              id: currentUser!.id,
              name: currentUser!.name,
              role: currentUser!.role,
              code: currentUser!.code,
              isOwner: true,
            );
          }
        } else {
          currentUser = match.first;
        }
      }
    }
  }

  Map<String, dynamic> _deviceToMap(Device d) => {
    'id': d.id,
    'name': d.name,
    'singleRate': d.singleRate,
    'multiRate': d.multiRate,
    'matchSingleRate': d.matchSingleRate,
    'matchMultiRate': d.matchMultiRate,
    'preferredMode': d.preferredMode.name,
    'session': d.session == null ? null : _sessionToMap(d.session!),
  };

  Device _deviceFromMap(Map<String, dynamic> m) {
    final d = Device(
      id: m['id'] as String,
      name: m['name'] as String,
      singleRate: (m['singleRate'] as num).toDouble(),
      multiRate: (m['multiRate'] as num).toDouble(),
      matchSingleRate: (m['matchSingleRate'] as num?)?.toDouble() ?? 5.0,
      matchMultiRate: (m['matchMultiRate'] as num?)?.toDouble() ?? 8.0,
      preferredMode: m['preferredMode'] == 'multi'
          ? PlayMode.multi
          : PlayMode.single,
    );
    final s = m['session'];
    if (s != null) {
      d.session = _sessionFromMap(Map<String, dynamic>.from(s as Map));
    }
    return d;
  }

  Map<String, dynamic> _sessionToMap(Session s) => {
    'startedAt': s.startedAt.toIso8601String(),
    'mode': s.mode.name,
    'customer': s.customer,
    'customDurationMinutes': s.customDurationMinutes,
    'numberOfMatches': s.numberOfMatches,
    'orders': s.orders.map(_orderToMap).toList(),
  };

  Session _sessionFromMap(Map<String, dynamic> m) => Session(
    startedAt: DateTime.parse(m['startedAt'] as String),
    mode: m['mode'] == 'multi' ? PlayMode.multi : PlayMode.single,
    customer: m['customer'] as String? ?? 'زبون',
    customDurationMinutes: m['customDurationMinutes'] as int?,
    numberOfMatches: m['numberOfMatches'] as int? ?? 1,
    orders: ((m['orders'] as List?) ?? [])
        .map((e) => _orderFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );

  Map<String, dynamic> _orderToMap(OrderLine o) => {
    'itemId': o.itemId,
    'name': o.name,
    'unitPrice': o.unitPrice,
    'qty': o.qty,
  };

  OrderLine _orderFromMap(Map<String, dynamic> m) => OrderLine(
    itemId: m['itemId'] as String,
    name: m['name'] as String,
    unitPrice: (m['unitPrice'] as num).toDouble(),
    qty: m['qty'] as int,
  );

  Map<String, dynamic> _cafeToMap(CafeItem c) => {
    'id': c.id,
    'name': c.name,
    'sell': c.sell,
    'buy': c.buy,
    'stock': c.stock,
    'alert': c.alert,
  };

  CafeItem _cafeFromMap(Map<String, dynamic> m) => CafeItem(
    id: m['id'] as String,
    name: m['name'] as String,
    sell: (m['sell'] as num).toDouble(),
    buy: (m['buy'] as num).toDouble(),
    stock: m['stock'] as int,
    alert: m['alert'] as int,
  );

  Map<String, dynamic> _invoiceToMap(Invoice i) => {
    'id': i.id,
    'deviceName': i.deviceName,
    'customer': i.customer,
    'from': i.from.toIso8601String(),
    'to': i.to.toIso8601String(),
    'billedMinutes': i.billedMinutes,
    'timeCost': i.timeCost,
    'cafeCost': i.cafeCost,
    'discount': i.discount,
    'total': i.total,
    'staffName': i.staffName,
    'mode': i.mode.name,
    'cafeLines': i.cafeLines.map(_orderToMap).toList(),
    'createdBy': i.createdBy, // CRITICAL: Include createdBy field
  };

  Invoice _invoiceFromMap(Map<String, dynamic> m) => Invoice(
    id: m['id'] as String,
    deviceName: m['deviceName'] as String,
    customer: m['customer'] as String,
    from: DateTime.parse(m['from'] as String),
    to: DateTime.parse(m['to'] as String),
    billedMinutes: m['billedMinutes'] as int,
    timeCost: (m['timeCost'] as num).toDouble(),
    cafeCost: (m['cafeCost'] as num).toDouble(),
    discount: (m['discount'] as num).toDouble(),
    total: (m['total'] as num).toDouble(),
    staffName: m['staffName'] as String,
    mode: m['mode'] == 'multi' ? PlayMode.multi : PlayMode.single,
    cafeLines: ((m['cafeLines'] as List?) ?? [])
        .map((e) => _orderFromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    createdBy: m['createdBy'] as String?, // CRITICAL: Read createdBy field
  );

  Map<String, dynamic> _expenseToMap(Expense e) => {
    'id': e.id,
    'title': e.title,
    'amount': e.amount,
    'at': e.at.toIso8601String(),
  };

  Expense _expenseFromMap(Map<String, dynamic> m) => Expense(
    id: m['id'] as String,
    title: m['title'] as String,
    amount: (m['amount'] as num).toDouble(),
    at: DateTime.parse(m['at'] as String),
  );

  Map<String, dynamic> _employeeToMap(Employee e) => {
    'id': e.id,
    'name': e.name,
    'role': e.role,
    'code': e.code,
    'isOwner': e.isOwner,
  };

  Employee _employeeFromMap(Map<String, dynamic> m) => Employee(
    id: m['id'] as String,
    name: m['name'] as String,
    role: m['role'] as String,
    code: m['code'] as String,
    isOwner: m['isOwner'] as bool? ?? false,
  );

  Future<void> _logShift(ShiftEvent event) async {
    // CRITICAL: Only log shift events for workers, not for owners/staff
    // Owners and staff are not workers and don't have shifts
    if (currentWorkerName == null) return;
    
    final entry = LoginAuditEntry(
      id: newId('log_'),
      employeeName: currentWorkerName!,
      role: 'عامل',
      at: DateTime.now(),
      event: event,
      isOwner: false,
    );
    loginLogs.insert(0, entry);
    // CRITICAL: Only log if storeCode is set
    if (storeCode != null && storeCode!.isNotEmpty) {
      await _sync.appendLoginLog(storeCode!, entry);
    }
    notifyListeners();
  }

  void setTab(AppTab value) {
    // Allow unrestricted tab switching for all users
    // Tab visibility is handled by the UI (TabStrip component)
    tab = value;
    _persist();
    notifyListeners();
  }

  void setShop({String? name, String? currencySymbol}) {
    if (name != null) shopName = name;
    if (currencySymbol != null) currency = currencySymbol;
    _persist();
    
    // Sync settings to Firestore immediately
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      _sync.saveSettings(storeCode!, {
        'shopName': shopName,
        'currency': currency,
      });
    }
  }

  void setPreferredMode(Device device, PlayMode mode) {
    device.preferredMode = mode;
    _persist();
  }

  void startSession(
    Device device, {
    required String customer,
    required PlayMode mode,
    int? customDurationMinutes,
    int numberOfMatches = 1,
  }) {
    if (device.isBusy) return;
    device.session = Session(
      startedAt: DateTime.now(),
      mode: mode,
      customer: customer.trim().isEmpty ? 'زبون' : customer.trim(),
      customDurationMinutes: customDurationMinutes,
      numberOfMatches: numberOfMatches,
    );
    device.preferredMode = mode;
    _persist();
    
    // CRITICAL: Save device state to Firestore for store-wide real-time sync
    // This ensures session starting on one account immediately shows on other accounts
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.saveDevice(device, storeCode!);
    }
    
    // CRITICAL: Force immediate UI update for cross-account sync
    notifyListeners();
  }

  String? applyCafeOrder(Device device, Map<String, int> quantities) {
    final session = device.session;
    if (session == null) return 'الجهاز غير شغّال';
    for (final entry in quantities.entries) {
      if (entry.value <= 0) continue;
      final item = cafeItems.firstWhere((c) => c.id == entry.key);
      if (item.stock < entry.value) {
        return 'المخزون غير كافٍ للصنف ${item.name}';
      }
    }
    for (final entry in quantities.entries) {
      if (entry.value <= 0) continue;
      final item = cafeItems.firstWhere((c) => c.id == entry.key);
      item.stock -= entry.value;
      final existing = session.orders.where((o) => o.itemId == item.id);
      if (existing.isNotEmpty) {
        existing.first.qty += entry.value;
      } else {
        session.orders.add(
          OrderLine(
            itemId: item.id,
            name: item.name,
            unitPrice: item.sell,
            qty: entry.value,
          ),
        );
      }
    }
    _persist();
    
    // CRITICAL: Sync device state with updated session orders to Firestore for cross-account sync
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.saveDevice(device, storeCode!);
    }
    
    // CRITICAL: Force immediate UI update for cross-account sync
    notifyListeners();
    
    return null;
  }

  Invoice previewCheckout(
    Device device, {
    DateTime? endedAt,
    double discount = 0,
  }) {
    final session = device.session!;
    final end = endedAt ?? DateTime.now();
    final elapsed = end.difference(session.startedAt);

    double time;
    int minutes;

    if (session.mode == PlayMode.matchSingle ||
        session.mode == PlayMode.matchMulti) {
      // Match mode: charge based on number of matches
      minutes = (elapsed.inSeconds / 60).ceil();
      final ratePerMatch = session.mode == PlayMode.matchSingle
          ? device.matchSingleRate
          : device.matchMultiRate;
      time = ratePerMatch * session.numberOfMatches;
    } else {
      minutes = billedMinutes(elapsed);
      final rate = device.rateFor(session.mode);
      time = minutes / 60.0 * rate;
    }

    final cafe = session.cafeTotal;
    final disc = discount.clamp(0, time + cafe).toDouble();
    
    // CRITICAL: Capture the actual user who is ending the session
    // This ensures accurate attribution regardless of who started the session
    final actualUserName = currentUser?.name ?? currentWorkerName ?? 'صاحب المحل';
    
    return Invoice(
      id: 'preview',
      deviceName: device.name,
      customer: session.customer,
      from: session.startedAt,
      to: end,
      billedMinutes: minutes,
      timeCost: time,
      cafeCost: cafe,
      discount: disc,
      total: time + cafe - disc,
      staffName: actualUserName,
      mode: session.mode,
      cafeLines: List.of(session.orders),
      createdBy: actualUserName, // CRITICAL: Include createdBy for consistency
    );
  }

  String? confirmCheckout(Device device, Invoice preview) {
    if (isStaff && preview.discount > maxStaffDiscount) {
      return 'أقصى خصم للموظف $maxStaffDiscount $currency';
    }
    
    // CRITICAL: Capture the actual user who is ending the session
    // This ensures accurate attribution regardless of who started the session
    final actualUserName = currentUser?.name ?? currentWorkerName ?? 'صاحب المحل';
    
    final invoice = Invoice(
      id: 'i${DateTime.now().millisecondsSinceEpoch}',
      deviceName: preview.deviceName,
      customer: preview.customer,
      from: preview.from,
      to: preview.to,
      billedMinutes: preview.billedMinutes,
      timeCost: preview.timeCost,
      cafeCost: preview.cafeCost,
      discount: preview.discount,
      total: preview.total,
      staffName: actualUserName, // Use actual user who ended the session
      mode: preview.mode,
      cafeLines: preview.cafeLines,
      createdAt: null, // Will be set by server timestamp in Firestore
      createdBy: actualUserName, // CRITICAL: Explicit user attribution for Worker/Owner sync
    );
    
    invoices.insert(0, invoice);
    device.session = null; // CRITICAL: Clear session to make device "فاضي" (idle)
    _persist();
    
    // CRITICAL: Save to Firestore for store-wide real-time sync across all accounts
    // This ensures session ending on Worker window immediately updates Owner window
    // and vice versa. All invoices are stored under stores/{storeCode} regardless of user.
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.saveInvoice(invoice, storeCode!);
      _sync.saveDevice(device, storeCode!); // Sync device state (session null = idle)
    }
    
    // CRITICAL: Force immediate UI update for cross-account sync
    notifyListeners();
    
    return null;
  }

  Invoice previewManualBill({
    required double amount,
    required String description,
    List<OrderLine>? orders,
  }) {
    final actualUserName = currentUser?.name ?? currentWorkerName ?? 'صاحب المحل';
    
    final cafeTotal = orders?.fold<double>(0.0, (a, o) => a + (o.lineTotal ?? 0.0)) ?? 0.0;
    
    return Invoice(
      id: 'preview',
      deviceName: description, // Use description as device name
      customer: 'فاتورة يدوية',
      from: DateTime.now(),
      to: DateTime.now(),
      billedMinutes: 0,
      timeCost: amount,
      cafeCost: cafeTotal,
      discount: 0,
      total: amount + cafeTotal,
      staffName: actualUserName,
      mode: PlayMode.single,
      cafeLines: orders ?? [],
      createdBy: actualUserName,
    );
  }

  String? confirmManualBill(Invoice preview) {
    final actualUserName = currentUser?.name ?? currentWorkerName ?? 'صاحب المحل';
    
    // Update inventory for cafe items
    for (final line in preview.cafeLines) {
      final item = cafeItems.firstWhere((c) => c.id == line.itemId);
      if (item.stock >= line.qty) {
        item.stock -= line.qty;
      } else {
        return 'المخزون غير كافٍ للصنف ${item.name}';
      }
    }
    
    final invoice = Invoice(
      id: 'i${DateTime.now().millisecondsSinceEpoch}',
      deviceName: preview.deviceName,
      customer: preview.customer,
      from: preview.from,
      to: preview.to,
      billedMinutes: preview.billedMinutes,
      timeCost: preview.timeCost,
      cafeCost: preview.cafeCost,
      discount: preview.discount,
      total: preview.total,
      staffName: actualUserName,
      mode: preview.mode,
      cafeLines: preview.cafeLines,
      createdAt: null,
      createdBy: actualUserName,
    );
    
    invoices.add(invoice);
    _persist();
    
    // Sync inventory to Firestore
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      _sync.shopId = storeCode!;
      _sync.saveInventory(storeCode!, cafeItems);
      _sync.saveInvoice(invoice, storeCode!);
    }
    
    notifyListeners();
    return null;
  }

  String? transferSession(Device sourceDevice, Device targetDevice) {
    if (targetDevice.isBusy) {
      return 'الجهاز المستهدف مشغول حالياً';
    }

    if (sourceDevice.session == null) {
      return 'الجهاز المصدر لا يحتوي على جلسة نشطة';
    }

    // Transfer the session to the target device
    final session = sourceDevice.session;
    targetDevice.session = session;
    
    // Clear session from source device
    sourceDevice.session = null;
    
    _persist();
    
    // Sync both devices to Firestore
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      _sync.shopId = storeCode!;
      _sync.saveDevice(sourceDevice, storeCode!);
      _sync.saveDevice(targetDevice, storeCode!);
    }
    
    notifyListeners();
    return null;
  }

  Future<String?> closeShift() async {
    if (devices.any((d) => d.isBusy)) {
      return 'لا يمكن تقفيل اليوم وهناك أجهزة شغّالة';
    }

    if (isWorker) {
      await lockWorkerShift();
      // CRITICAL: Immediately log out worker after shift completion
      await logout();
      await _persist();
      return null;
    }

    closedShifts.insert(
      0,
      ClosedShift(
        at: DateTime.now(),
        invoices: invoices.length,
        timeRevenue: timeRevenue,
        cafeRevenue: cafeRevenue,
        discounts: discountsTotal,
        collected: todayRevenue,
        expenses: expensesTotal,
        net: netProfit,
      ),
    );
    // CRITICAL: Owner close day should NOT be logged as shift end - owner is not a worker
    // await _logShift(ShiftEvent.shiftEnd); // REMOVED - Owner close day is not a shift end
    invoices.clear();
    expenses.clear();
    await logout();
    await _persist();
    return null;
  }

  void addDevice(
    String name,
    double singleRate,
    double multiRate, {
    double? matchSingle,
    double? matchMulti,
  }) {
    final device = Device(
      id: 'd${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      singleRate: singleRate,
      multiRate: multiRate,
      matchSingleRate: matchSingle ?? 5.0,
      matchMultiRate: matchMulti ?? 8.0,
    );
    devices.add(device);
    _persist();
    
    // Sync to Firestore immediately
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.saveDevice(device, storeCode!);
    }
  }

  void updateDevice(
    Device device, {
    String? name,
    double? single,
    double? multi,
    double? matchSingle,
    double? matchMulti,
  }) {
    if (name != null) device.name = name;
    if (single != null) device.singleRate = single;
    if (multi != null) device.multiRate = multi;
    if (matchSingle != null) device.matchSingleRate = matchSingle;
    if (matchMulti != null) device.matchMultiRate = matchMulti;
    _persist();
    
    // Sync device changes to Firestore immediately
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.saveDevice(device, storeCode!);
    }
  }

  String? removeDevice(Device device) {
    if (device.isBusy) return 'أوقف الجلسة أولاً';
    devices.remove(device);
    _persist();
    
    // Sync to Firestore immediately
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before writing
      _sync.shopId = storeCode!;
      _sync.deleteDevice(device.id, storeCode!);
    }
    return null;
  }

  void addCafeItem(CafeItem item) {
    cafeItems.add(item);
    _persist();
    if (storeCode != null && storeCode!.isNotEmpty) {
      _sync.saveInventory(storeCode!, cafeItems);
    }
  }

  void updateCafeItem(CafeItem item) {
    _persist();
    if (storeCode != null && storeCode!.isNotEmpty) {
      _sync.saveInventory(storeCode!, cafeItems);
    }
  }

  void removeCafeItem(CafeItem item) {
    cafeItems.remove(item);
    _persist();
    if (storeCode != null && storeCode!.isNotEmpty) {
      _sync.saveInventory(storeCode!, cafeItems);
    }
  }

  void addExpense(String title, double amount) {
    expenses.insert(
      0,
      Expense(
        id: 'x${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        amount: amount,
        at: DateTime.now(),
      ),
    );
    _persist();
  }

  void removeExpense(Expense expense) {
    expenses.remove(expense);
    _persist();
  }

  void addEmployee(Employee employee) {
    employees.add(employee);
    _persist();
    if (storeCode != null && storeCode!.isNotEmpty) {
      _sync.saveEmployee(storeCode!, employee);
    }
  }

  void updateEmployee(Employee employee) {
    final index = employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      employees[index] = employee;
      _persist();
      if (storeCode != null && storeCode!.isNotEmpty) {
        _sync.saveEmployee(storeCode!, employee);
      }
    }
  }

  String? removeEmployee(Employee employee) {
    if (employee.isOwner) return 'لا يمكن حذف صاحب المحل';
    employees.remove(employee);
    _persist();
    if (storeCode != null && storeCode!.isNotEmpty) {
      _sync.deleteEmployee(storeCode!, employee.id);
    }
    return null;
  }

  Future<bool> hasOwnerPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('owner_password');
  }

  Future<bool> hasStoreCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('store_code');
  }

  Future<void> setOwnerPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('owner_password', password);
    adminPin = password;
    await _persist();
  }

  Future<void> setStoreCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_code', code);
    storeCode = code;
    _sync.shopId = code;
    await _persist();
    // Re-setup real-time listeners with new store code
    _setupRealtimeListeners();
  }

  Future<bool> isOwnerSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTime = prefs.getInt('owner_last_login');
    if (lastLoginTime == null) return false;

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
    final now = DateTime.now();

    // Check if session is still valid (same day)
    return lastLogin.year == now.year &&
        lastLogin.month == now.month &&
        lastLogin.day == now.day;
  }

  Future<void> saveOwnerSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'owner_last_login',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clearOwnerSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('owner_last_login');
  }

  Future<void> clearAllOwnerData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('owner_last_login');
    await prefs.remove('owner_password');
    await prefs.remove('store_code');
    await prefs.clear(); // Clear all session data
  }

  Future<bool> validateAndSetupStore(
    String storeCode,
    String password, {
    String? securityQuestion,
    String? securityAnswer,
  }) async {
    // Check if store code already exists
    final codeExists = await _sync.checkStoreCodeExists(storeCode);
    if (codeExists) return false;

    // Create store auth in Firestore
    final storeAuth = StoreAuth(
      storeCode: storeCode,
      ownerPassword: password,
      createdAt: DateTime.now(),
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
    );
    await _sync.createStoreAuth(storeAuth);

    // Save locally
    await setStoreCode(storeCode);
    await setOwnerPassword(password);
    await saveOwnerSession();

    return true;
  }

  Future<bool> resetPassword(String storeCode, String newPassword) async {
    final success = await _sync.updateStorePassword(storeCode, newPassword);
    if (success) {
      await setOwnerPassword(newPassword);
      adminPin = newPassword;
    }
    return success;
  }

  Future<bool> verifySecurityAnswer(String storeCode, String answer) async {
    return await _sync.verifySecurityAnswer(storeCode, answer);
  }

  Future<bool> validateStoreCredentials(
    String storeCode,
    String password,
  ) async {
    // CRITICAL: Enable Firebase sync before validation to check store codes
    _sync.online = true;
    
    final storeAuth = await _sync.getStoreAuth(storeCode);
    if (storeAuth == null) return false;

    return storeAuth.ownerPassword == password;
  }

  Future<bool> checkStoreCodeExists(String storeCode) async {
    return await _sync.checkStoreCodeExists(storeCode);
  }

  Future<StoreAuth?> getStoreAuth(String storeCode) async {
    // CRITICAL: Enable Firebase sync before validation to check store codes
    _sync.online = true;
    
    return await _sync.getStoreAuth(storeCode);
  }

  Future<void> _loadFromFirestore() async {
    if (storeCode == null || storeCode!.isEmpty) return;

    try {
      // Cancel existing real-time listeners before loading
      _cancelRealtimeListeners();
      
      // Set applying flag to prevent real-time listeners from interfering
      _applyingRemote = true;

      // Load devices from Firestore - use merge instead of clear
      final devicesDoc = await _sync.firestore
          .collection('stores')
          .doc(storeCode!)
          .collection('devices')
          .get();
      
      // If no devices exist in Firestore and local is empty, add default devices
      if (devicesDoc.docs.isEmpty && devices.isEmpty) {
        devices.addAll([
          Device(id: 'd1', name: 'الجهاز 1', singleRate: 40, multiRate: 70),
          Device(id: 'd2', name: 'الجهاز 2', singleRate: 40, multiRate: 70),
          Device(id: 'd3', name: 'الجهاز 3', singleRate: 40, multiRate: 70),
          Device(id: 'd4', name: 'الجهاز 4', singleRate: 40, multiRate: 70),
          Device(id: 'd5', name: 'الجهاز 5', singleRate: 50, multiRate: 80),
          Device(id: 'd6', name: 'الجهاز 6', singleRate: 50, multiRate: 80),
          Device(id: 'd7', name: 'VIP 1', singleRate: 60, multiRate: 90),
          Device(id: 'd8', name: 'VIP 2', singleRate: 60, multiRate: 90),
        ]);
      } else if (devicesDoc.docs.isNotEmpty) {
        // Merge devices instead of clearing - preserve local devices
        final remoteDevices = devicesDoc.docs.map((doc) {
          final data = doc.data();
          final device = Device(
            id: doc.id,
            name: data['name'] as String,
            singleRate: (data['singleRate'] as num).toDouble(),
            multiRate: (data['multiRate'] as num).toDouble(),
            matchSingleRate:
                (data['matchSingleRate'] as num?)?.toDouble() ?? 5.0,
            matchMultiRate:
                (data['matchMultiRate'] as num?)?.toDouble() ?? 8.0,
          );
          
          // Handle session data if present
          if (data['session'] != null && data['isBusy'] == true) {
            final sessionData = data['session'] as Map<String, dynamic>;
            device.session = Session.fromMap(sessionData);
          }
          
          return device;
        }).toList();
        
        _mergeDevices(remoteDevices);
      }

      // Load employees from new Firestore collection
      final loadedEmployees = await _sync.loadEmployees(storeCode!);
      if (loadedEmployees.isNotEmpty) {
        // CRITICAL: Preserve owner profile if it exists in current user
        final currentOwnerProfile = currentUser?.isOwner == true ? currentUser : null;
        
        // Merge employees instead of clearing
        final remoteIds = loadedEmployees.map((e) => e.id).toSet();
        for (final employee in loadedEmployees) {
          final existingIndex = employees.indexWhere((e) => e.id == employee.id);
          if (existingIndex != -1) {
            // Don't override owner profile with worker data
            if (currentOwnerProfile != null && employee.id == currentOwnerProfile.id) {
              employees[existingIndex] = currentOwnerProfile;
            } else {
              employees[existingIndex] = employee;
            }
          } else {
            employees.add(employee);
          }
        }
        // Remove employees that no longer exist remotely, but preserve owner
        employees.removeWhere((e) => !remoteIds.contains(e.id) && (currentOwnerProfile == null || e.id != currentOwnerProfile.id));
        
        // Ensure owner profile is in employees list
        if (currentOwnerProfile != null) {
          final ownerIndex = employees.indexWhere((e) => e.id == currentOwnerProfile.id);
          if (ownerIndex == -1) {
            employees.add(currentOwnerProfile);
          } else {
            employees[ownerIndex] = currentOwnerProfile;
          }
        }
      }

      // Load inventory from new Firestore collection
      final loadedInventory = await _sync.loadInventory(storeCode!);
      if (loadedInventory.isNotEmpty) {
        _mergeInventory(loadedInventory);
      }

      // Load cafe items from old collection for backward compatibility
      final cafeDoc = await _sync.firestore
          .collection('stores')
          .doc(storeCode!)
          .collection('cafe')
          .get();
      if (cafeDoc.docs.isNotEmpty && cafeItems.isEmpty) {
        final legacyInventory = cafeDoc.docs.map((doc) {
          final data = doc.data();
          return CafeItem(
            id: doc.id,
            name: data['name'] as String,
            sell: (data['sell'] as num).toDouble(),
            buy: (data['buy'] as num).toDouble(),
            stock: data['stock'] as int,
            alert: data['alert'] as int,
          );
        }).toList();
        _mergeInventory(legacyInventory);
      }

      // Load invoices - always merge for real-time sync
      final invoicesDoc = await _sync.firestore
          .collection('stores')
          .doc(storeCode!)
          .collection('invoices')
          .get();
      
      final remoteInvoices = invoicesDoc.docs
          .map((doc) => Invoice.fromMap(doc.data()))
          .toList();
      _mergeInvoices(remoteInvoices);

      // Load settings
      final settingsDoc = await _sync.firestore
          .collection('stores')
          .doc(storeCode!)
          .get();
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        if (data['shopName'] != null) {
          shopName = data['shopName'] as String;
        }
        if (data['currency'] != null) {
          currency = data['currency'] as String;
        }
        if (data['hideRevenueFromStaff'] != null) {
          hideRevenueFromStaff = data['hideRevenueFromStaff'] as bool;
        }
        if (data['staffSeeBuyPrices'] != null) {
          staffSeeBuyPrices = data['staffSeeBuyPrices'] as bool;
        }
        if (data['allowCancelInvoices'] != null) {
          allowCancelInvoices = data['allowCancelInvoices'] as bool;
        }
        if (data['maxStaffDiscount'] != null) {
          maxStaffDiscount = (data['maxStaffDiscount'] as num).toDouble();
        }
      }

      // Load expiry date from storeAuth
      final storeAuth = await getStoreAuth(storeCode!);
      if (storeAuth != null && storeAuth.expiryDate != null) {
        expiryDate = storeAuth.expiryDate;
      }

      // Clear applying flag to allow real-time listeners to process updates
      _applyingRemote = false;
      
      // Re-setup real-time listeners after data load
      _setupRealtimeListeners();
      
      // CRITICAL: Ensure owner state is preserved after Firestore load
      await _ensureOwnerState();
      
      notifyListeners();
    } catch (e) {
      _applyingRemote = false;
      debugPrint('Error loading from Firestore: $e');
    }
  }

  Future<bool> loginAsAdmin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('owner_password');

    if (savedPassword != null) {
      if (pin != savedPassword) return false;
      adminPin = savedPassword;
    } else {
      if (pin != adminPin) return false;
    }

    // FORCE OWNER ROLE OVERRIDE IMMEDIATELY UPON PIN VERIFICATION
    // HARDCODE owner state in SharedPreferences BEFORE any other operations
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'owner'); // HARDCODE role as 'owner'
    await prefs.setBool('is_owner', true); // HARDCODE isOwner as true
    await prefs.setBool('is_worker', false); // HARDCODE isWorker as false
    await prefs.setBool('owner_session_persistent', true); // Set owner session flag
    await prefs.remove('role'); // Clear any legacy role field
    await prefs.remove('isOwner'); // Clear any legacy isOwner field
    await prefs.remove('isWorker'); // Clear any legacy isWorker field
    await prefs.remove('worker_name'); // Clear any worker session data

    // CRITICAL: Synchronous update for immediate UI response
    updateOwnerFromPrefsSync();

    // FORCE OWNER STATE IN APP STATE BEFORE LOADING FROM FIRESTORE
    activeRole = UserRole.admin;
    
    // CRITICAL: Force immediate UI update to ensure tabs show correctly
    notifyListeners();
    
    // Create dedicated owner profile - separate from employee list to prevent override
    final ownerProfile = Employee(
      id: 'owner',
      name: 'صاحب المحل',
      role: 'owner',
      code: adminPin,
      isOwner: true,
    );
    currentUser = ownerProfile;

    // CRITICAL: Enable Firebase sync after successful login
    _sync.online = true;

    // Check subscription expiry if store code exists
    if (storeCode != null && storeCode!.isNotEmpty) {
      // CRITICAL: Update sync shopId BEFORE loading from Firestore for correct real-time paths
      _sync.shopId = storeCode!;
      
      final storeAuth = await getStoreAuth(storeCode!);
      if (storeAuth != null && storeAuth.expiryDate != null) {
        expiryDate = storeAuth.expiryDate;
        if (DateTime.now().isAfter(storeAuth.expiryDate!)) {
          return false; // Login failed due to expired subscription
        }
      }

      // Load shop data from Firestore (owner state is already set above)
      await _loadFromFirestore();

      // CRITICAL: Re-assert owner state after Firestore load to prevent override
      // This ensures that even if Firestore contains worker profiles, currentUser remains owner
      if (activeRole == UserRole.admin) {
        currentUser = ownerProfile;
        
        // Ensure owner is in employees list for consistency, but don't let it override currentUser
        final ownerInEmployees = employees.indexWhere((e) => e.isOwner || e.role == 'owner');
        if (ownerInEmployees == -1) {
          employees.add(ownerProfile);
        } else {
          employees[ownerInEmployees] = ownerProfile;
        }
      }
      
      // CRITICAL: Force immediate real-time listener setup for store-wide sync
      // This ensures owner can see sessions started by worker and vice versa
      // CRITICAL: Ensure storeCode is properly set before setting up listeners
      if (storeCode != null && storeCode!.isNotEmpty) {
        // CRITICAL: Ensure CloudSync shopId matches current storeCode before setting up listeners
        _sync.shopId = storeCode!;
        _setupRealtimeListeners();
      }
    }
    tab = AppTab.devices;

    // Save store code if available
    if (storeCode != null) {
      await prefs.setString('store_code', storeCode!);
    }

    await saveOwnerSession();
    // CRITICAL: Owner login should NOT be logged as shift start - owner is not a worker
    // await _logShift(ShiftEvent.login); // REMOVED - Owner login is not a shift

    // FORCE STATE NOTIFICATION BEFORE NAVIGATION
    notifyListeners();

    return true;
  }

  Future<bool> loginAsWorker(String workerName, String storeCodeInput) async {
    // CRITICAL: Enable Firebase sync after successful login
    _sync.online = true;

    // Validate store code
    final storeAuth = await _sync.getStoreAuth(storeCodeInput);
    if (storeAuth == null) return false;

    // Check subscription expiry
    if (storeAuth.expiryDate != null &&
        DateTime.now().isAfter(storeAuth.expiryDate!)) {
      expiryDate = storeAuth.expiryDate;
      return false; // Login failed due to expired subscription
    }

    // Set expiry date if available
    if (storeAuth.expiryDate != null) {
      expiryDate = storeAuth.expiryDate;
    }

    // CRITICAL: Set local storeCode BEFORE loading from Firestore for correct real-time paths
    storeCode = storeCodeInput;
    
    // CRITICAL: Update sync shopId BEFORE any Firestore operations to ensure correct paths
    _sync.updateShopId(storeCodeInput);
    
    // Load shop data from Firestore to get employee information
    final freshEmployees = await _sync.loadEmployeesForStore(storeCodeInput);
    
    // Update local employees with fresh data
    employees.clear();
    employees.addAll(freshEmployees);

    // Find the employee by name to determine their role
    // Ignore case and role formatting - allow any role (worker, staff, موظف) to authenticate
    final employee = employees.firstWhere(
      (e) => e.name.toLowerCase().trim() == workerName.toLowerCase().trim(),
      orElse: () => Employee(id: '', name: '', role: '', code: ''),
    );

    if (employee.id.isEmpty) {
      debugPrint('Employee not found: $workerName');
      return false;
    }

    // CRITICAL: Set SharedPreferences IMMEDIATELY to prevent role conflicts before any operations
    final prefs = await SharedPreferences.getInstance();
    
    // FORCE WORKER ROLE - Clear any existing owner session state to prevent role inversion
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'worker'); // HARDCODE role as 'worker'
    await prefs.setBool('is_owner', false); // HARDCODE isOwner as false
    await prefs.setBool('is_worker', true); // HARDCODE isWorker as true
    await prefs.setBool('owner_session_persistent', false); // Clear owner session flag
    await prefs.remove('role'); // Clear any legacy role field
    await prefs.remove('isOwner'); // Clear any legacy isOwner field
    await prefs.remove('isWorker'); // Clear any legacy isWorker field
    await prefs.remove('worker_name'); // Clear any worker session data
    
    // CRITICAL: Save store code and worker name immediately after role is set
    await prefs.setString('store_code', storeCodeInput);
    await prefs.setString('worker_name', workerName);

    // Generate device ID
    final deviceId =
        prefs.getString('device_id') ??
        'device_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('device_id', deviceId);

    // Create worker session
    currentWorkerSession = WorkerSession(
      workerName: workerName,
      storeCode: storeCodeInput,
      deviceId: deviceId,
      loginTime: DateTime.now(),
    );

    // Log to Firestore
    if (storeCode != null && storeCode!.isNotEmpty) {
      await _sync.logWorkerLogin(storeCode!, currentWorkerSession!);
    }

    // Update local state
    currentWorkerName = workerName;
    currentDeviceId = deviceId;

    // Set worker role in app state
    activeRole = UserRole.worker;
    currentUser = employee;

    isShiftLocked = false;

    // CRITICAL: Load full shop data from Firestore for proper sync
    // This ensures worker sees current state from Firestore before setting up listeners
    await _loadFromFirestore();

    // CRITICAL: Force immediate real-time listener setup for store-wide sync
    // This ensures worker can see sessions started by owner and vice versa
    // CRITICAL: Ensure storeCode is properly set before setting up listeners
    if (storeCode != null && storeCode!.isNotEmpty) {
      // CRITICAL: Ensure CloudSync shopId matches current storeCode before setting up listeners
      _sync.shopId = storeCode!;
      _setupRealtimeListeners();
    }

    // Log shift event
    await _logShift(ShiftEvent.login);

    notifyListeners();
    return true;
  }

  Future<void> lockWorkerShift() async {
    if (currentWorkerSession == null || !currentWorkerSession!.isShiftActive) {
      return;
    }

    final endTime = DateTime.now();
    currentWorkerSession = WorkerSession(
      workerName: currentWorkerSession!.workerName,
      storeCode: currentWorkerSession!.storeCode,
      deviceId: currentWorkerSession!.deviceId,
      loginTime: currentWorkerSession!.loginTime,
      shiftEndTime: endTime,
    );

    // Update in Firestore
    final sessionId =
        '${currentDeviceId}_${currentWorkerSession!.loginTime.millisecondsSinceEpoch}';
    if (storeCode != null && storeCode!.isNotEmpty) {
      await _sync.updateWorkerShiftEnd(storeCode!, sessionId, endTime);
    }

    // Lock session
    isShiftLocked = true;
    await _logShift(ShiftEvent.shiftEnd);

    // CRITICAL: Clear worker session data immediately
    currentWorkerName = null;
    currentDeviceId = null;
    currentWorkerSession = null;

    notifyListeners();
  }

  Future<bool> canStartNewShift() async {
    if (!isShiftLocked) return true;

    // Check if enough time has passed (e.g., 1 minute)
    if (currentWorkerSession?.shiftEndTime != null) {
      final timeSinceEnd = DateTime.now().difference(
        currentWorkerSession!.shiftEndTime!,
      );
      return timeSinceEnd.inMinutes >= 1;
    }

    return false;
  }

  Future<void> loginAsStaff() async {
    activeRole = UserRole.staff;
    final staff = employees.where((e) => !e.isOwner);
    currentUser = staff.isNotEmpty
        ? staff.first
        : Employee(
            id: 'staff',
            name: 'كاشير',
            role: UserRole.staff.label,
            code: '',
            isOwner: false,
          );
    tab = AppTab.devices;
    // CRITICAL: Staff login should NOT be logged as shift start - staff are not workers with shifts
    // await _logShift(ShiftEvent.login); // REMOVED - Staff login is not a shift
    notifyListeners();
  }

  Future<void> logout() async {
    activeRole = null;
    currentUser = null;
    currentWorkerName = null;
    currentWorkerSession = null;
    isShiftLocked = false;
    tab = AppTab.devices;

    // Clear session-related SharedPreferences but keep store configuration for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    // Keep user_role and is_owner for owner to maintain invoice persistence on relogin
    // Only clear these if the current user is a worker, not an owner
    final isOwnerSession = await getIsOwnerFromPrefs();
    if (!isOwnerSession) {
      await prefs.remove('user_role');
      await prefs.remove('is_owner');
      await prefs.remove('owner_session_persistent');
    }
    await prefs.remove('is_worker');
    await prefs.remove('worker_name');
    await prefs.remove('owner_last_login');
    // Keep owner_password, store_code as they are needed for re-login and persistence

    // Update synchronous owner state
    await _updateOwnerFromPrefs();

    // Keep storeCode for data persistence - do NOT clear it
    // This ensures invoices and settings persist across logouts
    
    // Cancel real-time listeners to prevent unnecessary updates while logged out
    _cancelRealtimeListeners();

    notifyListeners();
  }

  // Re-assert owner state after any state updates that might override it
  Future<void> _ensureOwnerState() async {
    final isOwnerSession = await getIsOwnerFromPrefs();
    if (isOwnerSession && activeRole != UserRole.admin) {
      // Re-establish owner state if it was incorrectly reset
      activeRole = UserRole.admin;
      currentUser = Employee(
        id: 'owner',
        name: 'صاحب المحل',
        role: 'owner',
        code: adminPin,
        isOwner: true,
      );
      await _updateOwnerFromPrefs();
      notifyListeners();
    }
  }

  void setAdminPin(String pin) {
    if (pin.isEmpty) return;

    // Show confirmation dialog
    // Note: This would need to be handled in the UI layer since we're in a state management class
    // For now, we'll proceed with the change

    adminPin = pin;
    _persist();
  }

  void updatePermissions({
    bool? hideRevenue,
    bool? staffBuyPrices,
    bool? allowCancel,
    double? maxDiscount,
  }) {
    if (hideRevenue != null) hideRevenueFromStaff = hideRevenue;
    if (staffBuyPrices != null) staffSeeBuyPrices = staffBuyPrices;
    if (allowCancel != null) allowCancelInvoices = allowCancel;
    if (maxDiscount != null) maxStaffDiscount = maxDiscount;
    _persist();
    
    // Sync permissions to Firestore immediately
    // CRITICAL: Use storeCode! only if storeCode is properly set, otherwise skip sync
    if (storeCode != null && storeCode!.isNotEmpty && _sync.online) {
      _sync.saveSettings(storeCode!, {
        'hideRevenueFromStaff': hideRevenueFromStaff,
        'staffSeeBuyPrices': staffSeeBuyPrices,
        'allowCancelInvoices': allowCancelInvoices,
        'maxStaffDiscount': maxStaffDiscount,
      });
    }
  }

  String money(num value) {
    final n = value.abs();
    final formatted = n >= 1000
        ? n
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              )
        : (n == n.roundToDouble()
              ? n.toStringAsFixed(0)
              : n.toStringAsFixed(1));
    final sign = value < 0 ? '-' : '';
    return '$sign$formatted $currency';
  }
}

class PosScope extends InheritedNotifier<PosStore> {
  const PosScope({
    super.key,
    required PosStore super.notifier,
    required super.child,
  });

  static PosStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PosScope>()!.notifier!;
}

// ---------------------------------------------------------------------------
// Billing helpers
// ---------------------------------------------------------------------------

int billedMinutes(Duration elapsed) {
  final raw = elapsed.inSeconds / 60.0;
  if (raw <= 0) return 0;
  // Use exact elapsed time instead of rounding to 30 minutes
  return raw.ceil();
}

double liveTimeCost(Duration elapsed, double hourlyRate) =>
    elapsed.inSeconds / 3600.0 * hourlyRate;

// For match mode with fixed price per match
double liveTimeCostPerMatch(
  Duration elapsed,
  PlayMode mode,
  double matchSingleRate,
  double matchMultiRate,
  int numberOfMatches,
) {
  // Match mode charges based on number of matches
  final ratePerMatch = mode == PlayMode.matchSingle
      ? matchSingleRate
      : matchMultiRate;
  return ratePerMatch * numberOfMatches;
}

String formatElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
  return '$m:$s';
}

String formatCountdown(Duration d) {
  final totalSeconds = d.inSeconds;
  if (totalSeconds <= 0) return '00:00';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
  return '$m:$s';
}

String formatClock(DateTime t) {
  final h = t.hour;
  final m = t.minute.toString().padLeft(2, '0');
  final h12 = h % 12 == 0 ? 12 : h % 12;
  final ampm = h >= 12 ? 'PM' : 'AM';
  return '$ampm ${h12.toString().padLeft(2, '0')}:$m';
}

String formatDate(DateTime t) {
  final months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];
  return '${t.day} ${months[t.month - 1]} ${t.year}';
}

String newId(String prefix) =>
    '$prefix${DateTime.now().millisecondsSinceEpoch}';

// ---------------------------------------------------------------------------
// App root (login gate)
// ---------------------------------------------------------------------------

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    if (!store.ready) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.purple),
              SizedBox(height: 16),
              Text(
                'جاري المزامنة مع السحابة...',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }
    if (!store.isLoggedIn) return const RoleLoginScreen();
    if (store.isShiftLocked) return const ShiftLockedScreen();
    if (store.isSubscriptionExpired) return const SubscriptionExpiredScreen();
    return const HomeShell();
  }
}

class ShiftLockedScreen extends StatelessWidget {
  const ShiftLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, color: AppColors.orange, size: 48),
              const SizedBox(height: 16),
              const Text(
                'الشيفت مقفول',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'تم تقفيل الشيفت الخاص بك. سجّل الدخول مرة أخرى لبدء شيفت جديد.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await PosScope.of(context).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleLoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'سجّل الدخول مرة أخرى',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  UserRole? _selected;
  String _pin = '';
  String? _error;
  bool _busy = false;
  bool _hasOwnerPassword = false;
  bool _hasStoreCode = false;
  bool _checkingPassword = true;
  final bool _showInitialChoice = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOwnerPassword();
    });
  }

  Future<void> _checkOwnerPassword() async {
    final store = PosScope.of(context);
    _hasOwnerPassword = await store.hasOwnerPassword();
    _hasStoreCode = await store.hasStoreCode();

    // Check for persistent login session (only for owner)
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userRole = prefs.getString('user_role');
    final isOwner = prefs.getBool('is_owner') ?? false;
    final savedStoreCode = prefs.getString('store_code');

    // Auto-login only for owner role (check both user_role and is_owner flag)
    if (isLoggedIn &&
        (userRole == 'owner' || isOwner) &&
        savedStoreCode != null) {
      final savedPassword = prefs.getString('owner_password');

      if (savedPassword != null) {
        // Set persistent owner session flag before login
        await prefs.setBool('owner_session_persistent', true);
        
        // CRITICAL: Enable Firebase sync before auto-login
        store._sync.online = true;
        
        final success = await store.loginAsAdmin(savedPassword);
        if (success && mounted) {
          store.storeCode = savedStoreCode;
          store.sync.shopId = savedStoreCode;

          // Check subscription expiry after successful login
          if (store.isSubscriptionExpired && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionExpiredScreen(),
              ),
            );
          } else if (store.isSubscriptionNearExpiry && mounted) {
            // Show subscription warning dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.orange),
                    const SizedBox(width: 8),
                    const Text('تحذير انتهاء الاشتراك'),
                  ],
                ),
                content: Text(
                  'اشتراكك ينتهي خلال ${store.daysUntilExpiry} أيام. يرجى التواصل مع الدعم لتجديد الاشتراك.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Auto-redirect to dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeShell(),
                        ),
                      );
                    },
                    child: const Text('فهمت'),
                  ),
                ],
              ),
            );
          } else if (mounted) {
            // Auto-redirect to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeShell()),
            );
          }
        }
      }
    }

    // Always show initial choice screen (owner, worker, or new shop)
    setState(() => _checkingPassword = false);
  }

  Future<void> _submitAdmin() async {
    if (_pin.length < 4 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await PosScope.of(context).loginAsAdmin(_pin);
    if (!mounted) return;
    if (!ok) {
      final store = PosScope.of(context);
      setState(() {
        _busy = false;
      });

      // Check if it's due to expired subscription
      if (store.isSubscriptionExpired) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionExpiredScreen(),
          ),
        );
        return;
      }

      setState(() {
        _error = 'رمز PIN غير صحيح';
        _pin = '';
      });
      return;
    }
    setState(() => _busy = false);
  }

  Future<void> _loginStaff() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await PosScope.of(context).loginAsStaff();
    if (mounted) setState(() => _busy = false);
  }

  void _tapPin(String digit) {
    if (_busy || _pin.length >= 8) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) _submitAdmin();
  }

  void _handleAdminTap() {
    if (_checkingPassword) return;
    setState(() {
      _selected = UserRole.admin;
      _pin = '';
      _error = null;
    });

    // Always show store code login screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StoreCodeLoginScreen()),
    );
  }

  void _handleWorkerTap() {
    if (_busy) return;
    setState(() {
      _selected = UserRole.worker;
      _error = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkerLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showInitialChoice && !_checkingPassword) {
      return _buildInitialChoiceScreen();
    }
    return _buildRoleSelectionScreen();
  }

  Widget _buildInitialChoiceScreen() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withValues(alpha: 0.55),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const PlayControlTitle(fontSize: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'مرحباً بك في PlayControl',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 28),
                      _choiceCard(
                        title: 'تسجيل دخول صاحب المحل',
                        subtitle:
                            'لديك متجر بالفعل؟ سجل دخول بكود المتجر وكلمة السر',
                        icon: Icons.admin_panel_settings,
                        color: AppColors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StoreCodeLoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _choiceCard(
                        title: 'تسجيل دخول عامل / كاشير',
                        subtitle: 'سجل دخول العاملين بكود المتجر واسم العامل',
                        icon: Icons.person,
                        color: AppColors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WorkerLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const DeveloperFooter(),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionScreen() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withValues(alpha: 0.55),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const PlayControlTitle(fontSize: 32),
                      const SizedBox(height: 8),
                      const Text(
                        'اختر نوع الدخول للمتابعة',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 560) {
                            return Column(
                              children: [
                                _roleCard(UserRole.admin),
                                const SizedBox(height: 16),
                                _roleCard(UserRole.worker),
                                const SizedBox(height: 16),
                                _roleCard(UserRole.staff),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _roleCard(UserRole.admin)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _roleCard(UserRole.worker)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _roleCard(UserRole.staff),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const DeveloperFooter(),
        ],
      ),
    );
  }

  Widget _choiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: AppColors.muted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(UserRole role) {
    final selected = _selected == role;
    final isAdmin = role == UserRole.admin;
    return InkWell(
      onTap: _busy || _checkingPassword
          ? null
          : isAdmin
          ? _handleAdminTap
          : (role == UserRole.worker)
          ? _handleWorkerTap
          : () => setState(() {
              _selected = role;
              _pin = '';
              _error = null;
            }),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (isAdmin ? AppColors.gold : AppColors.cyan)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AppColors.purpleDim
                        : (role == UserRole.worker
                              ? AppColors.orangeDim
                              : AppColors.greenDim),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_outlined
                        : (role == UserRole.worker
                              ? Icons.person_outline
                              : Icons.badge_outlined),
                    color: isAdmin
                        ? const Color(0xFFDDD6FE)
                        : (role == UserRole.worker
                              ? AppColors.orange
                              : AppColors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    role.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_checkingPassword && isAdmin)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.purple,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isAdmin
                  ? 'يتطلب رمز PIN للوصول للتقارير والإعدادات والأرباح'
                  : (role == UserRole.worker
                        ? 'دخول العاملين بكود المتجر'
                        : 'دخول سريع للتحكم بالأجهزة وطلبات الكافيه وتقفيل الشيفت'),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (selected &&
                isAdmin &&
                !_checkingPassword &&
                _hasStoreCode &&
                _hasOwnerPassword) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length
                          ? AppColors.purple
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.red),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final n in [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '0',
                  ])
                    _pinKey(n),
                  _pinKey(
                    '',
                    icon: Icons.backspace_outlined,
                    onTap: () {
                      if (_pin.isEmpty) return;
                      setState(() => _pin = _pin.substring(0, _pin.length - 1));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'نسيت كلمة السر؟',
                  style: TextStyle(color: AppColors.purple),
                ),
              ),
            ],
            if (selected && !isAdmin) ...[
              const SizedBox(height: 16),
              _ActionBtn(
                label: _busy ? 'جاري الدخول...' : 'دخول كاشير',
                color: AppColors.green,
                onTap: _busy ? () {} : _loginStaff,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pinKey(String label, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _tapPin(label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardInner,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: icon != null
            ? Icon(icon, size: 18)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class SetOwnerPasswordScreen extends StatefulWidget {
  const SetOwnerPasswordScreen({super.key});

  @override
  State<SetOwnerPasswordScreen> createState() => _SetOwnerPasswordScreenState();
}

class _SetOwnerPasswordScreenState extends State<SetOwnerPasswordScreen> {
  String _storeCode = '';
  String _password = '';
  String _confirmPassword = '';
  String? _error;
  bool _busy = false;
  bool _checkingStoreCode = false;
  SecurityQuestion? _selectedSecurityQuestion;
  String _securityAnswer = '';

  Future<void> _checkStoreCodeAvailability() async {
    if (_storeCode.length < 3) return;

    setState(() {
      _checkingStoreCode = true;
      _error = null;
    });

    final store = PosScope.of(context);
    final exists = await store.checkStoreCodeExists(_storeCode);

    if (!mounted) return;

    setState(() {
      _checkingStoreCode = false;
      if (exists) {
        _error = 'كود المتجر مستخدم بالفعل';
      }
    });
  }

  Future<void> _submitPassword() async {
    if (_storeCode.length < 3) {
      setState(() => _error = 'كود المتجر يجب أن يكون 3 أحرف على الأقل');
      return;
    }
    if (_password.length < 4) {
      setState(() => _error = 'يجب أن يكون الرمز 4 أرقام على الأقل');
      return;
    }
    if (_password != _confirmPassword) {
      setState(() => _error = 'الرمز غير متطابق');
      return;
    }
    if (_selectedSecurityQuestion == null) {
      setState(() => _error = 'يرجى اختيار سؤال أمان');
      return;
    }
    if (_securityAnswer.trim().isEmpty) {
      setState(() => _error = 'يرجى إدخال إجابة السؤال');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final store = PosScope.of(context);
    final success = await store.validateAndSetupStore(
      _storeCode,
      _password,
      securityQuestion: _selectedSecurityQuestion!.id,
      securityAnswer: _securityAnswer.trim(),
    );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _busy = false;
        _error = 'كود المتجر مستخدم بالفعل';
      });
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعيين كود المتجر ورمز الصاحب بنجاح')),
    );
  }

  void _tapPin(String digit) {
    if (_password.length >= 8) return;
    setState(() {
      _password += digit;
      _error = null;
    });
  }

  void _tapConfirmPin(String digit) {
    if (_confirmPassword.length >= 8) return;
    setState(() {
      _confirmPassword += digit;
      _error = null;
    });
  }

  void _backspacePassword() {
    if (_password.isEmpty) return;
    setState(() => _password = _password.substring(0, _password.length - 1));
  }

  void _backspaceConfirmPassword() {
    if (_confirmPassword.isEmpty) return;
    setState(
      () => _confirmPassword = _confirmPassword.substring(
        0,
        _confirmPassword.length - 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('إعداد المتجر لأول مرة'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.55),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'إعداد المتجر لأول مرة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'قم بإنشاء كود متجر فريد ورمز PIN للوصول كصاحب المحل',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'كود المتجر (Store Code)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _storeCode = value.toUpperCase();
                            _error = null;
                          });
                          if (_storeCode.length >= 3) {
                            _checkStoreCodeAvailability();
                          }
                        },
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'مثال: MYSHOP123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: _checkingStoreCode
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : (_storeCode.length >= 3 && _error == null)
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الرمز الجديد',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _password.length
                                  ? AppColors.purple
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final n in [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '0',
                          ])
                            _pinKey(n, onTap: () => _tapPin(n)),
                          _pinKey(
                            '',
                            icon: Icons.backspace_outlined,
                            onTap: _backspacePassword,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'تأكيد الرمز',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _confirmPassword.length
                                  ? AppColors.green
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final n in [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '0',
                          ])
                            _pinKey(n, onTap: () => _tapConfirmPin(n)),
                          _pinKey(
                            '',
                            icon: Icons.backspace_outlined,
                            onTap: _backspaceConfirmPassword,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'سؤال الأمان',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SecurityQuestion>(
                        initialValue: _selectedSecurityQuestion,
                        decoration: InputDecoration(
                          labelText: 'اختر سؤال أمان',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: securityQuestions.map((question) {
                          return DropdownMenuItem<SecurityQuestion>(
                            value: question,
                            child: Text(question.questionAr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSecurityQuestion = value;
                            _error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _securityAnswer = value;
                            _error = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'إجابة السؤال',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.red)),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? () {} : _submitPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _busy ? 'جاري الحفظ...' : 'حفظ الإعدادات',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinKey(String label, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardInner,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: icon != null
            ? Icon(icon, size: 18)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  String _storeCode = '';
  String _pinCode = '';
  String? _error;
  bool _busy = false;
  bool _checkingStoreCode = false;

  Future<void> _checkStoreCode() async {
    if (_storeCode.length < 3) return;

    setState(() {
      _checkingStoreCode = true;
      _error = null;
    });

    final store = PosScope.of(context);
    
    // CRITICAL: Enable Firebase sync before validation to check store codes
    store._sync.online = true;
    
    final storeAuth = await store.getStoreAuth(_storeCode);

    if (!mounted) return;

    setState(() {
      _checkingStoreCode = false;
      if (storeAuth == null) {
        _error = 'كود المتجر غير صحيح';
      } else {
        _error = null; // مسح رسالة الخطأ فور إيجاد كود المتجر الصحيح
      }
    });
  }

  Future<void> _submitLogin() async {
    if (_storeCode.length < 3) {
      setState(() => _error = 'كود المتجر يجب أن يكون 3 أحرف على الأقل');
      return;
    }
    if (_pinCode.length != 5) {
      setState(() => _error = 'يرجى إدخال كود PIN من 5 أرقام');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final store = PosScope.of(context);
    
    // CRITICAL: Enable Firebase sync before validation to check store codes
    store._sync.online = true;

    // First validate the store code
    final storeAuth = await store.getStoreAuth(_storeCode);
    if (!mounted) return;

    if (storeAuth == null) {
      setState(() {
        _busy = false;
        _error = 'كود المتجر غير صحيح';
      });
      return;
    }

    // Check subscription expiry
    if (storeAuth.expiryDate != null &&
        DateTime.now().isAfter(storeAuth.expiryDate!)) {
      setState(() {
        _busy = false;
      });
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionExpiredScreen(),
        ),
      );
      return;
    }

    // Load employees from Firestore and validate PIN
    // Force fresh fetch from Firestore for this specific store to ensure latest employee data
    // Update sync shopId to match the login store code
    store._sync.updateShopId(_storeCode);
    final freshEmployees = await store._sync.loadEmployeesForStore(_storeCode);

    // Update local employees with fresh data
    store.employees.clear();
    store.employees.addAll(freshEmployees);

    // Find employee by PIN code only (no name required)
    // Ignore case and role formatting - validate PIN against all employees under this store
    final employee = store.employees.firstWhere(
      (e) => e.code.trim().toLowerCase() == _pinCode.trim().toLowerCase(),
      orElse: () => Employee(id: '', name: '', role: '', code: ''),
    );

    if (employee.id.isEmpty) {
      setState(() {
        _busy = false;
        _error = 'كود PIN غير صحيح';
      });
      return;
    }

    // Proceed with login using employee name from database
    final success = await store.loginAsWorker(employee.name, _storeCode);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _busy = false;
      });

      // Check if it's due to expired subscription
      if (store.isSubscriptionExpired) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SubscriptionExpiredScreen(),
          ),
        );
        return;
      }

      setState(() {
        _error = 'فشل تسجيل الدخول';
      });
      return;
    }

    // Check subscription expiry after successful login
    if (store.isSubscriptionExpired) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionExpiredScreen(),
        ),
      );
      return;
    }

    // Navigate to dashboard directly
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeShell()),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول بنجاح')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('دخول العامل'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.orange.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.55),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'دخول العامل',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل كود المتجر وكود PIN للدخول',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'كود المتجر',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _storeCode = value.toUpperCase();
                            _error = null;
                          });
                          if (_storeCode.length >= 3) {
                            _checkStoreCode();
                          }
                        },
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'مثال: MYSHOP123',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: _checkingStoreCode
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : (_storeCode.length >= 3 && _error == null)
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.green,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الكود / كلمة السر',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _pinCode = value;
                            _error = null;
                          });
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          hintText: 'أدخل كود PIN الخاص بك',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.red)),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? () {} : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _busy ? 'جاري الدخول...' : 'دخول',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoreCodeLoginScreen extends StatefulWidget {
  const StoreCodeLoginScreen({super.key});

  @override
  State<StoreCodeLoginScreen> createState() => _StoreCodeLoginScreenState();
}

class _StoreCodeLoginScreenState extends State<StoreCodeLoginScreen> {
  final _storeCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _storeCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final storeCode = _storeCodeController.text.trim().toUpperCase();
    final password = _passwordController.text.trim();

    if (storeCode.isEmpty || password.isEmpty) {
      setState(() => _error = 'يرجى إدخال كود المتجر وكلمة السر');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final store = PosScope.of(context);
    
    // CRITICAL: Enable Firebase sync before validation to check store codes
    store._sync.online = true;
    
    final valid = await store.validateStoreCredentials(storeCode, password);

    if (!mounted) return;

    if (!valid) {
      setState(() {
        _busy = false;
        _error = 'كود المتجر أو كلمة السر غير صحيحة';
      });

      // Show SnackBar error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كود المتجر أو رمز PIN غير صحيح'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }

    // Login successful
    await store.setStoreCode(storeCode);
    await store.setOwnerPassword(password);
    await store.saveOwnerSession();

    // CRITICAL: Set owner state in SharedPreferences immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'owner');
    await prefs.setBool('is_owner', true);
    await prefs.setBool('is_worker', false);
    await prefs.setBool('owner_session_persistent', true);
    await prefs.setString('store_code', storeCode);
    await prefs.remove('role'); // Clear any legacy role field
    await prefs.remove('isOwner'); // Clear any legacy isOwner field
    await prefs.remove('isWorker'); // Clear any legacy isWorker field
    await prefs.remove('worker_name'); // Clear any worker session data
    
    // CRITICAL: Trigger synchronous owner state update for immediate UI response
    store.updateOwnerFromPrefsSync();
    store.activeRole = UserRole.admin;
    store.notifyListeners();

    // Load shop data from Firestore
    await store._loadFromFirestore();

    if (!mounted) return;

    // Check subscription expiry
    if (store.isSubscriptionExpired) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionExpiredScreen(),
        ),
      );
      return;
    }

    // Navigate to dashboard directly
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('تسجيل دخول صاحب المحل'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.55),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 34),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل كود المتجر وكلمة السر',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _storeCodeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'كود المتجر',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'كلمة السر',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: AppColors.red)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'دخول',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'نسيت كلمة السر؟',
                    style: TextStyle(color: AppColors.purple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _storeCode = '';
  String _newPassword = '';
  String _confirmPassword = '';
  String _securityAnswer = '';
  String? _error;
  bool _busy = false;
  bool _checkingStoreCode = false;
  bool _showSecurityQuestion = false;
  StoreAuth? _storeAuth;

  Future<void> _checkStoreCode() async {
    if (_storeCode.length < 3) return;

    setState(() {
      _checkingStoreCode = true;
      _error = null;
    });

    final store = PosScope.of(context);
    
    // CRITICAL: Enable Firebase sync before validation to check store codes
    store._sync.online = true;
    
    final storeAuth = await store.getStoreAuth(_storeCode);

    if (!mounted) return;

    setState(() {
      _checkingStoreCode = false;
      if (storeAuth == null) {
        _error = 'كود المتجر غير صحيح';
      } else if (storeAuth.securityQuestion == null) {
        _error = 'هذا المتجر لا يحتوي على سؤال أمان';
      } else {
        _storeAuth = storeAuth;
        _showSecurityQuestion = true;
      }
    });
  }

  Future<void> _verifySecurityAnswer() async {
    if (_securityAnswer.trim().isEmpty) {
      setState(() => _error = 'يرجى إدخال إجابة السؤال');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final store = PosScope.of(context);
    final verified = await store.verifySecurityAnswer(
      _storeCode,
      _securityAnswer.trim(),
    );

    if (!mounted) return;

    if (!verified) {
      setState(() {
        _busy = false;
        _error = 'إجابة السؤال غير صحيحة';
      });
      return;
    }

    setState(() {
      _busy = false;
      _showSecurityQuestion = false;
    });
  }

  Future<void> _resetPassword() async {
    if (_newPassword.length < 4) {
      setState(() => _error = 'يجب أن يكون الرمز 4 أرقام على الأقل');
      return;
    }
    if (_newPassword != _confirmPassword) {
      setState(() => _error = 'الرمز غير متطابق');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final store = PosScope.of(context);
    final success = await store.resetPassword(_storeCode, _newPassword);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _busy = false;
        _error = 'فشل تحديث كلمة السر';
      });
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تحديث كلمة السر بنجاح')));
  }

  void _tapPin(String digit) {
    if (_newPassword.length >= 8) return;
    setState(() {
      _newPassword += digit;
      _error = null;
    });
  }

  void _tapConfirmPin(String digit) {
    if (_confirmPassword.length >= 8) return;
    setState(() {
      _confirmPassword += digit;
      _error = null;
    });
  }

  void _backspacePassword() {
    if (_newPassword.isEmpty) return;
    setState(
      () => _newPassword = _newPassword.substring(0, _newPassword.length - 1),
    );
  }

  void _backspaceConfirmPassword() {
    if (_confirmPassword.isEmpty) return;
    setState(
      () => _confirmPassword = _confirmPassword.substring(
        0,
        _confirmPassword.length - 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('نسيت كلمة السر'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.purple.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.55),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'استعادة كلمة السر',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'أدخل كود المتجر للبدء',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (!_showSecurityQuestion) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'كود المتجر',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _storeCode = value.toUpperCase();
                              _error = null;
                            });
                            if (_storeCode.length >= 3) {
                              _checkStoreCode();
                            }
                          },
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: 'مثال: MYSHOP123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: _checkingStoreCode
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : (_storeCode.length >= 3 && _error == null)
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.green,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_showSecurityQuestion && _storeAuth != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'سؤال الأمان',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _storeAuth!.securityQuestion != null
                              ? securityQuestions
                                    .firstWhere(
                                      (q) =>
                                          q.id == _storeAuth!.securityQuestion,
                                    )
                                    .questionAr
                              : '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _securityAnswer = value;
                              _error = null;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'إجابة السؤال',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 42,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? () {} : _verifySecurityAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _busy ? 'جاري التحقق...' : 'تحقق من الإجابة',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_showSecurityQuestion && _storeAuth == null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'الرمز الجديد',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (i) => Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _newPassword.length
                                    ? AppColors.purple
                                    : AppColors.border,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final n in [
                              '1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8',
                              '9',
                              '0',
                            ])
                              _pinKey(n, onTap: () => _tapPin(n)),
                            _pinKey(
                              '',
                              icon: Icons.backspace_outlined,
                              onTap: _backspacePassword,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'تأكيد الرمز',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (i) => Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _confirmPassword.length
                                    ? AppColors.green
                                    : AppColors.border,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final n in [
                              '1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8',
                              '9',
                              '0',
                            ])
                              _pinKey(n, onTap: () => _tapConfirmPin(n)),
                            _pinKey(
                              '',
                              icon: Icons.backspace_outlined,
                              onTap: _backspaceConfirmPassword,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: AppColors.red)),
                ],

                if (_showSecurityQuestion && _storeAuth == null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 42,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? () {} : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _busy ? 'جاري التحديث...' : 'تحديث كلمة السر',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinKey(String label, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardInner,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: icon != null
            ? Icon(icon, size: 18)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

// Access restrictions completely removed - StaffAccessDenied widget no longer needed

class SubscriptionExpiredScreen extends StatelessWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(Icons.cancel, color: AppColors.red, size: 34),
              ),
              const SizedBox(height: 20),
              const Text(
                'انتهت مدة اشتراكك',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى التواصل مع الدعم للتجديد',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await PosScope.of(context).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoleLoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'سجّل الدخول مرة أخرى',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  PosStore? _store;

  @override
  void initState() {
    super.initState();
    // Listen to store changes to rebuild shell when tab changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = PosScope.of(context);
      _store = store;
      store.addListener(_onStoreChanged);
    });
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Builder to ensure we get the updated store state on each rebuild
    return Builder(
      builder: (context) {
        final store = PosScope.of(context);

        return Scaffold(
          body: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: switch (store.tab) {
                  AppTab.devices => const DevicesPage(),
                  AppTab.invoices => const InvoicesPage(),
                  AppTab.inventory => const InventoryPage(),
                  AppTab.reports => const ReportsPage(),
                  AppTab.settings => const SettingsPage(),
                  AppTab.loginLogs => const LoginLogsPage(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  PosStore? _store;

  @override
  void initState() {
    super.initState();
    // Listen to store changes to rebuild header when tab changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = PosScope.of(context);
      _store = store;
      store.addListener(_onStoreChanged);
    });
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Builder to ensure we get the updated store state on each rebuild
    return Builder(
      builder: (context) {
        final store = PosScope.of(context);
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Brand(store: store),
                    const SizedBox(width: 16),
                    const TabStrip(),
                    const SizedBox(width: 12),
                    _StatChip(
                      value: '${store.sessionsToday}',
                      label: 'جلسات اليوم',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: '${store.activeCount}/${store.devices.length}',
                      label: 'أجهزة شغّالة',
                      valueColor: AppColors.cyan,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: store.canViewRevenue
                          ? store.todayRevenue.toStringAsFixed(0)
                          : '—',
                      label: 'إيراد اليوم',
                      valueColor: AppColors.green,
                    ),
                    if (store.isAdmin && store.expiryDate != null) ...[
                      const SizedBox(width: 8),
                      _SubscriptionStatusCard(store: store),
                    ],
                    // Show subscription warning banner when near expiry
                    if (store.isSubscriptionNearExpiry && !store.isSubscriptionExpired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.orangeDim.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber, color: AppColors.orange, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'الاشتراك ينتهي خلال ${store.daysUntilExpiry} أيام',
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (store.canModifyInventory) ...[
                      const SizedBox(width: 8),
                      _SquareIcon(
                        icon: Icons.local_cafe_outlined,
                        onTap: () {
                          store.setTab(AppTab.inventory);
                        },
                      ),
                    ],
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        // Clear session-related SharedPreferences but keep store configuration
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('is_logged_in');
                        await prefs.remove('user_role');
                        await prefs.remove('is_owner');
                        await prefs.remove('is_worker');
                        await prefs.remove('worker_name');
                        await prefs.remove('owner_last_login');
                        // Keep owner_password, store_code as they are needed for re-login

                        // Reset store state
                        store.activeRole = null;
                        store.currentUser = null;
                        store.currentWorkerName = null;
                        store.currentWorkerSession = null;
                        store.isShiftLocked = false;
                        // Keep storeCode for re-login
                        final savedStoreCode = store.storeCode;
                        store.storeCode = null;

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoleLoginScreen(),
                            ),
                            (route) => false,
                          );
                        }

                        // Restore store code for next login if available
                        if (savedStoreCode != null) {
                          store.storeCode = savedStoreCode;
                        }
                      },
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('تغيير المستخدم'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        backgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: store.syncOnline ? 'متصل بالسحابة' : 'وضع محلي',
                      child: Icon(
                        store.syncOnline ? Icons.cloud_done : Icons.cloud_off,
                        color: store.syncOnline
                            ? AppColors.green
                            : AppColors.faint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.store});
  final PosStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.45),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(Icons.sports_esports, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PlayControlTitle(fontSize: 18),
            if (store.shopName.isNotEmpty &&
                store.shopName != AppBranding.name) ...[
              const SizedBox(height: 2),
              Text(
                store.shopName,
                style: const TextStyle(color: AppColors.faint, fontSize: 11),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _RoleBadge(role: store.activeRole),
                if (store.currentUser != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    store.currentUser!.name,
                    style: const TextStyle(
                      color: AppColors.faint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    if (role == null) return const SizedBox.shrink();
    final admin = role == UserRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: admin ? const Color(0x22EAB308) : const Color(0x2222D3EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: admin
              ? AppColors.gold.withValues(alpha: 0.7)
              : AppColors.cyan.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        role!.label,
        style: TextStyle(
          color: admin ? AppColors.gold : AppColors.cyan,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TabStrip extends StatefulWidget {
  const TabStrip({super.key});

  static const _items = [
    (AppTab.devices, 'الأجهزة'),
    (AppTab.invoices, 'الفواتير'),
    (AppTab.inventory, 'المخزون والمشروبات'),
    (AppTab.reports, 'التقارير'),
    (AppTab.settings, 'الإعدادات'),
    (AppTab.loginLogs, 'سجل الدخول'),
  ];

  @override
  State<TabStrip> createState() => _TabStripState();
}

class _TabStripState extends State<TabStrip> {
  PosStore? _store;

  @override
  void initState() {
    super.initState();
    // Listen to store changes to rebuild tab strip when tab changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = PosScope.of(context);
      _store = store;
      store.addListener(_onStoreChanged);
    });
  }

  @override
  void dispose() {
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Builder to ensure we get the updated store state on each rebuild
    return Builder(
      builder: (context) {
        final store = PosScope.of(context);
        // CRITICAL: Use the authoritative allowedTabs from store instead of implementing custom logic
        // This ensures owner always gets all tabs as defined in store.allowedTabs
        final visibleTabs = store.allowedTabs;

        final visible = TabStrip._items.where(
          (item) => visibleTabs.contains(item.$1),
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in visible)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Force immediate tab switch and rebuild
                      store.setTab(item.$1);
                      // Ensure state change is applied immediately
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: store.tab == item.$1
                            ? AppColors.elevated
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: store.tab == item.$1
                              ? AppColors.purple.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          color: store.tab == item.$1
                              ? AppColors.text
                              : AppColors.muted,
                          fontWeight: store.tab == item.$1
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    this.valueColor = AppColors.text,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.faint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SquareIcon extends StatelessWidget {
  const _SquareIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.muted),
      ),
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({required this.store});
  final PosStore store;

  @override
  Widget build(BuildContext context) {
    final daysRemaining = store.daysUntilExpiry;
    final isExpired = store.isSubscriptionExpired;

    // Format expiry date
    final expiryDate = store.expiryDate!;
    final formattedDate =
        '${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}';

    // Determine color based on status
    Color statusColor;
    String statusText;

    if (isExpired) {
      statusColor = AppColors.red;
      statusText = 'منتهي';
    } else if (daysRemaining <= 7) {
      statusColor = AppColors.orange;
      statusText = 'قريب';
    } else {
      statusColor = AppColors.green;
      statusText = 'نشط';
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_membership, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isExpired ? 'انتهى: $formattedDate' : 'متبقي $daysRemaining يوم',
            style: const TextStyle(color: AppColors.faint, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Devices
// ---------------------------------------------------------------------------

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1280
            ? 4
            : w >= 960
            ? 3
            : w >= 640
            ? 2
            : 1;

        // Show empty state with default devices if no devices exist
        if (store.devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.devices_outlined, size: 64, color: AppColors.faint),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد أجهزة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يتم إضافة الأجهزة الافتراضية تلقائياً',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    store.devices.addAll([
                      Device(
                        id: 'd1',
                        name: 'الجهاز 1',
                        singleRate: 40,
                        multiRate: 70,
                      ),
                      Device(
                        id: 'd2',
                        name: 'الجهاز 2',
                        singleRate: 40,
                        multiRate: 70,
                      ),
                      Device(
                        id: 'd3',
                        name: 'الجهاز 3',
                        singleRate: 40,
                        multiRate: 70,
                      ),
                      Device(
                        id: 'd4',
                        name: 'الجهاز 4',
                        singleRate: 40,
                        multiRate: 70,
                      ),
                    ]);
                    // Notify listeners will be called automatically through the store's internal mechanisms
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إضافة أجهزة افتراضية'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: w >= 1280 ? 1.18 : 1.05,
          ),
          itemCount: store.devices.length,
          itemBuilder: (_, i) => DeviceCard(device: store.devices[i]),
        );
      },
    );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final session = device.session;
    final busy = session != null;
    final elapsed = busy
        ? DateTime.now().difference(session.startedAt)
        : Duration.zero;
    final rate = busy
        ? device.rateFor(session.mode)
        : device.rateFor(device.preferredMode);
    final live = busy
        ? (session.mode == PlayMode.matchSingle ||
                  session.mode == PlayMode.matchMulti
              ? liveTimeCostPerMatch(
                      elapsed,
                      session.mode,
                      device.matchSingleRate,
                      device.matchMultiRate,
                      session.numberOfMatches,
                    ) +
                    session.cafeTotal
              : liveTimeCost(elapsed, rate) + session.cafeTotal)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: busy
              ? AppColors.purple.withValues(alpha: 0.45)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  device.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusBadge(busy: busy),
            ],
          ),
          const Spacer(),
          FittedBox(
            child: Text(
              busy && session.customDurationMinutes != null
                  ? formatCountdown(
                      Duration(
                        seconds:
                            (session.customDurationMinutes! * 60) -
                            elapsed.inSeconds,
                      ),
                    )
                  : formatElapsed(elapsed),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                height: 1,
                color:
                    busy &&
                        session.customDurationMinutes != null &&
                        elapsed.inSeconds >=
                            (session.customDurationMinutes! * 60)
                    ? AppColors.red
                    : null,
              ),
            ),
          ),
          if (busy) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: session.customDurationMinutes != null
                    ? elapsed.inSeconds /
                          (session.customDurationMinutes! * 60).clamp(
                            1,
                            double.infinity,
                          )
                    : (elapsed.inSeconds % 3600) / 3600,
                minHeight: 4,
                backgroundColor: AppColors.border,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'بدأ ${formatClock(session.startedAt)}  ·  ${session.mode.label}'
              '${session.customDurationMinutes != null ? '  ·  ${session.customDurationMinutes} دقيقة' : ''}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 10),
            _ModeSelector(
              mode: device.preferredMode,
              singleRate: device.singleRate,
              multiRate: device.multiRate,
              matchSingleRate: device.matchSingleRate,
              matchMultiRate: device.matchMultiRate,
              currency: store.currency,
              onChanged: (m) => store.setPreferredMode(device, m),
            ),
          ],
          const Spacer(),
          if (busy)
            Row(
              children: [
                if (store.canViewRevenue)
                  Text(
                    store.money(live),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  )
                else
                  const Text(
                    '—',
                    style: TextStyle(color: AppColors.faint, fontSize: 20),
                  ),
                const Spacer(),
                if (session.cafeQty > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x2234D399),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${session.cafeQty} طلب كافيه',
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            )
          else
            Text(
              '0 ${store.currency}',
              style: const TextStyle(color: AppColors.faint, fontSize: 18),
            ),
          const SizedBox(height: 12),
          if (busy)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'إنهاء وحساب',
                        color: AppColors.green,
                        onTap: () => showCheckoutDialog(context, device),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: '+ طلب',
                        color: AppColors.elevated,
                        foreground: AppColors.text,
                        onTap: () => showCafeOrdersDialog(context, device),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ActionBtn(
                  label: 'نقل الجلسة',
                  color: AppColors.orange,
                  foreground: Colors.white,
                  onTap: () => showTransferSessionDialog(context, device),
                ),
              ],
            )
          else
            _ActionBtn(
              label: 'ابدأ الجلسة',
              color: AppColors.purple,
              onTap: () => showStartSessionDialog(context, device),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.busy});
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: busy ? AppColors.purpleDim : AppColors.greenDim,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        busy ? 'شغال' : 'فاضي',
        style: TextStyle(
          color: busy ? const Color(0xFFDDD6FE) : AppColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.singleRate,
    required this.multiRate,
    required this.matchSingleRate,
    required this.matchMultiRate,
    required this.currency,
    required this.onChanged,
  });

  final PlayMode mode;
  final double singleRate;
  final double multiRate;
  final double matchSingleRate;
  final double matchMultiRate;
  final String currency;
  final ValueChanged<PlayMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeChip(
                selected: mode == PlayMode.single,
                title: 'فردي',
                subtitle: '${singleRate.toStringAsFixed(0)} $currency/س',
                onTap: () => onChanged(PlayMode.single),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModeChip(
                selected: mode == PlayMode.multi,
                title: 'زوجي',
                subtitle: '${multiRate.toStringAsFixed(0)} $currency/س',
                onTap: () => onChanged(PlayMode.multi),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ModeChip(
                selected: mode == PlayMode.matchSingle,
                title: 'ماتش فردي',
                subtitle:
                    '${matchSingleRate.toStringAsFixed(0)} $currency/ماتش',
                onTap: () => onChanged(PlayMode.matchSingle),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModeChip(
                selected: mode == PlayMode.matchMulti,
                title: 'ماتش زوجي',
                subtitle: '${matchMultiRate.toStringAsFixed(0)} $currency/ماتش',
                onTap: () => onChanged(PlayMode.matchMulti),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleDim : AppColors.cardInner,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.text : AppColors.muted,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.faint),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.foreground = Colors.white,
  });

  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transfer session
// ---------------------------------------------------------------------------

Future<void> showTransferSessionDialog(BuildContext context, Device sourceDevice) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => TransferSessionDialog(sourceDevice: sourceDevice),
  );
}

class TransferSessionDialog extends StatefulWidget {
  const TransferSessionDialog({super.key, required this.sourceDevice});
  final Device sourceDevice;

  @override
  State<TransferSessionDialog> createState() => _TransferSessionDialogState();
}

class _TransferSessionDialogState extends State<TransferSessionDialog> {
  Device? targetDevice;

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final availableDevices = store.devices.where((d) => 
      d.id != widget.sourceDevice.id && !d.isBusy
    ).toList();

    return _ModalFrame(
      title: 'نقل الجلسة',
      subtitle: widget.sourceDevice.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'اختر الجهاز المراد نقل الجلسة إليه',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (availableDevices.isEmpty)
            const Center(
              child: Text(
                'لا توجد أجهزة متاحة للنقل',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            Column(
              children: availableDevices.map((device) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        targetDevice = device;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: targetDevice?.id == device.id
                            ? AppColors.purpleDim.withValues(alpha: 0.5)
                            : AppColors.cardInner,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: targetDevice?.id == device.id
                              ? AppColors.purple
                              : AppColors.border,
                          width: targetDevice?.id == device.id ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.computer, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              device.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (targetDevice?.id == device.id)
                            const Icon(Icons.check_circle, color: AppColors.green),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'إلغاء',
                  color: AppColors.elevated,
                  foreground: AppColors.text,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: 'نقل الجلسة',
                  color: AppColors.orange,
                  onTap: () async {
                    if (targetDevice == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار جهاز للنقل'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                      return;
                    }

                    final err = await store.transferSession(
                      widget.sourceDevice,
                      targetDevice!,
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(err),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نقل الجلسة بنجاح'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Start session
// ---------------------------------------------------------------------------

Future<void> showStartSessionDialog(BuildContext context, Device device) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => StartSessionDialog(device: device),
  );
}

class StartSessionDialog extends StatefulWidget {
  const StartSessionDialog({super.key, required this.device});
  final Device device;

  @override
  State<StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<StartSessionDialog> {
  late PlayMode mode = widget.device.preferredMode;
  final customer = TextEditingController();
  final duration = TextEditingController();
  final numberOfMatches = TextEditingController(text: '1');

  @override
  void dispose() {
    customer.dispose();
    duration.dispose();
    numberOfMatches.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return _ModalFrame(
      title: 'بدء الجلسة',
      subtitle: widget.device.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkField(controller: customer, label: 'اسم العميل (اختياري)'),
          const SizedBox(height: 12),
          _ModeSelector(
            mode: mode,
            singleRate: widget.device.singleRate,
            multiRate: widget.device.multiRate,
            matchSingleRate: widget.device.matchSingleRate,
            matchMultiRate: widget.device.matchMultiRate,
            currency: store.currency,
            onChanged: (m) => setState(() => mode = m),
          ),
          const SizedBox(height: 12),
          if (mode == PlayMode.single || mode == PlayMode.multi)
            _DarkField(
              controller: duration,
              label: 'المدة بالدقائق (اختياري)',
              keyboardType: TextInputType.number,
            ),
          if (mode == PlayMode.matchSingle || mode == PlayMode.matchMulti)
            _DarkField(
              controller: numberOfMatches,
              label: 'عدد المباريات',
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 18),
          _ActionBtn(
            label: 'ابدأ الجلسة',
            color: AppColors.purple,
            onTap: () {
              final customDuration =
                  mode == PlayMode.single || mode == PlayMode.multi
                  ? int.tryParse(duration.text)
                  : null;
              final matches = mode == PlayMode.matchSingle || mode == PlayMode.matchMulti
                  ? int.tryParse(numberOfMatches.text) ?? 1
                  : 1;
              store.startSession(
                widget.device,
                customer: customer.text,
                mode: mode,
                customDurationMinutes: customDuration,
                numberOfMatches: matches,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cafe orders
// ---------------------------------------------------------------------------

Future<void> showCafeOrdersDialog(BuildContext context, Device device) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => CafeOrdersDialog(device: device),
  );
}

class CafeOrdersDialog extends StatefulWidget {
  const CafeOrdersDialog({super.key, required this.device});
  final Device device;

  @override
  State<CafeOrdersDialog> createState() => _CafeOrdersDialogState();
}

class _CafeOrdersDialogState extends State<CafeOrdersDialog> {
  final Map<String, int> qty = {};

  int of(String id) => qty[id] ?? 0;

  void bump(CafeItem item, int delta) {
    final next = (of(item.id) + delta).clamp(0, item.stock);
    setState(() => qty[item.id] = next);
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final selected = store.cafeItems.where((c) => of(c.id) > 0).toList();
    final total = selected.fold(0.0, (a, c) => a + c.sell * of(c.id));

    return _ModalFrame(
      title: 'طلبات الكافيه',
      subtitle: widget.device.name,
      width: 720,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 260,
            child: GridView.builder(
              itemCount: store.cafeItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (_, i) {
                final item = store.cafeItems[i];
                final q = of(item.id);
                return InkWell(
                  onTap: item.stock > 0 ? () => bump(item, 1) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cardInner,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: q > 0 ? AppColors.purple : AppColors.border,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              store.money(item.sell),
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            Text(
                              'باقي: ${item.stock}',
                              style: TextStyle(
                                fontSize: 11,
                                color: item.stock <= item.alert
                                    ? AppColors.orange
                                    : AppColors.faint,
                              ),
                            ),
                          ],
                        ),
                        if (q > 0)
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.purple,
                              child: Text(
                                '$q',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 24),
          if (selected.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لم يتم اختيار أصناف',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            ...selected.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      store.money(item.sell * of(item.id)),
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(width: 12),
                    _QtyBtns(
                      qty: of(item.id),
                      onMinus: () => bump(item, -1),
                      onPlus: () => bump(item, 1),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'إجمالي الطلبات',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                store.money(total),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionBtn(
            label: 'تم',
            color: AppColors.purple,
            onTap: () {
              final err = store.applyCafeOrder(widget.device, qty);
              if (err != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
                return;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _QtyBtns extends StatelessWidget {
  const _QtyBtns({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniIcon(icon: Icons.add, onTap: onPlus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        _MiniIcon(icon: Icons.remove, onTap: onMinus),
      ],
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Checkout
// ---------------------------------------------------------------------------

Future<void> showCheckoutDialog(BuildContext context, Device device) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => CheckoutDialog(device: device),
  );
}

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key, required this.device});
  final Device device;

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final discountCtrl = TextEditingController(text: '0');
  late final DateTime endedAt = DateTime.now();

  @override
  void dispose() {
    discountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final discount = double.tryParse(discountCtrl.text) ?? 0;
    final preview = store.previewCheckout(
      widget.device,
      endedAt: endedAt,
      discount: discount,
    );
    final session = widget.device.session!;
    final rate = widget.device.rateFor(session.mode);

    return _ModalFrame(
      title: 'الفاتورة',
      subtitle: '${widget.device.name} — ${session.customer}',
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KV('بدأت', formatClock(preview.from)),
          _KV('انتهت', formatClock(preview.to)),
          _KV('المدة المحسوبة', '${preview.billedMinutes} دقيقة'),
          if (session.mode == PlayMode.matchSingle || session.mode == PlayMode.matchMulti)
            _KV('عدد المباريات', '${session.numberOfMatches}'),
          const SizedBox(height: 6),
          _KV(
            session.mode == PlayMode.matchSingle || session.mode == PlayMode.matchMulti
                ? 'حساب المباريات (${session.numberOfMatches} × ${session.mode == PlayMode.matchSingle ? widget.device.matchSingleRate : widget.device.matchMultiRate} ${store.currency})'
                : 'حساب الوقت (${rate.toStringAsFixed(0)} ${store.currency}/ساعة)',
            store.money(preview.timeCost),
          ),
          for (final line in session.orders)
            _KV('${line.name} × ${line.qty}', store.money(line.lineTotal)),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'خصم (${store.currency})',
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 6),
          _DarkField(
            controller: discountCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                store.money(preview.total),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'تأكيد الدفع وإنهاء',
                  color: AppColors.green,
                  onTap: () {
                    final err = store.confirmCheckout(widget.device, preview);
                    if (err != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(err)));
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: 'رجوع',
                  color: AppColors.elevated,
                  foreground: AppColors.text,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(k, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manual Bill
// ---------------------------------------------------------------------------

class _DrinkSelectionDialog extends StatefulWidget {
  final PosStore store;
  final Map<String, int> initialQuantities;
  final Function(Map<String, int>) onConfirm;

  const _DrinkSelectionDialog({
    required this.store,
    required this.initialQuantities,
    required this.onConfirm,
  });

  @override
  State<_DrinkSelectionDialog> createState() => _DrinkSelectionDialogState();
}

class _DrinkSelectionDialogState extends State<_DrinkSelectionDialog> {
  late Map<String, int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = Map.from(widget.initialQuantities);
  }

  void _bumpQuantity(String itemId, int delta) {
    setState(() {
      final current = quantities[itemId] ?? 0;
      final next = (current + delta).clamp(0, 99);
      if (next == 0) {
        quantities.remove(itemId);
      } else {
        quantities[itemId] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final selectedItems = store.cafeItems.where((c) => quantities[c.id] != null && quantities[c.id]! > 0).toList();
    final total = selectedItems.fold(0.0, (a, c) => a + c.sell * (quantities[c.id] ?? 0));

    return _ModalFrame(
      title: 'اختيار المشروبات',
      subtitle: 'من المخزون',
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              child: GridView.builder(
              itemCount: store.cafeItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (_, i) {
                final item = store.cafeItems[i];
                final qty = quantities[item.id] ?? 0;
                return InkWell(
                  onTap: item.stock > 0 ? () => _bumpQuantity(item.id, 1) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: qty > 0 ? AppColors.purpleDim.withValues(alpha: 0.5) : AppColors.cardInner,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: qty > 0 ? AppColors.purple : AppColors.border,
                        width: qty > 0 ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.money(item.sell),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (qty > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'x$qty',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        if (item.stock <= 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'نفذت الكمية',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                store.money(total),
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'إلغاء',
                  color: AppColors.elevated,
                  foreground: AppColors.text,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: 'تأكيد',
                  color: AppColors.green,
                  onTap: () {
                    widget.onConfirm(quantities);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

Future<void> showManualBillDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const ManualBillDialog(),
  );
}

class ManualBillDialog extends StatefulWidget {
  const ManualBillDialog({super.key});

  @override
  State<ManualBillDialog> createState() => _ManualBillDialogState();
}

class _ManualBillDialogState extends State<ManualBillDialog> {
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  List<OrderLine> selectedDrinks = [];

  @override
  void dispose() {
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  void _showDrinkSelectionDialog(BuildContext context) {
    final store = PosScope.of(context);
    Map<String, int> drinkQuantities = {};
    
    for (var drink in selectedDrinks) {
      drinkQuantities[drink.itemId] = (drinkQuantities[drink.itemId] ?? 0) + drink.qty;
    }

    showDialog(
      context: context,
      builder: (_) => _DrinkSelectionDialog(
        store: store,
        initialQuantities: drinkQuantities,
        onConfirm: (quantities) {
          setState(() {
            selectedDrinks.clear();
            double drinkTotal = 0.0;
            for (var entry in quantities.entries) {
              if (entry.value > 0) {
                final item = store.cafeItems.firstWhere((c) => c.id == entry.key);
                selectedDrinks.add(OrderLine(
                  itemId: item.id,
                  name: item.name,
                  unitPrice: item.sell,
                  qty: entry.value,
                ));
                drinkTotal += item.sell * entry.value;
              }
            }
            // Automatically set amount to drink total when drinks are selected
            if (selectedDrinks.isNotEmpty) {
              amountCtrl.text = drinkTotal.toStringAsFixed(0);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
    final description = descriptionCtrl.text.trim().isEmpty 
        ? 'فاتورة يدوية' 
        : descriptionCtrl.text.trim();
    
    // Calculate preview without device dependency
    final preview = store.previewManualBill(
      amount: amount,
      description: description,
      orders: selectedDrinks.isNotEmpty ? selectedDrinks : null,
    );

    return _ModalFrame(
      title: 'فاتورة يدوية',
      subtitle: 'فاتورة يدوية',
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DarkField(
              controller: descriptionCtrl,
              label: 'الوصف',
            ),
            const SizedBox(height: 12),
            _DarkField(
              controller: amountCtrl,
              label: 'المبلغ',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDrinkSelectionDialog(context),
              icon: const Icon(Icons.local_cafe_outlined, size: 18),
              label: const Text('طلب مشروب'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (selectedDrinks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardInner,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المشروبات المطلوبة:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...selectedDrinks.map((drink) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${drink.name} x${drink.qty}'),
                          Text(store.money(drink.lineTotal)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'الإجمالي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text(
                  store.money(preview.total),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'إلغاء',
                    color: AppColors.elevated,
                    foreground: AppColors.text,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    label: 'تأكيد الفاتورة',
                    color: AppColors.green,
                    onTap: () {
                      if (amount <= 0 && selectedDrinks.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يرجى إدخال مبلغ صحيح أو اختيار مشروبات'),
                            backgroundColor: AppColors.red,
                          ),
                        );
                        return;
                      }
                      store.confirmManualBill(preview);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إنشاء الفاتورة بنجاح')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyRevenueDialog extends StatefulWidget {
  const MonthlyRevenueDialog({super.key});

  @override
  State<MonthlyRevenueDialog> createState() => _MonthlyRevenueDialogState();
}

class _MonthlyRevenueDialogState extends State<MonthlyRevenueDialog> {
  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    
    return _ModalFrame(
      title: 'تحليلات الإيراد الشهري',
      subtitle: 'آخر 30 يوم',
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: FutureBuilder<double>(
              future: store.sync.calculateMonthlyRevenue(store.storeCode ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.purple),
                  );
                }
                
                final monthlyRevenue = snapshot.data ?? 0.0;
                
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.purpleDim.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.purple.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'إجمالي الإيراد الشهري',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              store.money(monthlyRevenue),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'آخر 30 يوم',
                              style: TextStyle(
                                color: AppColors.faint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _KV('عدد الفواتير الشهرية', '${store.invoices.length}'),
                      _KV('متوسط الإيراد اليومي', store.money(monthlyRevenue / 30)),
                      _KV('إيراد الكافيه الشهري', store.money(store.cafeRevenue)),
                      _KV('إيراد الوقت الشهري', store.money(store.timeRevenue)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: 'إغلاق',
            color: AppColors.elevated,
            foreground: AppColors.text,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoices + shift close
// ---------------------------------------------------------------------------

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final admin = store.isAdmin;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _Panel(
        title: admin ? 'فواتير اليوم' : 'جلسات اليوم',
        subtitle: admin
            ? '${store.money(store.todayRevenue)} — ${store.invoices.length} فواتير'
            : '${store.invoices.length} جلسة منتهية',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => showManualBillDialog(context),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('فاتورة يدوية'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Only show shift close button for workers, not for owners/admins
            if (!store.isOwner && !store.isAdmin) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => showShiftCloseDialog(context),
                icon: const Icon(Icons.nights_stay_outlined, size: 18),
                label: const Text('تقفيل الشيفت'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.text,
                  backgroundColor: AppColors.elevated,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
        child: Column(
          children: [
            _TableHead(
              cells: admin
                  ? const [
                      'الجهاز',
                      'العميل',
                      'من',
                      'إلى',
                      'المدة',
                      'وقت',
                      'كافيه',
                      'خصم',
                      'الإجمالي',
                      'بواسطة',
                    ]
                  : const [
                      'الجهاز',
                      'العميل',
                      'من',
                      'إلى',
                      'المدة',
                      'بواسطة',
                    ],
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: store.invoices.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          admin
                              ? 'لا توجد فواتير اليوم'
                              : 'لا توجد جلسات منتهية',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: store.invoices.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (_, i) {
                        final inv = store.invoices[i];
                        return _TableRow(
                          cells: admin
                              ? [
                                  inv.deviceName,
                                  inv.customer,
                                  formatClock(inv.from),
                                  formatClock(inv.to),
                                  '${inv.billedMinutes} د',
                                  store.money(inv.timeCost),
                                  store.money(inv.cafeCost),
                                  inv.discount == 0
                                      ? '—'
                                      : store.money(inv.discount),
                                  store.money(inv.total),
                                  inv.staffName,
                                ]
                              : [
                                  inv.deviceName,
                                  inv.customer,
                                  formatClock(inv.from),
                                  formatClock(inv.to),
                                  '${inv.billedMinutes} د',
                                  inv.staffName,
                                ],
                          emphasizeLastMoney: admin,
                          badgeLast: admin,
                        );
                      },
                    ),
            ),
            // Show recent login/logout activity for owner/admin
            if (store.isOwner || store.isAdmin) ...[
              const SizedBox(height: 16),
              _Panel(
                title: 'سجل تسجيل الدخول والخروج',
                subtitle: 'آخر النشاطات',
                height: 200,
                child: Column(
                  children: [
                    Expanded(
                      child: store.loginLogs.isEmpty
                          ? const Center(
                              child: Text(
                                'لا يوجد سجل نشاط',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            )
                          : ListView.separated(
                              itemCount: store.loginLogs.length > 10 ? 10 : store.loginLogs.length,
                              separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (_, i) {
                                final log = store.loginLogs[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: log.event == ShiftEvent.login 
                                              ? AppColors.greenDim.withValues(alpha: 0.3)
                                              : AppColors.redDim.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          log.event == ShiftEvent.login 
                                              ? Icons.login 
                                              : Icons.logout,
                                          size: 16,
                                          color: log.event == ShiftEvent.login 
                                              ? AppColors.green 
                                              : AppColors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              log.employeeName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              log.role,
                                              style: TextStyle(
                                                color: AppColors.muted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            log.statusLabel,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: log.event == ShiftEvent.login 
                                                  ? AppColors.green 
                                                  : AppColors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            formatClock(log.at),
                                            style: TextStyle(
                                              color: AppColors.faint,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showShiftCloseDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const ShiftCloseDialog());
}

class ShiftCloseDialog extends StatelessWidget {
  const ShiftCloseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    // Improved worker detection
    final isWorkerUser = store.isWorker || store.currentWorkerName != null;
    final isAdminUser = store.isAdmin;
    
    return _ModalFrame(
      title: isAdminUser ? 'تقفيل اليوم' : 'تقفيل الشيفت',
      subtitle: isAdminUser ? 'ملخص الوردية الحالية' : 'إنهاء الوردية النشطة',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KV('عدد الفواتير', '${store.invoices.length}'),
          _KV('أجهزة شغّالة', '${store.activeCount}'),
          if (isAdminUser) ...[
            _KV('إيراد الوقت', store.money(store.timeRevenue)),
            _KV('إيراد الكافيه', store.money(store.cafeRevenue)),
            _KV('الخصومات', store.money(store.discountsTotal)),
            _KV('إجمالي التحصيل', store.money(store.todayRevenue)),
            _KV('المصروفات', store.money(store.expensesTotal)),
            _KV('صافي الربح', store.money(store.netProfit)),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ملخص الإيرادات والأرباح متاح للمدير فقط.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: isWorkerUser ? 'تأكيد تقفيل الشيفت' : 'تأكيد تقفيل اليوم',
            color: AppColors.green,
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final err = await store.closeShift();
              if (context.mounted) Navigator.pop(context);
              
              if (err != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.red,
                  ),
                );
              } else {
                // If worker closed shift, navigate to login screen automatically
                if (isWorkerUser && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoleLoginScreen(),
                    ),
                    (route) => false,
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم التقفيل — سجّل دخول مستخدم جديد',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inventory
// ---------------------------------------------------------------------------

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox.expand(
        child: _Panel(
          title: 'أصناف الكافيه',
          subtitle: 'أسعار البيع والشراء والكميات وتنبيه النقص',
          trailing: _AddBtn(
            label: '+ صنف',
            onTap: () => showAddItemDialog(context),
          ),
          child: Column(
            children: [
              const _TableHead(
                cells: [
                  'اسم الصنف',
                  'سعر البيع',
                  'سعر الشراء',
                  'الكمية المتاحة',
                  'حد التنبيه',
                  '',
                ],
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: store.cafeItems.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد أصناف',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: store.cafeItems.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (_, i) {
                          final item = store.cafeItems[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _MiniField(
                                    label: 'بيع',
                                    value: item.sell.toStringAsFixed(0),
                                    onChanged: (v) {
                                      item.sell =
                                          double.tryParse(v) ?? item.sell;
                                      store.updateCafeItem(item);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _MiniField(
                                    label: 'شراء',
                                    value: item.buy.toStringAsFixed(0),
                                    obscure: false,
                                    readOnly: false,
                                    onChanged: (v) {
                                      item.buy = double.tryParse(v) ?? item.buy;
                                      store.updateCafeItem(item);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _MiniField(
                                    label: 'كمية',
                                    value: '${item.stock}',
                                    onChanged: (v) {
                                      item.stock =
                                          int.tryParse(v) ?? item.stock;
                                      store.updateCafeItem(item);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _MiniField(
                                    label: 'تنبيه',
                                    value: '${item.alert}',
                                    onChanged: (v) {
                                      item.alert =
                                          int.tryParse(v) ?? item.alert;
                                      store.updateCafeItem(item);
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => store.removeCafeItem(item),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAddItemDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const AddItemDialog());
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final name = TextEditingController();
  final sell = TextEditingController(text: '10');
  final buy = TextEditingController(text: '5');
  final stock = TextEditingController(text: '20');
  final alert = TextEditingController(text: '5');

  @override
  void dispose() {
    name.dispose();
    sell.dispose();
    buy.dispose();
    stock.dispose();
    alert.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return _ModalFrame(
      title: 'صنف جديد',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkField(controller: name, label: 'اسم الصنف'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DarkField(
                  controller: sell,
                  label: 'سعر البيع',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DarkField(
                  controller: buy,
                  label: 'سعر الشراء',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DarkField(
                  controller: stock,
                  label: 'الكمية',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DarkField(
                  controller: alert,
                  label: 'حد التنبيه',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: 'حفظ',
            color: AppColors.purple,
            onTap: () {
              if (name.text.trim().isEmpty) return;
              store.addCafeItem(
                CafeItem(
                  id: newId('c'),
                  name: name.text.trim(),
                  sell: double.tryParse(sell.text) ?? 0,
                  buy: double.tryParse(buy.text) ?? 0,
                  stock: int.tryParse(stock.text) ?? 0,
                  alert: int.tryParse(alert.text) ?? 0,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    final best = _bestSellers(store);
    final perDevice = _deviceRevenue(store);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Monthly Revenue Analytics Button
        if (store.canViewRevenue)
          _Panel(
            title: 'تحليلات الإيراد الشهري',
            subtitle: 'آخر 30 يوم',
            height: 100,
            trailing: _AddBtn(
              label: 'عرض التقرير',
              onTap: () => showMonthlyRevenueDialog(context),
            ),
            child: Center(
              child: FutureBuilder<double>(
                future: store.sync.calculateMonthlyRevenue(store.storeCode ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: AppColors.purple);
                  }
                  final monthlyRevenue = snapshot.data ?? 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.money(monthlyRevenue),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'إجمالي الإيراد خلال آخر 30 يوم',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Metric(
              label: 'إيراد الوقت',
              value: store.money(store.timeRevenue),
              color: AppColors.green,
            ),
            _Metric(
              label: 'إيراد الكافيه',
              value: store.money(store.cafeRevenue),
              color: AppColors.cyan,
            ),
            _Metric(
              label: 'الخصومات',
              value: store.money(-store.discountsTotal),
              color: AppColors.red,
            ),
            _Metric(
              label: 'إجمالي التحصيل',
              value: store.money(store.todayRevenue),
              color: AppColors.green,
            ),
            _Metric(
              label: 'تكلفة البضاعة',
              value: store.money(store.cogs),
              color: AppColors.orange,
            ),
            _Metric(
              label: 'المصروفات',
              value: store.money(store.expensesTotal),
              color: AppColors.orange,
            ),
            _Metric(
              label: 'صافي الربح',
              value: store.money(store.netProfit),
              color: store.netProfit >= 0 ? AppColors.green : AppColors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Panel(
                title: 'الأكثر مبيعاً',
                height: 320,
                child: Column(
                  children: [
                    const _TableHead(
                      cells: ['الصنف', 'الكمية', 'الإيراد', 'الربح'],
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final row in best)
                            _SimpleRow([
                              row.$1,
                              '${row.$2}',
                              store.money(row.$3),
                              store.money(row.$4),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Panel(
                title: 'إيراد كل جهاز',
                height: 320,
                child: Column(
                  children: [
                    const _TableHead(
                      cells: ['الجهاز', 'الجلسات', 'إجمالي الدقائق', 'الإيراد'],
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final row in perDevice)
                            _SimpleRow([
                              row.$1,
                              '${row.$2}',
                              '${row.$3}',
                              store.money(row.$4),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Panel(
          title: 'سجل تسجيلات الدخول',
          subtitle: 'مزامنة مباشرة — يظهر لصاحب المحل من أي جهاز',
          height: 280,
          child: Column(
            children: [
              const _TableHead(cells: ['الموظف', 'الوقت', 'حالة الوردية']),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: store.loginLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تسجيلات دخول بعد',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: store.loginLogs.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (_, i) {
                          final log = store.loginLogs[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${log.employeeName} — ${log.role}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    formatClock(log.at),
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: log.event == ShiftEvent.login
                                        ? AppColors.greenDim
                                        : AppColors.purpleDim,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    log.statusLabel,
                                    style: TextStyle(
                                      color: log.event == ShiftEvent.login
                                          ? AppColors.green
                                          : const Color(0xFFDDD6FE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (store.canManageExpenses)
          _Panel(
            title: 'المصروفات',
            subtitle: 'تسجيل تكاليف اليوم',
            height: 280,
            trailing: _AddBtn(
              label: 'إضافة مصروف',
              onTap: () => showAddExpenseDialog(context),
            ),
            child: Column(
              children: [
                const _TableHead(cells: ['البند', 'المبلغ', 'الوقت', '']),
                const Divider(color: AppColors.border, height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: store.expenses.length,
                    itemBuilder: (_, i) {
                      final e = store.expenses[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                store.money(e.amount),
                                style: const TextStyle(color: AppColors.green),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                formatClock(e.at),
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ),
                            IconButton(
                              onPressed: () => store.removeExpense(e),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<(String, int, double, double)> _bestSellers(PosStore store) {
    final qty = <String, int>{};
    final rev = <String, double>{};
    final profit = <String, double>{};
    final names = {for (final c in store.cafeItems) c.id: c.name};
    final buy = {for (final c in store.cafeItems) c.id: c.buy};
    for (final inv in store.invoices) {
      for (final line in inv.cafeLines) {
        qty[line.itemId] = (qty[line.itemId] ?? 0) + line.qty;
        rev[line.itemId] = (rev[line.itemId] ?? 0) + line.lineTotal;
        profit[line.itemId] =
            (profit[line.itemId] ?? 0) +
            (line.unitPrice - (buy[line.itemId] ?? 0)) * line.qty;
      }
    }
    final ids = qty.keys.toList()
      ..sort((a, b) => (qty[b] ?? 0).compareTo(qty[a] ?? 0));
    return [
      for (final id in ids) (names[id] ?? id, qty[id]!, rev[id]!, profit[id]!),
    ];
  }

  List<(String, int, int, double)> _deviceRevenue(PosStore store) {
    final map = <String, (int, int, double)>{};
    for (final inv in store.invoices) {
      final prev = map[inv.deviceName] ?? (0, 0, 0.0);
      map[inv.deviceName] = (
        prev.$1 + 1,
        prev.$2 + inv.billedMinutes,
        prev.$3 + inv.total,
      );
    }
    final keys = map.keys.toList()
      ..sort((a, b) => map[b]!.$3.compareTo(map[a]!.$3));
    return [for (final k in keys) (k, map[k]!.$1, map[k]!.$2, map[k]!.$3)];
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showAddExpenseDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const AddExpenseDialog());
}

Future<void> showMonthlyRevenueDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const MonthlyRevenueDialog());
}

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final title = TextEditingController();
  final amount = TextEditingController();

  @override
  void dispose() {
    title.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return _ModalFrame(
      title: 'إضافة مصروف',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkField(controller: title, label: 'البند'),
          const SizedBox(height: 8),
          _DarkField(
            controller: amount,
            label: 'المبلغ',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: 'حفظ',
            color: AppColors.purple,
            onTap: () {
              final v = double.tryParse(amount.text) ?? 0;
              if (title.text.trim().isEmpty || v <= 0) return;
              store.addExpense(title.text.trim(), v);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Store Info Section
        _Panel(
          title: 'بيانات المحل',
          subtitle: 'اسم المحل والعملة',
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: _LiveField(
                  label: 'اسم المحل',
                  value: store.shopName,
                  onChanged: (v) => store.setShop(name: v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LiveField(
                  label: 'العملة',
                  value: store.currency,
                  onChanged: (v) => store.setShop(currencySymbol: v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Store Devices Section
        _Panel(
          title: 'أجهزة المحل',
          subtitle: 'الأجهزة والأسعار',
          height: 380,
          trailing: _AddBtn(
            label: '+ جهاز',
            onTap: () => showAddDeviceDialog(context),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: store.devices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = store.devices[i];
              return _ListTileRow(
                leading: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.greenDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tv,
                        color: AppColors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 140,
                      child: _MiniField(
                        label: 'الاسم',
                        value: d.name,
                        onChanged: (v) => store.updateDevice(d, name: v),
                      ),
                    ),
                  ],
                ),
                children: [
                  _MiniField(
                    label: 'فردي',
                    value: d.singleRate.toStringAsFixed(0),
                    onChanged: (v) =>
                        store.updateDevice(d, single: double.tryParse(v)),
                  ),
                  _MiniField(
                    label: 'زوجي',
                    value: d.multiRate.toStringAsFixed(0),
                    onChanged: (v) =>
                        store.updateDevice(d, multi: double.tryParse(v)),
                  ),
                  _MiniField(
                    label: 'ماتش فردي',
                    value: d.matchSingleRate.toStringAsFixed(0),
                    onChanged: (v) =>
                        store.updateDevice(d, matchSingle: double.tryParse(v)),
                  ),
                  _MiniField(
                    label: 'ماتش زوجي',
                    value: d.matchMultiRate.toStringAsFixed(0),
                    onChanged: (v) =>
                        store.updateDevice(d, matchMulti: double.tryParse(v)),
                  ),
                ],
                onDelete: () {
                  final err = store.removeDevice(d);
                  if (err != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(err)));
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Subscription Section
        _Panel(
          title: 'الاشتراك',
          subtitle: 'حالة الاشتراك وتاريخ الانتهاء',
          height: 110,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      store.isSubscriptionExpired ? Icons.warning : Icons.card_membership,
                      color: store.isSubscriptionExpired ? AppColors.red : AppColors.purple,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.isSubscriptionExpired ? 'الاشتراك منتهي' : 'الاشتراك نشط',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: store.isSubscriptionExpired ? AppColors.red : AppColors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Always show expiry date if available
                    if (store.expiryDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: store.isSubscriptionExpired 
                              ? AppColors.redDim.withValues(alpha: 0.3)
                              : AppColors.purpleDim.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: store.isSubscriptionExpired ? AppColors.red : AppColors.purple,
                          ),
                        ),
                        child: Text(
                          formatDate(store.expiryDate!),
                          style: TextStyle(
                            color: store.isSubscriptionExpired ? AppColors.red : AppColors.purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.muted),
                        ),
                        child: const Text(
                          'غير محدد',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                if (store.daysUntilExpiry <= 7 && !store.isSubscriptionExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orangeDim.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppColors.orange, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'ينتهي خلال ${store.daysUntilExpiry} أيام',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (store.isSubscriptionExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.redDim.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppColors.red, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'الاشتراك منتهي',
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Employees & Access PINs Section
        _Panel(
          title: 'الموظفين وأكواد الدخول',
          subtitle:
              'لكل واحد شغال عندك داخل الكاشير الخاص - والتواير النقل السفة.',
          height: 300,
          trailing: _AddBtn(
            label: '+ موظف جديد',
            onTap: () => showAddEmployeeDialog(context),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'الكود 5 أرقام لكل شخص ولازم يكون مختلف عن باقي الأكواد. لازم يفضل صاحب محل واحد على الأقل',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: store.employees.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final e = store.employees[i];
                    return _ListTileRow(
                      leading: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: e.isOwner
                                  ? AppColors.purpleDim
                                  : AppColors.greenDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              e.isOwner
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: e.isOwner
                                  ? const Color(0xFFDDD6FE)
                                  : AppColors.green,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniField(
                              label: 'الاسم',
                              value: e.name,
                              onChanged: (v) {
                                final updated = Employee(
                                  id: e.id,
                                  name: v,
                                  role: e.role,
                                  code: e.code,
                                  isOwner: e.isOwner,
                                );
                                store.updateEmployee(updated);
                              },
                            ),
                          ),
                        ],
                      ),
                      children: [
                        _MiniField(
                          label: 'الدور',
                          value: e.isOwner ? 'صاحب المحل' : 'موظف',
                          readOnly: true, // Role editing not supported in UI
                        ),
                        _MiniField(
                          label: 'الكود',
                          value: e.code,
                          onChanged: (v) {
                            if (v.length == 5) {
                              final updated = Employee(
                                id: e.id,
                                name: e.name,
                                role: e.role,
                                code: v,
                                isOwner: e.isOwner,
                              );
                              store.updateEmployee(updated);
                            }
                          },
                        ),
                      ],
                      onDelete: () {
                        final err = store.removeEmployee(e);
                        if (err != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const AboutAppPanel(),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.purple
            : AppColors.border,
      ),
      onChanged: onChanged,
    );
  }
}

Future<void> showAddDeviceDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const AddDeviceDialog());
}

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final name = TextEditingController();
  final single = TextEditingController(text: '40');
  final multi = TextEditingController(text: '70');
  final matchSingle = TextEditingController(text: '5');
  final matchMulti = TextEditingController(text: '8');

  @override
  void dispose() {
    name.dispose();
    single.dispose();
    multi.dispose();
    matchSingle.dispose();
    matchMulti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return _ModalFrame(
      title: 'جهاز جديد',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkField(controller: name, label: 'اسم الجهاز'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DarkField(
                  controller: single,
                  label: 'سعر الفردي',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DarkField(
                  controller: multi,
                  label: 'سعر الزوجي',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DarkField(
                  controller: matchSingle,
                  label: 'سعر الماتش الفردي',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DarkField(
                  controller: matchMulti,
                  label: 'سعر الماتش الزوجي',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: 'إضافة',
            color: AppColors.purple,
            onTap: () {
              if (name.text.trim().isEmpty) return;
              store.addDevice(
                name.text.trim(),
                double.tryParse(single.text) ?? 40,
                double.tryParse(multi.text) ?? 70,
                matchSingle: double.tryParse(matchSingle.text) ?? 5,
                matchMulti: double.tryParse(matchMulti.text) ?? 8,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showAddEmployeeDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const AddEmployeeDialog(),
  );
}

class AddEmployeeDialog extends StatefulWidget {
  const AddEmployeeDialog({super.key});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final name = TextEditingController();
  String selectedRole = 'موظف';
  final code = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);
    return _ModalFrame(
      title: 'موظف جديد',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DarkField(controller: name, label: 'الاسم'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardInner,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                items: const [
                  DropdownMenuItem(value: 'موظف', child: Text('موظف')),
                  DropdownMenuItem(
                    value: 'صاحب المحل',
                    child: Text('صاحب المحل'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value ?? 'موظف';
                  });
                },
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.text),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DarkField(
            controller: code,
            label: 'كود الدخول (5 أرقام)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _ActionBtn(
            label: 'حفظ',
            color: AppColors.purple,
            onTap: () {
              if (name.text.trim().isEmpty || code.text.length != 5) return;
              store.addEmployee(
                Employee(
                  id: newId('e'),
                  name: name.text.trim(),
                  role: selectedRole,
                  code: code.text.trim(),
                  isOwner: selectedRole == 'صاحب المحل',
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared UI
// ---------------------------------------------------------------------------

class _ModalFrame extends StatelessWidget {
  const _ModalFrame({
    required this.title,
    required this.child,
    this.subtitle,
    this.width = 440,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                _SquareIcon(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class LoginLogsPage extends StatelessWidget {
  const LoginLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PosScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Panel(
          title: 'سجل تسجيلات الدخول',
          subtitle: 'مزامنة مباشرة — يظهر لصاحب المحل من أي جهاز',
          height: 600,
          child: Column(
            children: [
              const _TableHead(cells: ['الموظف', 'الوقت', 'حالة الوردية']),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: store.loginLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تسجيلات دخول بعد',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: store.loginLogs.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (_, i) {
                          final log = store.loginLogs[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${log.employeeName} — ${log.role}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    formatClock(log.at),
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: log.event == ShiftEvent.login
                                        ? AppColors.greenDim
                                        : AppColors.purpleDim,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    log.statusLabel,
                                    style: TextStyle(
                                      color: log.event == ShiftEvent.login
                                          ? AppColors.green
                                          : const Color(0xFFDDD6FE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.height,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              ...trailing != null ? [trailing!] : [],
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
    if (height != null) return SizedBox(height: height, child: body);
    return body;
  }
}

class _AddBtn extends StatelessWidget {
  const _AddBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    this.controller,
    this.label,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        filled: true,
        fillColor: AppColors.cardInner,
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.faint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
    );
  }
}

class _LiveField extends StatefulWidget {
  const _LiveField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_LiveField> createState() => _LiveFieldState();
}

class _LiveFieldState extends State<_LiveField> {
  late final controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _LiveField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && controller.text != widget.value) {
      controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DarkField(
      controller: controller,
      label: widget.label,
      onChanged: widget.onChanged,
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late final controller = TextEditingController(text: widget.value);
  bool _obscureText = true;
  bool _hasChanged = false;

  @override
  void didUpdateWidget(covariant _PasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && controller.text != widget.value) {
      controller.text = widget.value;
      _hasChanged = false;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('تأكيد تغيير كلمة السر'),
        content: const Text('هل أنت متأكد من تغيير كلمة السر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تأكيد',
              style: TextStyle(color: AppColors.purple),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onChanged(controller.text);
      setState(() => _hasChanged = false);
    } else if (mounted) {
      controller.text = widget.value;
      setState(() => _hasChanged = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: _obscureText,
      onChanged: (value) {
        setState(() {
          _hasChanged = value != widget.value;
        });
      },
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
        filled: true,
        fillColor: AppColors.cardInner,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            if (_hasChanged)
              IconButton(
                icon: const Icon(Icons.check, color: AppColors.green),
                onPressed: _showConfirmationDialog,
              ),
          ],
        ),
      ),
      style: const TextStyle(color: AppColors.text),
    );
  }
}

class _MiniField extends StatefulWidget {
  const _MiniField({
    required this.label,
    required this.value,
    this.onChanged,
    this.obscure = false,
    this.readOnly = false,
  });

  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool readOnly;

  @override
  State<_MiniField> createState() => _MiniFieldState();
}

class _MiniFieldState extends State<_MiniField> {
  late final controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _MiniField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && controller.text != widget.value) {
      controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: TextField(
        controller: controller,
        obscureText: widget.obscure,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          filled: true,
          fillColor: AppColors.cardInner,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _ListTileRow extends StatelessWidget {
  const _ListTileRow({
    required this.leading,
    required this.children,
    this.onDelete,
  });

  final Widget leading;
  final List<Widget> children;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: leading),
          ...children.map(
            (w) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: w,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: onDelete == null ? AppColors.faint : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead({required this.cells});
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          for (final c in cells)
            Expanded(
              child: Text(
                c,
                style: const TextStyle(
                  color: AppColors.faint,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.cells,
    this.emphasizeLastMoney = false,
    this.badgeLast = false,
  });

  final List<String> cells;
  final bool emphasizeLastMoney;
  final bool badgeLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              child: i == cells.length - 1 && badgeLast
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x22EAB308),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          cells[i],
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      cells[i],
                      style: TextStyle(
                        color: emphasizeLastMoney && i == cells.length - 2
                            ? AppColors.green
                            : AppColors.text,
                        fontWeight: emphasizeLastMoney && i == cells.length - 2
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow(this.cells);
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              child: Text(
                cells[i],
                style: TextStyle(
                  color: i >= 2 ? AppColors.green : AppColors.text,
                  fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
