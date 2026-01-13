// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get collections => 'Collections';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get studySettings => 'Study Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get language => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get studyNow => 'Study Now';

  @override
  String get totalDecks => 'Total Decks';

  @override
  String get totalCards => 'Total Cards';

  @override
  String get dueToday => 'Due Today';

  @override
  String get studiedToday => 'Studied Today';

  @override
  String get studyActivity => 'Study Activity (Last 30 Days)';

  @override
  String get yourDecks => 'Your Decks';

  @override
  String get viewAllCollections => 'View All Collections';

  @override
  String get viewAll => 'View All';

  @override
  String get noDecks => 'No Decks';

  @override
  String get createDeck => 'Create Deck';

  @override
  String get selectStudyDecks => 'Select Study Decks';

  @override
  String get retry => 'Retry';

  @override
  String get noCollections => 'No Collections';

  @override
  String get createCollectionToStartStudying =>
      'Create a collection to start studying';

  @override
  String get studyAllDueCards => 'Study All Due Cards';

  @override
  String get filters => 'Filters';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get due => 'Due';

  @override
  String get studied => 'Studied';

  @override
  String get filterByTags => 'Filter by Tags';

  @override
  String get labelNew => 'New';

  @override
  String get learning => 'Learning';

  @override
  String get filterByCardType => 'Filter by Card Type';

  @override
  String get pleaseSelectAtLeastOneCollection =>
      'Please select at least one collection';

  @override
  String cardCountWithFilter(int count, String filter) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cards',
      one: 'card',
    );
    return '$count $filter $_temp0';
  }

  @override
  String noCardsWithFilter(String filter) {
    return 'No $filter cards';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get displayNameOptional => 'Display Name (Optional)';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetYourPassword => 'Reset Your Password';

  @override
  String get enterEmailForReset =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get resetEmailSent =>
      'If an account exists with this email, you will receive a password reset link.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get noUserData => 'No user data available';

  @override
  String get displayName => 'Display Name';

  @override
  String get notSet => 'Not set';

  @override
  String get user => 'User';

  @override
  String get memberSince => 'Member Since';

  @override
  String get lastSyncLabel => 'Last Sync';

  @override
  String get pendingSyncItems => 'Pending Sync Items';

  @override
  String get loadingText => 'Loading...';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String pendingItemsCount(int count) {
    return '$count pending items';
  }

  @override
  String get clearSyncQueue => 'Clear Sync Queue';

  @override
  String get clearSyncQueueConfirm =>
      'Are you sure you want to clear all pending sync items? This action cannot be undone.';

  @override
  String get removePendingSyncItems => 'Remove all pending sync items';

  @override
  String get syncQueueCleared => 'Sync queue cleared';

  @override
  String get changePassword => 'Change Password';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncCompleted => 'Sync completed successfully';

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get clear => 'Clear';

  @override
  String get deleteCards => 'Delete Cards';

  @override
  String deleteCardsConfirm(int count) {
    return 'Are you sure you want to delete $count card(s)? This action cannot be undone.';
  }

  @override
  String get cardsDeletedSuccessfully => 'Cards deleted successfully';

  @override
  String get deleteCollection => 'Delete Collection';

  @override
  String deleteCollectionConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get editCollection => 'Edit Collection';

  @override
  String get exportTooltip => 'Export';

  @override
  String exportedTo(String path) {
    return 'Exported to $path';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get noCardsYet => 'No cards yet';

  @override
  String get addFirstFlashcard => 'Add your first flashcard';

  @override
  String get searchCards => 'Search cards...';

  @override
  String cardsOfTotal(int filtered, int total) {
    return '$filtered of $total cards';
  }

  @override
  String get noCardsFound => 'No cards found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get study => 'Study';

  @override
  String cancelWithCount(int count) {
    return 'Cancel ($count)';
  }

  @override
  String get unselectAll => 'Unselect all';

  @override
  String get selectAll => 'Select all';

  @override
  String get deleteSelected => 'Delete selected';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get tags => 'Tags';

  @override
  String get addTag => 'Add tag';

  @override
  String get color => 'Color';

  @override
  String get noCollectionsYet => 'No collections yet';

  @override
  String get createFirstCollection =>
      'Create your first collection to get started';

  @override
  String get deleteCollections => 'Delete Collections';

  @override
  String deleteCollectionsConfirm(int count) {
    return 'Are you sure you want to delete $count collection(s)? This action cannot be undone.';
  }

  @override
  String get collectionsDeletedSuccessfully =>
      'Collections deleted successfully';

  @override
  String get exportCollections => 'Export collections';

  @override
  String exportedCollections(int success, String failed) {
    return 'Exported $success collection(s)$failed';
  }

  @override
  String get studyCollection => 'Study Collection';

  @override
  String cardsLeft(int count) {
    return '$count cards left';
  }

  @override
  String get greatJob => 'Great job!';

  @override
  String cardsReviewedToday(int count) {
    return 'You\'ve reviewed $count cards today';
  }

  @override
  String get done => 'Done';

  @override
  String get noCardsToStudy => 'No cards to study';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Answer';

  @override
  String get tapToReveal => 'Tap to reveal';

  @override
  String fromCollection(String name) {
    return 'From: $name';
  }

  @override
  String timeSeconds(int seconds) {
    return 'Time: ${seconds}s';
  }

  @override
  String get howWellDidYouKnow => 'How well did you know this?';

  @override
  String get wrong => 'Wrong';

  @override
  String get hard => 'Hard';

  @override
  String get good => 'Good';

  @override
  String get easy => 'Easy';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get createCollection => 'Create Collection';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get syncTooltip => 'Sync';

  @override
  String get importCollections => 'Import Collections';

  @override
  String importedCollections(int collections, int cards, String failed) {
    return 'Imported $collections collection(s) with $cards card(s)$failed';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get start => 'Start';

  @override
  String get noMatchingFilters => 'No collections match filters';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters';

  @override
  String studyDecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'decks',
      one: 'deck',
    );
    return 'Study $count $_temp0';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateYourInfo => 'Update Your Information';

  @override
  String get changeDisplayOrEmail =>
      'Change your display name or email address';

  @override
  String get enterDisplayName => 'Enter your display name';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get emailVerificationRequired => 'Email Verification Required';

  @override
  String get emailVerificationMessage =>
      'Your email has been changed. Please check your new email for a verification link, then login again.';

  @override
  String get ok => 'OK';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get displayNameMinLength =>
      'Display name must be at least 2 characters';

  @override
  String get emailChangeWarning =>
      'Changing your email will require verification. You will be logged out and must verify your new email before logging in again.';

  @override
  String get changeYourPassword => 'Change Your Password';

  @override
  String get enterCurrentAndNewPassword =>
      'Enter your current password and choose a new one';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmYourNewPassword => 'Confirm your new password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMinLength8 => 'Password must be at least 8 characters';

  @override
  String get newPasswordMustBeDifferent =>
      'New password must be different from current password';

  @override
  String get pleaseConfirmNewPassword => 'Please confirm your new password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully!';

  @override
  String get failedToChangePassword => 'Failed to change password';

  @override
  String get passwordLengthInfo =>
      'Password must be at least 8 characters long';

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String get maxReviewsPerDay => 'Maximum Reviews Per Day';

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String get maxNewCardsPerDay => 'Maximum New Cards Per Day';

  @override
  String get showAnswerTimer => 'Show Answer Timer';

  @override
  String get displayTimeTakenToAnswer => 'Display time taken to answer';

  @override
  String get showIntervalButtons => 'Show Interval Buttons';

  @override
  String get displayNextReviewIntervals =>
      'Display next review intervals under buttons';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get account => 'Account';

  @override
  String get never => 'Never';

  @override
  String get flashcardsApp => 'Flashcards App';

  @override
  String get offlineFirstFlashcardApp =>
      'An offline-first flashcard application';

  @override
  String get value => 'Value';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }
}
