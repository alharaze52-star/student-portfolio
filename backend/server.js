const express = require('express');
const cors = require('cors');
const { readDb, writeDb } = require('./firebaseConfig');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Логирование входящих API запросов
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
  next();
});

// Проверка здоровья сервиса
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Student Portfolio API Backend',
    database: 'Firebase/Firestore API Data Store',
    timestamp: new Date().toISOString()
  });
});

// ==========================================
// 1. ПРОФИЛЬ СТУДЕНТА (GET, PUT)
// ==========================================

// GET /api/profile
app.get('/api/profile', (req, res) => {
  try {
    const db = readDb();
    res.json(db.profile);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось получить профиль студента', details: err.message });
  }
});

// PUT /api/profile
app.put('/api/profile', (req, res) => {
  try {
    const db = readDb();
    const updatedProfile = {
      ...db.profile,
      ...req.body,
      updatedAt: new Date().toISOString()
    };
    db.profile = updatedProfile;
    writeDb(db);
    res.json(updatedProfile);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось обновить профиль', details: err.message });
  }
});

// ==========================================
// 2. ПРОЕКТЫ (GET, POST, PUT, DELETE)
// ==========================================

// GET /api/projects
app.get('/api/projects', (req, res) => {
  try {
    const db = readDb();
    res.json(db.projects);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось получить список проектов', details: err.message });
  }
});

// GET /api/projects/:id
app.get('/api/projects/:id', (req, res) => {
  try {
    const db = readDb();
    const project = db.projects.find(p => p.id === req.params.id);
    if (!project) {
      return res.status(404).json({ error: 'Проект не найден' });
    }
    res.json(project);
  } catch (err) {
    res.status(500).json({ error: 'Ошибка сервера', details: err.message });
  }
});

// POST /api/projects
app.post('/api/projects', (req, res) => {
  try {
    const db = readDb();
    const newProject = {
      id: req.body.id || `proj_${Date.now()}`,
      title: req.body.title || 'Новый проект',
      description: req.body.description || '',
      role: req.body.role || 'Разработчик',
      status: req.body.status || 'Завершен',
      tags: Array.isArray(req.body.tags) ? req.body.tags : [],
      githubUrl: req.body.githubUrl || '',
      demoUrl: req.body.demoUrl || '',
      imageUrl: req.body.imageUrl || '',
      period: req.body.period || '',
      isFeatured: !!req.body.isFeatured,
      createdAt: req.body.createdAt || new Date().toISOString()
    };

    db.projects.unshift(newProject);
    writeDb(db);
    res.status(201).json(newProject);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось создать проект', details: err.message });
  }
});

// PUT /api/projects/:id
app.put('/api/projects/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.projects.findIndex(p => p.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Проект не найден' });
    }

    const updated = {
      ...db.projects[index],
      ...req.body,
      id: req.params.id
    };

    db.projects[index] = updated;
    writeDb(db);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось обновить проект', details: err.message });
  }
});

// DELETE /api/projects/:id
app.delete('/api/projects/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.projects.findIndex(p => p.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Проект не найден' });
    }

    const deleted = db.projects.splice(index, 1)[0];
    writeDb(db);
    res.json({ message: 'Проект успешно удален', deletedId: deleted.id });
  } catch (err) {
    res.status(500).json({ error: 'Не удалось удалить проект', details: err.message });
  }
});

// ==========================================
// 3. ДОСТИЖЕНИЯ И ГРАМОТЫ (GET, POST, PUT, DELETE)
// ==========================================

// GET /api/achievements
app.get('/api/achievements', (req, res) => {
  try {
    const db = readDb();
    res.json(db.achievements);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось получить достижения', details: err.message });
  }
});

// POST /api/achievements
app.post('/api/achievements', (req, res) => {
  try {
    const db = readDb();
    const newAchievement = {
      id: req.body.id || `ach_${Date.now()}`,
      title: req.body.title || 'Новое достижение',
      category: req.body.category || 'Сертификат',
      issuer: req.body.issuer || '',
      date: req.body.date || '',
      place: req.body.place || '1 место',
      certificateUrl: req.body.certificateUrl || '',
      imageUrl: req.body.imageUrl || '',
      description: req.body.description || ''
    };

    db.achievements.unshift(newAchievement);
    writeDb(db);
    res.status(201).json(newAchievement);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось создать достижение', details: err.message });
  }
});

// PUT /api/achievements/:id
app.put('/api/achievements/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.achievements.findIndex(a => a.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Достижение не найдено' });
    }

    const updated = {
      ...db.achievements[index],
      ...req.body,
      id: req.params.id
    };

    db.achievements[index] = updated;
    writeDb(db);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось обновить достижение', details: err.message });
  }
});

// DELETE /api/achievements/:id
app.delete('/api/achievements/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.achievements.findIndex(a => a.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Достижение не найдено' });
    }

    const deleted = db.achievements.splice(index, 1)[0];
    writeDb(db);
    res.json({ message: 'Достижение успешно удалено', deletedId: deleted.id });
  } catch (err) {
    res.status(500).json({ error: 'Не удалось удалить достижение', details: err.message });
  }
});

// ==========================================
// 4. НАВЫКИ И КОМПЕТЕНЦИИ (GET, POST, PUT, DELETE)
// ==========================================

// GET /api/skills
app.get('/api/skills', (req, res) => {
  try {
    const db = readDb();
    res.json(db.skills);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось получить навыки', details: err.message });
  }
});

// POST /api/skills
app.post('/api/skills', (req, res) => {
  try {
    const db = readDb();
    const newSkill = {
      id: req.body.id || `sk_${Date.now()}`,
      name: req.body.name || 'Новый навык',
      category: req.body.category || 'Hard Skills',
      level: typeof req.body.level === 'number' ? req.body.level : 0.8,
      levelTitle: req.body.levelTitle || 'Продвинутый'
    };

    db.skills.push(newSkill);
    writeDb(db);
    res.status(201).json(newSkill);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось создать навык', details: err.message });
  }
});

// PUT /api/skills/:id
app.put('/api/skills/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.skills.findIndex(s => s.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Навык не найден' });
    }

    const updated = {
      ...db.skills[index],
      ...req.body,
      id: req.params.id
    };

    db.skills[index] = updated;
    writeDb(db);
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: 'Не удалось обновить навык', details: err.message });
  }
});

// DELETE /api/skills/:id
app.delete('/api/skills/:id', (req, res) => {
  try {
    const db = readDb();
    const index = db.skills.findIndex(s => s.id === req.params.id);
    if (index === -1) {
      return res.status(404).json({ error: 'Навык не найден' });
    }

    const deleted = db.skills.splice(index, 1)[0];
    writeDb(db);
    res.json({ message: 'Навык успешно удален', deletedId: deleted.id });
  } catch (err) {
    res.status(500).json({ error: 'Не удалось удалить навык', details: err.message });
  }
});

// ==========================================
// 5. СВОДНАЯ СТАТИСТИКА
// ==========================================
app.get('/api/stats', (req, res) => {
  try {
    const db = readDb();
    res.json({
      projectsCount: db.projects.length,
      completedProjectsCount: db.projects.filter(p => p.status === 'Завершен').length,
      inProgressProjectsCount: db.projects.filter(p => p.status === 'В разработке').length,
      achievementsCount: db.achievements.length,
      skillsCount: db.skills.length,
      gpa: db.profile.gpa,
      updatedAt: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ error: 'Ошибка получения статистики', details: err.message });
  }
});

// Запуск сервера
app.listen(PORT, '0.0.0.0', () => {
  console.log(`====================================================`);
  console.log(`🚀 Сервер API студенческого портфолио запущен!`);
  console.log(`📡 URL адрес: http://localhost:${PORT}`);
  console.log(`📱 Для Android эмулятора: http://10.0.2.2:${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 Эндпоинты:`);
  console.log(`   - GET/PUT    /api/profile`);
  console.log(`   - GET/POST   /api/projects`);
  console.log(`   - PUT/DELETE /api/projects/:id`);
  console.log(`   - GET/POST   /api/achievements`);
  console.log(`   - PUT/DELETE /api/achievements/:id`);
  console.log(`   - GET/POST   /api/skills`);
  console.log(`   - PUT/DELETE /api/skills/:id`);
  console.log(`   - GET        /api/stats`);
  console.log(`====================================================`);
});
