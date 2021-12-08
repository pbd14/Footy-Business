import 'languages.dart';

class LanguageRu extends Languages {
  @override
  String get footyBusiness => "Footy Бизнесс";
  @override
  String get labelSelectLanguage => "Русский";
  @override
  String get loginScreen1head => "Онлайн бронирование";
  @override
  String get loginScreen1text =>
      "Бронируйте онлайн без проблем. Больше нет нужды связываться с администраторами и вести долгую беседу";
  @override
  String get loginScreen2head => "2 минуты";
  @override
  String get loginScreen2text =>
      "Всего лишь 2 минуты чтобы забронировать услугу в любом месте";
  @override
  String get loginScreen3head => "Комфорт";
  @override
  String get loginScreen3text =>
      "Мы предлагаем удобное расписание и систему которая регулирует и организовывает ваши броны";
  @override
  String get getStarted => "Начнем";
  @override
  String get loginScreenYourPhone => "Телефон";
  @override
  String get loginScreen6Digits => "Минимум 6 символов";
  @override
  String get loginScreenEnterCode => "Введите код";
  @override
  String get loginScreenReenterPhone => "Поменять номер телефона";
  @override
  String get loginScreenPolicy =>
      "Продолжая вы принимаете все правила пользования приложением и нашу Политику Конфиденциальности";
  @override
  String get loginScreenCodeIsNotValid => "Время действия кода истекло";

  @override
  String get instructions => "Инструкции";
  @override
  String get instText1 =>
      "Поздравляем, вы стали частью семьи Footy. Вот несколько инструкций. Во-первых, вам нужно создать компанию. У каждой компании свой баланс в системе Footy. В качестве примера можно взять компанию «Боулинг-клуб». Вы можете увидеть свои компании в своем профиле. \n\nУ каждой компании разные офисы в разных местах. Позже вы сможете их добавить. Примеры: «Боулинг-клуб Ташкент», «Боулинг-клуб Москва». \n\nВ разных местах вы можете предлагать разные услуги. В одном месте может быть несколько сервисов. Пример: услуга «1-часовая игра» в «Боулинг клубе Ташкент».";
  @override
  String get instText2 =>
      'Когда клиенты закажут одну из ваших услуг, вы получите уведомление и предложение. Вы должны принять или отклонить это предложение как минимум за 3 часа до начала заказа. По истечении установленного срока заказ будет аннулирован. Вы можете нажать на карточку, чтобы получить дополнительную информацию.';
  @override
  String get instText3 =>
      "Баланс вашей компании можно регулировать на экране профиля. В любое время вы можете пополнить баланс. Однако, когда ваш баланс опустится ниже -100 000 сум, ваша компания будет деактивирована, и вы не сможете получать заказы, пока не оплатите свой долг.";
  @override
  String get instText4 => "После того, как вы приняли предложение, вы можете отрегулировать его, нажав на карточку заказа. Когда придет время заказа, вы можете приступить к заказу. Когда он закончится, вы получите оплату от клиента. Как только оплата будет произведена, вы можете завершить заказ. У заказов 3 статуса. \n- Незавершенный - заказ, который еще не запущен. \n- В процессе - заказ, который выполняется прямо сейчас. \n- Неоплаченные - бронирование завершено, но клиент не оплатил.";

  @override
  String get homeScreenBook => "Брон";
  @override
  String get homeScreenFail => "Ошибка";
  @override
  String get homeScreenFailedToUpdate => "Не удалось обновить";
  @override
  String get homeScreenSaved => "Сохранено";

  @override
  String get managementScreenToday => "Сегодня";
  @override
  String get managementScreenNoBooksToday => "Сегодня нет заказов";
  @override
  String get managementScreenLocations => "Локации";
  @override
  String get managementScreenNoLocations => "У вас 0 филиалов для этой компании. Добавьте их, иначе ваша компания может быть заблокирована.";
  @override
  String get managementScreenCreateLocation => "Создать локацию";

  @override
  String get searchScreenName => "Название";

  @override
  String get historyScreenSchedule => "Расписание";
  @override
  String get historyScreenHistory => "История";
  @override
  String get historyScreenUnpaid => "Неоплачено";
  @override
  String get historyScreenInProcess => "В процессе";
  @override
  String get historyScreenUpcoming => "Предстоящие";
  @override
  String get historyScreenUnrated => "Без оценки";
  @override
  String get historyScreenCustom => "Специальные";
  @override
  String get historyScreenVerificationNeeded => "Ожидание согласия владельца";
  @override
  String get historyScreenCreateCustomBook => "Создать индивидуальное бронирование";
  @override
  String get historyScreenSelectService => "Выберите услугу";
  @override
  String get historyScreenAcceptOffer => "Принять предложение";
  @override
  String get historyScreenRejectOffer => "Отклонить предложение";
  @override
  String get historyScreenCancel => "Отменить";
  @override
  String get historyScreenQuestionCancel=> "Вы уверены, что хотите отменить бронирование";

  @override
  String get profileScreenFavs => "Избранное";
  @override
  String get profileScreenNotifs => "Уведомления";
  @override
  String get profileScreenSignOut => "Выйти?";
  @override
  String get profileScreenWantToLeave => "Хотите выйти?";

  @override
  String get settingsSettings => "Настройки";
  @override
  String get settingsLocalPassword => "Локальный пароль";
  @override
  String get settingsLocalPasswordTurnedOff => "Локальный пароль отключен";
  @override
  String get settingsLocalPasswordTurnedOn => "Локальный пароль включен";
  @override
  String get settingsDigitPassword => "4-значный пароль";

  @override
  String get serviceScreenNoInternet => "Нет соединения с Интернетом";
}
