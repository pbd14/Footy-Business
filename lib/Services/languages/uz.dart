import 'languages.dart';

class LanguageUz extends Languages {
  @override
  String get footyBusiness => "Footy Biznes";
  @override
  String get labelSelectLanguage => "O'zbek";
  @override
  String get loginScreen1head => "Onlayn bron qilish";
  @override
  String get loginScreen1text =>
      "Hech qanday muammosiz onlayn buyurtma bering. Administratorlar bilan bog'lanish va uzoq suhbatlashishning hojati yo'q";
  @override
  String get loginScreen2head => "2 daqiqa";
  @override
  String get loginScreen2text =>
      "Xizmatni istalgan joyda bron qilish uchun atigi 2 daqiqa";
  @override
  String get loginScreen3head => "Qulaylik";
  @override
  String get loginScreen3text =>
      "Biz qulay jadval va sizning buyurtmalaringizni tartibga soluvchi tizimni taklif etamiz.";
  @override
  String get getStarted => "Boshlaylik";
  @override
  String get loginScreenYourPhone => "Telefon raqamingiz";
  @override
  String get loginScreen6Digits => "Kod 6 ta raqamdan iborat bo'lishi kerak";
  @override
  String get loginScreenEnterCode => "Kodni tering";
  @override
  String get loginScreenReenterPhone => "Tel. raqamini o'zgartiring";
  @override
  String get loginScreenPolicy =>
      "Davom etish orqali siz ilovadan foydalanishning barcha shartlariga va Maxfiylik siyosatiga rozilik bildirasiz";
  @override
  String get loginScreenCodeIsNotValid => "Kodning muddati tugadi";

  @override
  String get instructions => "Ko'rsatmalar";
  @override
  String get instText1 =>
      "Footy oilasining a'zosi bo'lganingiz bilan tabriklayman. Bu erda bizda ba'zi ko'rsatmalar mavjud. Birinchidan, siz kompaniya yaratishingiz kerak. Footy tizimida har bir kompaniyaning o'z balansi bor. Misol tariqasida Bowling club kompaniyasini olamiz. Siz o'z kompaniyangizni profilingizda ko'rishingiz mumkin. \n\nHar bir kompaniyaning har xil ofislari bor. Keyinchalik ularni qo'shishingiz mumkin. Misollar: Bowling club Tashkent, Bowling club Moscow. \n\nTurli joylarda siz turli xil xizmatlarni taklif qilishingiz mumkin. Bir joyda bir nechta xizmatlar bo'lishi mumkin. Misol: Bowling club Tashkent da 1 soatlik o'yin xizmati.";
  @override
  String get instText2 =>
      "Mijozlar sizning xizmatlaringizdan biriga buyurtma berishganda, sizga xabar va taklif beriladi. Buyurtma boshlanishidan kamida 3 soat oldin siz ushbu taklifni qabul qilishingiz yoki rad qilishingiz kerak. Belgilangan muddatdan keyin buyurtma bekor qilinadi. Qo'shimcha ma'lumot olish uchun siz kartani bosishingiz mumkin.";
  @override
  String get instText3 =>
      "Sizning kompaniyangiz balansi profil ekranida sozlanishi mumkin. Qachon xohlasangiz, balansni to'ldirishingiz mumkin. Balansingiz -100 000 so'mdan pastga tushganda, sizning kompaniyangiz o'chiriladi va siz qarzingizni to'lamaguningizcha buyurtmalarni qabul qila olmaysiz.";
  @override
  String get instText4 =>
      "Taklifni qabul qilganingizdan so'ng, siz buyurtma kartasini bosish orqali uni tartibga solishingiz mumkin. Buyurtma vaqti kelganda, siz buyurtmani boshlashingiz mumkin. U tugagandan so'ng, siz mijozdan to'lov olasiz. To'lov amalga oshirilgandan so'ng, siz buyurtmani tugatshingiz mumkin. Buyurtmalar uchun 3 ta status mavjud. \n- Tugallanmagan - hali boshlanmagan buyurtma. \n- Jarayon - hozirda sodir bo'layotgan tartib. \n- To'lanmagan - buyurtma tugadi lekin mijoz hali to'lamadi.";

  @override
  String get homeScreenBook => "Bron qilish";
  @override
  String get homeScreenFail => "Xato";
  @override
  String get homeScreenFailedToUpdate => "Yangilanmadi";
  @override
  String get homeScreenSaved => "Saqlandi";

  @override
  String get managementScreenToday => "Bugun";
  @override
  String get managementScreenNoBooksToday => "Bugun buyurtmalar yo'q";
  @override
  String get managementScreenLocations => "Joylar";
  @override
  String get managementScreenNoLocations =>
      "Sizda bu kompaniya uchun 0 ta joy mavjud. Iltimos, ularni qo'shing, aks holda kompaniyangiz taqiqlangan bo'lishi mumkin.";
  @override
  String get managementScreenCreateLocation => "Joy yaratish";

  @override
  String get searchScreenName => "Joy nomi";

  @override
  String get historyScreenSchedule => "Jadval";
  @override
  String get historyScreenHistory => "Tarix";
  @override
  String get historyScreenUnpaid => "To'lanmagan";
  @override
  String get historyScreenInProcess => "Jarayonda";
  @override
  String get historyScreenUpcoming => "Tugallanmagan";
  @override
  String get historyScreenUnrated => "Baholanmagan";
  @override
  String get historyScreenCustom => "Maxsus";
  @override
  String get historyScreenVerificationNeeded => "Kelishuv kutilmoqda";
  @override
  String get historyScreenCreateCustomBook => "Maxsus bron yaratish";
  @override
  String get historyScreenSelectService => "Xizmatni tanlang";
  @override
  String get historyScreenAcceptOffer => "Taklifni qabul qilish";
  @override
  String get historyScreenRejectOffer => "Taklifni rad qilish";

  @override
  String get profileScreenFavs => "Sevimlilar";
  @override
  String get profileScreenNotifs => "Xabarlar";
  @override
  String get profileScreenSignOut => "Chiqish?";
  @override
  String get profileScreenWantToLeave => "Ketmoqchimisiz?";

  @override
  String get settingsSettings => "Sozlamalar";
  @override
  String get settingsLocalPassword => "Mahalliy parol";
  @override
  String get settingsLocalPasswordTurnedOff => "Mahalliy parol ochirildi";
  @override
  String get settingsLocalPasswordTurnedOn => "Mahalliy parol yoqildi";
  @override
  String get settingsDigitPassword => "4 raqamli parol";

  @override
  String get serviceScreenNoInternet => "Internet aloqasi yo'q";
}
