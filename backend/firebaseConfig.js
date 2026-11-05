const fs = require('fs');
const path = require('path');

// Локальный файл базы данных для надежной работы без привязки к внешним ключам
const DB_FILE = path.join(__dirname, 'database.json');

const initialDatabase = {
  profile: {
    id: "default_student",
    fullName: "Иванов Иван Иванович",
    title: "Студент 3 курса, Fullstack & Flutter разработчик",
    university: "Московский Политехнический Университет",
    faculty: "Факультет информационных технологий",
    group: "ПИ-301",
    gpa: 4.85,
    email: "ivanov.student@edu.ru",
    phone: "+7 (999) 123-45-67",
    githubUrl: "https://github.com/ivanov-dev",
    telegramUrl: "@ivanov_dev",
    bio: "Разрабатываю кроссплатформенные мобильные приложения на Flutter/Dart с интеграцией облачных сервисов Firebase API. Участник хакатонов и научных конференций.",
    avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
    updatedAt: new Date().toISOString()
  },
  projects: [
    {
      id: "proj_1",
      title: "Мобильное приложение 'Цифровое портфолио студента'",
      description: "Курсовой проект: кроссплатформенное приложение на Flutter и Dart с интеграцией Firebase API и REST бэкендом. Полная реализация CRUD операций, чистая архитектура.",
      role: "Lead Flutter Developer",
      status: "Завершен",
      tags: ["Flutter", "Dart", "Firebase", "REST API", "Provider"],
      githubUrl: "https://github.com/ivanov-dev/student-portfolio",
      demoUrl: "https://portfolio-app.dev",
      imageUrl: "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=800",
      period: "Сентябрь 2024 - Ноябрь 2024",
      isFeatured: true,
      createdAt: new Date(Date.now() - 30 * 86400000).toISOString()
    },
    {
      id: "proj_2",
      title: "Система мониторинга посещаемости и успеваемости",
      description: "Мобильный сервис с QR-сканером для мгновенной фиксации присутствия студентов на лекциях и синхронизацией с деканатом через API.",
      role: "Backend & Mobile Dev",
      status: "Завершен",
      tags: ["Flutter", "Node.js", "Express", "QR Code", "PostgreSQL"],
      githubUrl: "https://github.com/ivanov-dev/attendance-scanner",
      imageUrl: "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800",
      period: "Февраль 2024 - Май 2024",
      isFeatured: true,
      createdAt: new Date(Date.now() - 90 * 86400000).toISOString()
    },
    {
      id: "proj_3",
      title: "AI Ассистент студента для подготовки к экзаменам",
      description: "Приложение для генерации тестовых вопросов по конспектам лекций с использованием Gemini API и алгоритмов семантического поиска.",
      role: "Fullstack Developer",
      status: "В разработке",
      tags: ["Flutter", "Gemini API", "Python", "Vector DB"],
      imageUrl: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800",
      period: "Сентябрь 2024 - настоящее время",
      isFeatured: true,
      createdAt: new Date(Date.now() - 15 * 86400000).toISOString()
    }
  ],
  achievements: [
    {
      id: "ach_1",
      title: "Победитель всероссийского хакатона 'Цифровой прорыв'",
      category: "Хакатон",
      issuer: "АНО 'Россия - страна возможностей'",
      date: "Октябрь 2024",
      place: "1 место",
      certificateUrl: "https://hackathon.ru/certs/123",
      imageUrl: "https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=800",
      description: "Разработка мобильного прототипа сервиса кампусной навигации за 48 часов непрерывной разработки."
    },
    {
      id: "ach_2",
      title: "Диплом I степени университетской олимпиады по программированию",
      category: "Олимпиада",
      issuer: "Ученый совет университета",
      date: "Апрель 2024",
      place: "Победитель",
      certificateUrl: "",
      imageUrl: "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800",
      description: "Решение алгоритмических задач и структур данных на время."
    },
    {
      id: "ach_3",
      title: "Сертификат Google Certified Flutter Specialist",
      category: "Сертификат",
      issuer: "Google Developers Training",
      date: "Июнь 2024",
      place: "Сертификат с отличием",
      certificateUrl: "https://coursera.org/verify/flutter",
      imageUrl: "",
      description: "Успешное подтверждение квалификации в создании кроссплатформенных мобильных приложений."
    }
  ],
  skills: [
    { id: "sk_1", name: "Flutter & Dart", category: "Hard Skills", level: 0.92, levelTitle: "Продвинутый" },
    { id: "sk_2", name: "REST API & JSON", category: "Hard Skills", level: 0.95, levelTitle: "Эксперт" },
    { id: "sk_3", name: "Firebase (Firestore, REST API)", category: "Hard Skills", level: 0.88, levelTitle: "Продвинутый" },
    { id: "sk_4", name: "State Management (Provider / Bloc)", category: "Hard Skills", level: 0.90, levelTitle: "Продвинутый" },
    { id: "sk_5", name: "Git, GitHub Actions (CI/CD)", category: "Инструменты", level: 0.85, levelTitle: "Уверенный" },
    { id: "sk_6", name: "Figma UI/UX прототипирование", category: "Инструменты", level: 0.80, levelTitle: "Уверенный" },
    { id: "sk_7", name: "Командная работа & Agile Scrum", category: "Soft Skills", level: 0.90, levelTitle: "Высокий" },
    { id: "sk_8", name: "Технический английский язык", category: "Языки", level: 0.82, levelTitle: "B2 / Upper-Intermediate" }
  ]
};

function readDb() {
  if (!fs.existsSync(DB_FILE)) {
    fs.writeFileSync(DB_FILE, JSON.stringify(initialDatabase, null, 2), 'utf-8');
    return initialDatabase;
  }
  try {
    const raw = fs.readFileSync(DB_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('Ошибка чтения БД, восстановление начальных данных:', err);
    return initialDatabase;
  }
}

function writeDb(data) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf-8');
  } catch (err) {
    console.error('Ошибка записи в БД:', err);
  }
}

module.exports = {
  readDb,
  writeDb
};
