// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'TaskFlow';

  @override
  String get tasks => 'Tâches';

  @override
  String get projects => 'Projets';

  @override
  String get profile => 'Profil';

  @override
  String get newTask => 'Nouvelle Tâche';

  @override
  String get newProject => 'Nouveau Projet';

  @override
  String get signIn => 'Se Connecter';

  @override
  String get signOut => 'Se Déconnecter';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get fullName => 'Nom complet';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get title => 'Titre';

  @override
  String get description => 'Description';

  @override
  String get status => 'Statut';

  @override
  String get priority => 'Priorité';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get assignTo => 'Assigner à';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get noTasksYet => 'Aucune tâche pour l\'instant';

  @override
  String get noProjectsYet => 'Aucun projet pour l\'instant';

  @override
  String get color => 'Couleur';

  @override
  String get createProject => 'Créer un projet';

  @override
  String get tapCreateFirstProject => 'Appuyez sur + pour créer votre premier projet';

  @override
  String get deleteProject => 'Supprimer le projet';

  @override
  String deleteProjectConfirmation(Object name) {
    return 'Supprimer \"$name\" ? Toutes les tâches seront également supprimées.';
  }

  @override
  String get addFirstTask => 'Ajouter la première tâche';

  @override
  String get total => 'Total';

  @override
  String get done => 'Terminé';

  @override
  String get overdue => 'En retard';
}
