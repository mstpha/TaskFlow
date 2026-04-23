// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تاسك فلو';

  @override
  String get tasks => 'المهام';

  @override
  String get projects => 'المشاريع';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get newProject => 'مشروع جديد';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get title => 'العنوان';

  @override
  String get description => 'الوصف';

  @override
  String get status => 'الحالة';

  @override
  String get priority => 'الأولوية';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get assignTo => 'تعيين إلى';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noTasksYet => 'لا توجد مهام بعد';

  @override
  String get noProjectsYet => 'لا توجد مشاريع بعد';

  @override
  String get color => 'اللون';

  @override
  String get createProject => 'إنشاء مشروع';

  @override
  String get tapCreateFirstProject => 'اضغط + لإنشاء المشروع الأول';

  @override
  String get deleteProject => 'حذف المشروع';

  @override
  String deleteProjectConfirmation(Object name) {
    return 'هل تريد حذف \"$name\"؟ سيتم حذف جميع المهام أيضًا.';
  }

  @override
  String get addFirstTask => 'إضافة المهمة الأولى';

  @override
  String get total => 'المجموع';

  @override
  String get done => 'مكتمل';

  @override
  String get overdue => 'متأخر';
}
