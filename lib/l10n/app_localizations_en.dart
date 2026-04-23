// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TaskFlow';

  @override
  String get tasks => 'Tasks';

  @override
  String get projects => 'Projects';

  @override
  String get profile => 'Profile';

  @override
  String get newTask => 'New Task';

  @override
  String get newProject => 'New Project';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get dueDate => 'Due Date';

  @override
  String get assignTo => 'Assign To';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get color => 'Color';

  @override
  String get createProject => 'Create Project';

  @override
  String get tapCreateFirstProject => 'Tap + to create your first project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String deleteProjectConfirmation(Object name) {
    return 'Delete \"$name\"? All tasks will be deleted too.';
  }

  @override
  String get addFirstTask => 'Add First Task';

  @override
  String get total => 'Total';

  @override
  String get done => 'Done';

  @override
  String get overdue => 'Overdue';
}
