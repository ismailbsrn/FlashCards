// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get home => 'Ana Sayfa';

  @override
  String get collections => 'Koleksiyonlar';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get studySettings => 'Çalışma Ayarları';

  @override
  String get appearance => 'Görünüm';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Sürüm';

  @override
  String get language => 'Dil';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get create => 'Oluştur';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get welcomeBack => 'Hoş Geldiniz!';

  @override
  String get studyNow => 'Çalış';

  @override
  String get totalDecks => 'Toplam Koleksiyon';

  @override
  String get totalCards => 'Toplam Kart';

  @override
  String get dueToday => 'Bugünkü';

  @override
  String get studiedToday => 'Bugünkü Çalışma';

  @override
  String get studyActivity => 'Çalışma Aktivitesi (Son 30 Gün)';

  @override
  String get yourDecks => 'Koleksiyonlarınız';

  @override
  String get viewAllCollections => 'Tüm Koleksiyonları Görüntüle';

  @override
  String get viewAll => 'Tümü';

  @override
  String get noDecks => 'Henüz Koleksiyon Oluşturulmamış';

  @override
  String get createDeck => 'Başlamak için bir koleksiyon oluşturun';

  @override
  String get selectStudyDecks => 'Çalışma Koleksiyonlarını Seç';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get noCollections => 'Henüz Koleksiyon Oluşturulmamış';

  @override
  String get createCollectionToStartStudying =>
      'Başlamak için bir koleksiyon oluşturun';

  @override
  String get studyAllDueCards => 'Tümü';

  @override
  String get filters => 'Filtreler';

  @override
  String get search => 'Ara';

  @override
  String get all => 'Tümü';

  @override
  String get due => 'Bugünkü';

  @override
  String get studied => 'Çalışılan';

  @override
  String get filterByTags => 'Etiketler';

  @override
  String get labelNew => 'Yeni';

  @override
  String get learning => 'Öğrenme';

  @override
  String get filterByCardType => 'Kart Türüne Göre Filtrele';

  @override
  String get pleaseSelectAtLeastOneCollection =>
      'Lütfen en az bir koleksiyon seçin';

  @override
  String cardCountWithFilter(int count, String filter) {
    return '$count $filter kart';
  }

  @override
  String noCardsWithFilter(String filter) {
    return '$filter kart yok';
  }

  @override
  String get login => 'Giriş';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get displayNameOptional => 'Görünen Ad (İsteğe Bağlı)';

  @override
  String get forgotPasswordQuestion => 'Şifrenizi mi unuttunuz?';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get sendResetLink => 'Sıfırlama Bağlantısı Gönder';

  @override
  String get backToLogin => 'Girişe Dön';

  @override
  String get resetYourPassword => 'Şifrenizi Sıfırlayın';

  @override
  String get enterEmailForReset =>
      'E-posta adresinizi girin, size şifre sıfırlama bağlantısı göndereceğiz.';

  @override
  String get resetEmailSent =>
      'Bu e-posta ile bir hesap varsa, şifre sıfırlama bağlantısı alacaksınız.';

  @override
  String get pleaseEnterEmail => 'Lütfen e-postanızı girin';

  @override
  String get pleaseEnterValidEmail => 'Lütfen geçerli bir e-posta girin';

  @override
  String get pleaseEnterPassword => 'Lütfen şifrenizi girin';

  @override
  String get pleaseEnterAPassword => 'Lütfen bir şifre girin';

  @override
  String get pleaseConfirmPassword => 'Lütfen şifrenizi onaylayın';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get loginFailed => 'Giriş başarısız';

  @override
  String get registrationFailed => 'Kayıt başarısız';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? Kayıt olun';

  @override
  String get enterYourEmail => 'E-postanızı girin';

  @override
  String get noUserData => 'Kullanıcı bilgisi bulunamadı';

  @override
  String get displayName => 'Görünen Ad';

  @override
  String get notSet => 'Ayarlanmamış';

  @override
  String get user => 'Kullanıcı';

  @override
  String get memberSince => 'Üyelik Tarihi';

  @override
  String get lastSyncLabel => 'Son Senkronizasyon';

  @override
  String get pendingSyncItems => 'Bekleyen Senkronizasyon';

  @override
  String get loadingText => 'Yükleniyor...';

  @override
  String itemsCount(int count) {
    return '$count öğe';
  }

  @override
  String pendingItemsCount(int count) {
    return '$count bekleyen öğe';
  }

  @override
  String get clearSyncQueue => 'Senkronizasyon Kuyruğunu Temizle';

  @override
  String get clearSyncQueueConfirm =>
      'Tüm bekleyen senkronizasyon öğelerini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get removePendingSyncItems =>
      'Tüm bekleyen senkronizasyon öğelerini kaldır';

  @override
  String get syncQueueCleared => 'Senkronizasyon kuyruğu temizlendi';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get syncNow => 'Şimdi Senkronize Et';

  @override
  String get syncCompleted => 'Senkronizasyon başarıyla tamamlandı';

  @override
  String syncFailed(String error) {
    return 'Senkronizasyon başarısız: $error';
  }

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get clear => 'Temizle';

  @override
  String get deleteCards => 'Kartları Sil';

  @override
  String deleteCardsConfirm(int count) {
    return '$count kartı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get cardsDeletedSuccessfully => 'Kartlar başarıyla silindi';

  @override
  String get deleteCollection => 'Koleksiyonu Sil';

  @override
  String deleteCollectionConfirm(String name) {
    return '\"$name\" koleksiyonunu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get editCollection => 'Koleksiyonu Düzenle';

  @override
  String get exportTooltip => 'Dışa Aktar';

  @override
  String exportedTo(String path) {
    return '$path konumuna aktarıldı';
  }

  @override
  String exportFailed(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String get noCardsYet => 'Henüz kart yok';

  @override
  String get addFirstFlashcard => 'İlk kartınızı ekleyin';

  @override
  String get searchCards => 'Kart ara...';

  @override
  String cardsOfTotal(int filtered, int total) {
    return '$total karttan $filtered tanesi';
  }

  @override
  String get noCardsFound => 'Kart bulunamadı';

  @override
  String get tryDifferentSearch => 'Farklı bir arama terimi deneyin';

  @override
  String get deleteCard => 'Kartı Sil';

  @override
  String get areYouSure => 'Emin misiniz?';

  @override
  String get study => 'Çalış';

  @override
  String cancelWithCount(int count) {
    return 'İptal ($count)';
  }

  @override
  String get unselectAll => 'Seçimi kaldır';

  @override
  String get selectAll => 'Tümünü seç';

  @override
  String get deleteSelected => 'Seçilenleri sil';

  @override
  String get name => 'Ad';

  @override
  String get description => 'Açıklama';

  @override
  String get descriptionOptional => 'Açıklama (İsteğe Bağlı)';

  @override
  String get tags => 'Etiketler';

  @override
  String get addTag => 'Etiket ekle';

  @override
  String get color => 'Renk';

  @override
  String get noCollectionsYet => 'Henüz koleksiyon yok';

  @override
  String get createFirstCollection =>
      'Başlamak için ilk koleksiyonunuzu oluşturun';

  @override
  String get deleteCollections => 'Koleksiyonları Sil';

  @override
  String deleteCollectionsConfirm(int count) {
    return '$count koleksiyonu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get collectionsDeletedSuccessfully =>
      'Koleksiyonlar başarıyla silindi';

  @override
  String get exportCollections => 'Koleksiyonları dışa aktar';

  @override
  String exportedCollections(int success, String failed) {
    return '$success koleksiyon dışa aktarıldı$failed';
  }

  @override
  String get studyCollection => 'Koleksiyonu Çalış';

  @override
  String cardsLeft(int count) {
    return '$count kart kaldı';
  }

  @override
  String get greatJob => 'Harika!';

  @override
  String cardsReviewedToday(int count) {
    return 'Bugün $count kart çalıştınız';
  }

  @override
  String get done => 'Tamam';

  @override
  String get noCardsToStudy => 'Çalışılacak kart yok';

  @override
  String get question => 'Soru';

  @override
  String get answer => 'Cevap';

  @override
  String get tapToReveal => 'Görmek için dokunun';

  @override
  String fromCollection(String name) {
    return 'Kaynak: $name';
  }

  @override
  String timeSeconds(int seconds) {
    return 'Süre: ${seconds}sn';
  }

  @override
  String get howWellDidYouKnow => 'Bu kartı ne kadar iyi biliyordunuz?';

  @override
  String get wrong => 'Yanlış';

  @override
  String get hard => 'Zor';

  @override
  String get good => 'İyi';

  @override
  String get easy => 'Kolay';

  @override
  String errorWithMessage(String message) {
    return 'Hata: $message';
  }

  @override
  String get createCollection => 'Koleksiyon Oluştur';

  @override
  String get lightMode => 'Açık Mod';

  @override
  String get syncTooltip => 'Senkronize Et';

  @override
  String get importCollections => 'Koleksiyonları İçe Aktar';

  @override
  String importedCollections(int collections, int cards, String failed) {
    return '$collections koleksiyon, $cards kart içe aktarıldı$failed';
  }

  @override
  String importFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }

  @override
  String get start => 'Başla';

  @override
  String get noMatchingFilters => 'Filtrelere uyan koleksiyon yok';

  @override
  String get tryAdjustingFilters => 'Filtreleri ayarlamayı deneyin';

  @override
  String studyDecksCount(int count) {
    return '$count koleksiyon çalış';
  }

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get updateYourInfo => 'Bilgilerinizi Güncelleyin';

  @override
  String get changeDisplayOrEmail =>
      'Görünen adınızı veya e-posta adresinizi değiştirin';

  @override
  String get enterDisplayName => 'Görünen adınızı girin';

  @override
  String get profileUpdatedSuccessfully => 'Profil başarıyla güncellendi!';

  @override
  String get failedToUpdateProfile => 'Profil güncellenemedi';

  @override
  String get emailVerificationRequired => 'E-posta Doğrulaması Gerekli';

  @override
  String get emailVerificationMessage =>
      'E-postanız değiştirildi. Lütfen yeni e-postanızdaki doğrulama bağlantısını kontrol edin, ardından tekrar giriş yapın.';

  @override
  String get ok => 'Tamam';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get displayNameMinLength => 'Görünen ad en az 2 karakter olmalıdır';

  @override
  String get emailChangeWarning =>
      'E-postanızı değiştirmek doğrulama gerektirecektir. Oturumunuz kapatılacak ve tekrar giriş yapmadan önce yeni e-postanızı doğrulamanız gerekecek.';

  @override
  String get changeYourPassword => 'Şifrenizi Değiştirin';

  @override
  String get enterCurrentAndNewPassword =>
      'Mevcut şifrenizi girin ve yeni bir şifre seçin';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get enterCurrentPassword => 'Mevcut şifrenizi girin';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get enterNewPassword => 'Yeni şifrenizi girin';

  @override
  String get confirmNewPassword => 'Yeni Şifreyi Onayla';

  @override
  String get confirmYourNewPassword => 'Yeni şifrenizi onaylayın';

  @override
  String get pleaseEnterCurrentPassword => 'Lütfen mevcut şifrenizi girin';

  @override
  String get pleaseEnterNewPassword => 'Lütfen yeni bir şifre girin';

  @override
  String get passwordMinLength8 => 'Şifre en az 8 karakter olmalıdır';

  @override
  String get newPasswordMustBeDifferent =>
      'Yeni şifre mevcut şifreden farklı olmalıdır';

  @override
  String get pleaseConfirmNewPassword => 'Lütfen yeni şifrenizi onaylayın';

  @override
  String get passwordChangedSuccessfully => 'Şifre başarıyla değiştirildi!';

  @override
  String get failedToChangePassword => 'Şifre değiştirilemedi';

  @override
  String get passwordLengthInfo =>
      'Şifre en az 8 karakter uzunluğunda olmalıdır';

  @override
  String get failedToLoadSettings => 'Ayarlar yüklenemedi';

  @override
  String get maxReviewsPerDay => 'Günlük Maksimum Tekrar';

  @override
  String cardsCount(int count) {
    return '$count kart';
  }

  @override
  String get maxNewCardsPerDay => 'Günlük Maksimum Yeni Kart';

  @override
  String get showAnswerTimer => 'Cevap Zamanlayıcısını Göster';

  @override
  String get displayTimeTakenToAnswer => 'Cevaplama süresini göster';

  @override
  String get showIntervalButtons => 'Aralık Düğmelerini Göster';

  @override
  String get displayNextReviewIntervals =>
      'Düğmelerin altında sonraki tekrar aralıklarını göster';

  @override
  String get useDarkTheme => 'Karanlık tema kullan';

  @override
  String get account => 'Hesap';

  @override
  String get never => 'Hiçbir zaman';

  @override
  String get flashcardsApp => 'Flashcards Uygulaması';

  @override
  String get offlineFirstFlashcardApp =>
      'Çevrimdışı öncelikli bir kart uygulaması';

  @override
  String get value => 'Değer';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int count) {
    return '$count dakika önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count saat önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }
}
