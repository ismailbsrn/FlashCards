import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Collections tab label
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Study settings section title
  ///
  /// In en, this message translates to:
  /// **'Study Settings'**
  String get studySettings;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Welcome back text
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Study now button text
  ///
  /// In en, this message translates to:
  /// **'Study Now'**
  String get studyNow;

  /// Total decks label
  ///
  /// In en, this message translates to:
  /// **'Total Decks'**
  String get totalDecks;

  /// Total cards label
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// Due today label
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// Studied today label
  ///
  /// In en, this message translates to:
  /// **'Studied Today'**
  String get studiedToday;

  /// Study activity label
  ///
  /// In en, this message translates to:
  /// **'Study Activity (Last 30 Days)'**
  String get studyActivity;

  /// Your decks label
  ///
  /// In en, this message translates to:
  /// **'Your Decks'**
  String get yourDecks;

  /// View all collections button text
  ///
  /// In en, this message translates to:
  /// **'View All Collections'**
  String get viewAllCollections;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No decks label
  ///
  /// In en, this message translates to:
  /// **'No Decks'**
  String get noDecks;

  /// Create deck button text
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeck;

  /// Select study decks button text
  ///
  /// In en, this message translates to:
  /// **'Select Study Decks'**
  String get selectStudyDecks;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No collections label
  ///
  /// In en, this message translates to:
  /// **'No Collections'**
  String get noCollections;

  /// Create collection to start studying label
  ///
  /// In en, this message translates to:
  /// **'Create a collection to start studying'**
  String get createCollectionToStartStudying;

  /// Study all due cards button text
  ///
  /// In en, this message translates to:
  /// **'Study All Due Cards'**
  String get studyAllDueCards;

  /// Filters label
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// All label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Due label
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// Studied label
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get studied;

  /// Filter by tags label
  ///
  /// In en, this message translates to:
  /// **'Filter by Tags'**
  String get filterByTags;

  /// New label
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get labelNew;

  /// Learning label
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// Filter by card type label
  ///
  /// In en, this message translates to:
  /// **'Filter by Card Type'**
  String get filterByCardType;

  /// Please select at least one collection label
  ///
  /// In en, this message translates to:
  /// **'Please select at least one collection'**
  String get pleaseSelectAtLeastOneCollection;

  /// Card count with filter label
  ///
  /// In en, this message translates to:
  /// **'{count} {filter} {count, plural, =1{card} other{cards}}'**
  String cardCountWithFilter(int count, String filter);

  /// No cards with filter label
  ///
  /// In en, this message translates to:
  /// **'No {filter} cards'**
  String noCardsWithFilter(String filter);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @displayNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Display Name (Optional)'**
  String get displayNameOptional;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetYourPassword;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get enterEmailForReset;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists with this email, you will receive a password reset link.'**
  String get resetEmailSent;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @noUserData.
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get noUserData;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @lastSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSyncLabel;

  /// No description provided for @pendingSyncItems.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync Items'**
  String get pendingSyncItems;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @pendingItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending items'**
  String pendingItemsCount(int count);

  /// No description provided for @clearSyncQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear Sync Queue'**
  String get clearSyncQueue;

  /// No description provided for @clearSyncQueueConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all pending sync items? This action cannot be undone.'**
  String get clearSyncQueueConfirm;

  /// No description provided for @removePendingSyncItems.
  ///
  /// In en, this message translates to:
  /// **'Remove all pending sync items'**
  String get removePendingSyncItems;

  /// No description provided for @syncQueueCleared.
  ///
  /// In en, this message translates to:
  /// **'Sync queue cleared'**
  String get syncQueueCleared;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @deleteCards.
  ///
  /// In en, this message translates to:
  /// **'Delete Cards'**
  String get deleteCards;

  /// No description provided for @deleteCardsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} card(s)? This action cannot be undone.'**
  String deleteCardsConfirm(int count);

  /// No description provided for @cardsDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cards deleted successfully'**
  String get cardsDeletedSuccessfully;

  /// No description provided for @deleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Delete Collection'**
  String get deleteCollection;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteCollectionConfirm(String name);

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get editCollection;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTooltip;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String exportedTo(String path);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get noCardsYet;

  /// No description provided for @addFirstFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Add your first flashcard'**
  String get addFirstFlashcard;

  /// No description provided for @searchCards.
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchCards;

  /// No description provided for @cardsOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{filtered} of {total} cards'**
  String cardsOfTotal(int filtered, int total);

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get noCardsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @cancelWithCount.
  ///
  /// In en, this message translates to:
  /// **'Cancel ({count})'**
  String cancelWithCount(int count);

  /// No description provided for @unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect all'**
  String get unselectAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deleteSelected;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @noCollectionsYet.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollectionsYet;

  /// No description provided for @createFirstCollection.
  ///
  /// In en, this message translates to:
  /// **'Create your first collection to get started'**
  String get createFirstCollection;

  /// No description provided for @deleteCollections.
  ///
  /// In en, this message translates to:
  /// **'Delete Collections'**
  String get deleteCollections;

  /// No description provided for @deleteCollectionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} collection(s)? This action cannot be undone.'**
  String deleteCollectionsConfirm(int count);

  /// No description provided for @collectionsDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Collections deleted successfully'**
  String get collectionsDeletedSuccessfully;

  /// No description provided for @exportCollections.
  ///
  /// In en, this message translates to:
  /// **'Export collections'**
  String get exportCollections;

  /// No description provided for @exportedCollections.
  ///
  /// In en, this message translates to:
  /// **'Exported {success} collection(s){failed}'**
  String exportedCollections(int success, String failed);

  /// No description provided for @studyCollection.
  ///
  /// In en, this message translates to:
  /// **'Study Collection'**
  String get studyCollection;

  /// No description provided for @cardsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} cards left'**
  String cardsLeft(int count);

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @cardsReviewedToday.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reviewed {count} cards today'**
  String cardsReviewedToday(int count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noCardsToStudy.
  ///
  /// In en, this message translates to:
  /// **'No cards to study'**
  String get noCardsToStudy;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToReveal;

  /// No description provided for @fromCollection.
  ///
  /// In en, this message translates to:
  /// **'From: {name}'**
  String fromCollection(String name);

  /// No description provided for @timeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Time: {seconds}s'**
  String timeSeconds(int seconds);

  /// No description provided for @howWellDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'How well did you know this?'**
  String get howWellDidYouKnow;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @createCollection.
  ///
  /// In en, this message translates to:
  /// **'Create Collection'**
  String get createCollection;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @syncTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTooltip;

  /// No description provided for @importCollections.
  ///
  /// In en, this message translates to:
  /// **'Import Collections'**
  String get importCollections;

  /// No description provided for @importedCollections.
  ///
  /// In en, this message translates to:
  /// **'Imported {collections} collection(s) with {cards} card(s){failed}'**
  String importedCollections(int collections, int cards, String failed);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @noMatchingFilters.
  ///
  /// In en, this message translates to:
  /// **'No collections match filters'**
  String get noMatchingFilters;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// No description provided for @studyDecksCount.
  ///
  /// In en, this message translates to:
  /// **'Study {count} {count, plural, =1{deck} other{decks}}'**
  String studyDecksCount(int count);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateYourInfo.
  ///
  /// In en, this message translates to:
  /// **'Update Your Information'**
  String get updateYourInfo;

  /// No description provided for @changeDisplayOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Change your display name or email address'**
  String get changeDisplayOrEmail;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterDisplayName;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your email has been changed. Please check your new email for a verification link, then login again.'**
  String get emailVerificationMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @displayNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters'**
  String get displayNameMinLength;

  /// No description provided for @emailChangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing your email will require verification. You will be logged out and must verify your new email before logging in again.'**
  String get emailChangeWarning;

  /// No description provided for @changeYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Your Password'**
  String get changeYourPassword;

  /// No description provided for @enterCurrentAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new one'**
  String get enterCurrentAndNewPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmYourNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmYourNewPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @pleaseConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmNewPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @passwordLengthInfo.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get passwordLengthInfo;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get failedToLoadSettings;

  /// No description provided for @maxReviewsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Maximum Reviews Per Day'**
  String get maxReviewsPerDay;

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(int count);

  /// No description provided for @maxNewCardsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Maximum New Cards Per Day'**
  String get maxNewCardsPerDay;

  /// No description provided for @showAnswerTimer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer Timer'**
  String get showAnswerTimer;

  /// No description provided for @displayTimeTakenToAnswer.
  ///
  /// In en, this message translates to:
  /// **'Display time taken to answer'**
  String get displayTimeTakenToAnswer;

  /// No description provided for @showIntervalButtons.
  ///
  /// In en, this message translates to:
  /// **'Show Interval Buttons'**
  String get showIntervalButtons;

  /// No description provided for @displayNextReviewIntervals.
  ///
  /// In en, this message translates to:
  /// **'Display next review intervals under buttons'**
  String get displayNextReviewIntervals;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @flashcardsApp.
  ///
  /// In en, this message translates to:
  /// **'Flashcards App'**
  String get flashcardsApp;

  /// No description provided for @offlineFirstFlashcardApp.
  ///
  /// In en, this message translates to:
  /// **'An offline-first flashcard application'**
  String get offlineFirstFlashcardApp;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Danger zone section title
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Delete account button text
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone. All your collections, cards, and study progress will be permanently deleted.'**
  String get deleteAccountConfirm;

  /// Password confirmation prompt
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get enterPasswordToConfirm;

  /// Delete account success message
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// Delete account failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get deleteAccountFailed;

  /// Deleting progress text
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
