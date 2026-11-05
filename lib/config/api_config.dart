enum ApiMode {
  backendRest,      // Подключение к Node.js / Express серверу
  firebaseDirect,   // Прямой доступ к Firebase Cloud Firestore REST API
  offlineMock,      // Автономный режим с сохранением в локальное хранилище
}

class ApiConfig {
  // Текущий режим работы API (по умолчанию backendRest, с авто-переключением на offlineMock при отсутствии сети)
  static ApiMode currentMode = ApiMode.offlineMock;

  // URL Express бэкенда (10.0.2.2 для Android эмулятора, localhost для iOS/Web, либо IP в локальной сети / облачный URL)
  static const String defaultBaseUrl = 'http://10.0.2.2:3000/api';
  static const String localNetworkUrl = 'http://localhost:3000/api';

  // Firebase Cloud Firestore REST API конфигурация
  // https://firebase.google.com/docs/firestore/reference/rest
  static const String firebaseProjectId = 'student-portfolio-app';
  static const String firebaseRestEndpoint = 
      'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents';

  // Таймаут сетевых запросов
  static const Duration requestTimeout = Duration(seconds: 8);

  // Кастомный адрес сервера (можно изменить из настроек приложения)
  static String customBaseUrl = defaultBaseUrl;

  static String get baseUrl => customBaseUrl;
}

