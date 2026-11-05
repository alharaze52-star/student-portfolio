import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Set default font
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rcParams['axes.edgecolor'] = '#cbd5e1'
plt.rcParams['axes.linewidth'] = 0.8

def create_architecture_diagram():
    fig, ax = plt.subplots(figsize=(10, 7), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Background
    fig.patch.set_facecolor('#ffffff')

    # Layer 1: Presentation Layer
    p1 = patches.FancyBboxPatch((5, 75), 90, 20, boxstyle="round,pad=1", ec="#4f46e5", fc="#eef2ff", lw=1.5)
    ax.add_patch(p1)
    ax.text(50, 91, "СЛОЙ ПРЕДСТАВЛЕНИЯ (UI / Presentation Layer — Flutter)", ha="center", va="center", fontsize=11, fontweight='bold', color="#312e81")
    
    screens = ["HomeDashboardScreen\n(Визитка, метрики)", "ProjectsScreen\n(Каталог, фильтры)", "AchievementsScreen\n(Награды, категории)", "SkillsScreen\n(Компетенции, шкалы)", "ProfileScreen\n(Настройки, экспорт)"]
    for i, sc in enumerate(screens):
        bx = patches.FancyBboxPatch((7 + i*18, 77), 16, 11, boxstyle="round,pad=0.5", ec="#818cf8", fc="#ffffff", lw=1)
        ax.add_patch(bx)
        ax.text(7 + i*18 + 8, 82.5, sc, ha="center", va="center", fontsize=7.5, color="#1e1b4b")

    # Arrow 1 <-> 2
    ax.annotate('', xy=(50, 74), xytext=(50, 68), arrowprops=dict(arrowstyle="<->", color="#4f46e5", lw=2))

    # Layer 2: State Management & Business Logic
    p2 = patches.FancyBboxPatch((15, 49), 70, 18, boxstyle="round,pad=1", ec="#059669", fc="#ecfdf5", lw=1.5)
    ax.add_patch(p2)
    ax.text(50, 63, "СЛОЙ БИЗНЕС-ЛОГИКИ И УПРАВЛЕНИЯ СОСТОЯНИЕМ (Provider)", ha="center", va="center", fontsize=11, fontweight='bold', color="#064e3b")
    
    prov1 = patches.FancyBboxPatch((20, 51), 28, 9, boxstyle="round,pad=0.5", ec="#34d399", fc="#ffffff", lw=1)
    ax.add_patch(prov1)
    ax.text(34, 55.5, "PortfolioProvider\n(CRUD, фильтрация, кэш)", ha="center", va="center", fontsize=8, color="#064e3b")

    prov2 = patches.FancyBboxPatch((52, 51), 28, 9, boxstyle="round,pad=0.5", ec="#34d399", fc="#ffffff", lw=1)
    ax.add_patch(prov2)
    ax.text(66, 55.5, "ThemeProvider\n(Светлая/Темная тема)", ha="center", va="center", fontsize=8, color="#064e3b")

    # Arrow 2 <-> 3
    ax.annotate('', xy=(50, 48), xytext=(50, 42), arrowprops=dict(arrowstyle="<->", color="#059669", lw=2))

    # Layer 3: Data & Service Layer
    p3 = patches.FancyBboxPatch((5, 23), 90, 18, boxstyle="round,pad=1", ec="#0284c7", fc="#f0f9ff", lw=1.5)
    ax.add_patch(p3)
    ax.text(50, 37, "СЛОЙ ДАННЫХ И СЕТЕВЫХ СЕРВИСОВ (Data & Repository Layer: ApiService)", ha="center", va="center", fontsize=11, fontweight='bold', color="#0c4a6e")
    
    services = [
        ("HttpApiService", "REST API клиент\n(Node.js сервер)"),
        ("FirebaseRestService", "Прямой доступ к\nFirestore REST API"),
        ("LocalCacheService", "Офлайн-хранилище\nSharedPreferences")
    ]
    for i, (s_title, s_desc) in enumerate(services):
        bx = patches.FancyBboxPatch((10 + i*28, 25), 24, 9, boxstyle="round,pad=0.5", ec="#38bdf8", fc="#ffffff", lw=1)
        ax.add_patch(bx)
        ax.text(10 + i*28 + 12, 30.5, f"{s_title}\n{s_desc}", ha="center", va="center", fontsize=8, color="#0c4a6e")

    # Arrow 3 -> Backend
    ax.annotate('', xy=(30, 22), xytext=(30, 15), arrowprops=dict(arrowstyle="<->", color="#0284c7", lw=1.8))
    ax.annotate('', xy=(70, 22), xytext=(70, 15), arrowprops=dict(arrowstyle="<->", color="#0284c7", lw=1.8))

    # Layer 4: External Servers & Cloud
    b_serv = patches.FancyBboxPatch((12, 3), 36, 11, boxstyle="round,pad=0.8", ec="#d97706", fc="#fffbeb", lw=1.5)
    ax.add_patch(b_serv)
    ax.text(30, 8.5, "Node.js & Express REST API Server\n(Локальный порт 3000 / облако)", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#78350f")

    b_fire = patches.FancyBboxPatch((52, 3), 36, 11, boxstyle="round,pad=0.8", ec="#ea580c", fc="#fff7ed", lw=1.5)
    ax.add_patch(b_fire)
    ax.text(70, 8.5, "Google Firebase Cloud Firestore\n(Облачная NoSQL база данных)", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#7c2d12")

    plt.tight_layout()
    plt.savefig('report/images/architecture_diagram.png', bbox_inches='tight')
    plt.close()
    print("Architecture diagram created.")

def create_use_case_diagram():
    fig, ax = plt.subplots(figsize=(10, 7), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Actor (Student)
    # Head
    head = patches.Circle((15, 55), 3, ec="#1e293b", fc="#f8fafc", lw=1.5)
    ax.add_patch(head)
    # Body
    ax.plot([15, 15], [52, 42], color="#1e293b", lw=2)
    # Arms
    ax.plot([10, 20], [48, 48], color="#1e293b", lw=2)
    # Legs
    ax.plot([15, 10], [42, 32], color="#1e293b", lw=2)
    ax.plot([15, 20], [42, 32], color="#1e293b", lw=2)
    ax.text(15, 27, "Студент\n(Пользователь)", ha="center", va="center", fontsize=10, fontweight='bold', color="#0f172a")

    # Boundary Box
    bound = patches.FancyBboxPatch((28, 5), 68, 90, boxstyle="round,pad=1", ec="#64748b", fc="#ffffff", lw=1.5, ls="--")
    ax.add_patch(bound)
    ax.text(62, 92, "Мобильное приложение «Цифровое портфолио студента»", ha="center", va="center", fontsize=11, fontweight='bold', color="#334155")

    use_cases = [
        (62, 83, "Просмотр дашборда и статистики GPA"),
        (62, 73, "Редактирование профиля и контактов"),
        (62, 63, "Добавление, изменение, удаление проектов (CRUD)"),
        (62, 53, "Полнотекстовый поиск и фильтрация проектов"),
        (62, 43, "Учет грамот, дипломов и олимпиад (CRUD)"),
        (62, 33, "Оценка и управление компетенциями (Hard/Soft)"),
        (62, 23, "Экспорт сводки портфолио в резюме"),
        (62, 13, "Синхронизация данных с REST API и Firebase")
    ]

    for x, y, uc in use_cases:
        ellipse = patches.Ellipse((x, y), 56, 7.5, ec="#4f46e5", fc="#f5f3ff", lw=1.2)
        ax.add_patch(ellipse)
        ax.text(x, y, uc, ha="center", va="center", fontsize=8.5, color="#312e81")
        # Line from actor to use case
        ax.plot([20, x - 28], [48, y], color="#94a3b8", lw=1, ls=":")

    plt.tight_layout()
    plt.savefig('report/images/use_case_diagram.png', bbox_inches='tight')
    plt.close()
    print("Use case diagram created.")

def create_user_flow_diagram():
    fig, ax = plt.subplots(figsize=(10, 6), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    # Start Node
    st = patches.FancyBboxPatch((38, 88), 24, 8, boxstyle="round,pad=0.5", ec="#10b981", fc="#ecfdf5", lw=1.5)
    ax.add_patch(st)
    ax.text(50, 92, "Запуск приложения\n(Инициализация Provider)", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#064e3b")

    # Main Screen
    main_sc = patches.FancyBboxPatch((30, 68), 40, 11, boxstyle="round,pad=0.8", ec="#4f46e5", fc="#eef2ff", lw=1.8)
    ax.add_patch(main_sc)
    ax.text(50, 73.5, "Главный экран навигации\nMainNavigationScreen (NavigationBar)", ha="center", va="center", fontsize=9.5, fontweight='bold', color="#312e81")

    # Arrow Start -> Main
    ax.annotate('', xy=(50, 79.5), xytext=(50, 88), arrowprops=dict(arrowstyle="->", color="#10b981", lw=1.5))

    # Tabs
    tabs = [
        (10, 46, "Вкладка «Обзор»\nДашборд, GPA,\nбыстрые действия"),
        (30, 46, "Вкладка «Проекты»\nКаталог, фильтры,\nпоиск по стеку"),
        (50, 46, "Вкладка «Грамоты»\nОлимпиады, хакатоны,\nдипломы"),
        (70, 46, "Вкладка «Навыки»\nШкалы прогресса,\nHard/Soft skills"),
        (90, 46, "Вкладка «Профиль»\nЛичные данные, темы,\nэкспорт резюме")
    ]

    for cx, cy, text in tabs:
        bx = patches.FancyBboxPatch((cx - 8, cy - 6), 16, 12, boxstyle="round,pad=0.5", ec="#6366f1", fc="#ffffff", lw=1.2)
        ax.add_patch(bx)
        ax.text(cx, cy, text, ha="center", va="center", fontsize=7.5, color="#1e1b4b")
        # Line from Main to Tab
        ax.annotate('', xy=(cx, cy + 6.5), xytext=(50, 68), arrowprops=dict(arrowstyle="->", color="#818cf8", lw=1.2))

    # Sub-actions
    sub_actions = [
        (30, 20, "ProjectDetailScreen\n(Просмотр ссылок, стека)\nProjectEditScreen\n(Создание / Редактирование)"),
        (50, 20, "AchievementEditScreen\n(Добавление диплома,\nвыбор номинации)"),
        (70, 20, "SkillDialog\n(Интерактивный слайдер,\nвыбор уровня владения)"),
        (90, 20, "ProfileEditScreen\n(Форма редактирования)\nExportDialog (Сводка)")
    ]

    for cx, cy, text in sub_actions:
        bx = patches.FancyBboxPatch((cx - 8.5, cy - 7), 17, 14, boxstyle="round,pad=0.5", ec="#0ea5e9", fc="#f0f9ff", lw=1, ls="--")
        ax.add_patch(bx)
        ax.text(cx, cy, text, ha="center", va="center", fontsize=7, color="#0369a1")
        # Arrow from Tab to Sub
        ax.annotate('', xy=(cx, cy + 7.5), xytext=(cx, 39.5), arrowprops=dict(arrowstyle="->", color="#0ea5e9", lw=1.2))

    plt.tight_layout()
    plt.savefig('report/images/user_flow_diagram.png', bbox_inches='tight')
    plt.close()
    print("User flow diagram created.")

def create_er_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.5), dpi=300)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')

    entities = [
        (25, 75, "StudentProfile (Студент)", [
            "id: String (PK)",
            "fullName: String",
            "title: String",
            "university: String",
            "faculty: String",
            "group: String",
            "gpa: Double",
            "email, phone: String",
            "githubUrl, telegramUrl: String",
            "bio: String",
            "avatarUrl: String"
        ], "#4f46e5", "#eef2ff"),

        (75, 75, "ProjectItem (Проект)", [
            "id: String (PK)",
            "title: String",
            "description: String",
            "role: String",
            "status: String",
            "tags: List<String>",
            "githubUrl: String",
            "demoUrl: String",
            "period: String",
            "isFeatured: Boolean"
        ], "#059669", "#ecfdf5"),

        (25, 25, "AchievementItem (Грамота)", [
            "id: String (PK)",
            "title: String",
            "category: String",
            "issuer: String",
            "date: String",
            "place: String",
            "certificateUrl: String",
            "description: String"
        ], "#ea580c", "#fff7ed"),

        (75, 25, "SkillItem (Компетенция)", [
            "id: String (PK)",
            "name: String",
            "category: String",
            "level: Double (0.0 .. 1.0)",
            "levelTitle: String"
        ], "#0284c7", "#f0f9ff")
    ]

    for x, y, title, fields, ec, fc in entities:
        h = 5 + len(fields) * 3.2
        bx = patches.FancyBboxPatch((x - 22, y - h/2), 44, h, boxstyle="round,pad=0.5", ec=ec, fc=fc, lw=1.5)
        ax.add_patch(bx)
        # Header line
        ax.text(x, y + h/2 - 3, title, ha="center", va="center", fontsize=9.5, fontweight='bold', color=ec)
        ax.plot([x - 21, x + 21], [y + h/2 - 5, y + h/2 - 5], color=ec, lw=1)
        # Fields
        for fi, f in enumerate(fields):
            ax.text(x - 19, y + h/2 - 8.5 - fi * 3.1, f, ha="left", va="center", fontsize=8, color="#1e293b")

    # Relationships (Student has many Projects, Achievements, Skills)
    ax.annotate('', xy=(53, 75), xytext=(47, 75), arrowprops=dict(arrowstyle="->", color="#64748b", lw=1.5))
    ax.text(50, 78, "1 : N", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#475569")

    ax.annotate('', xy=(25, 43), xytext=(25, 50), arrowprops=dict(arrowstyle="->", color="#64748b", lw=1.5))
    ax.text(28, 47, "1 : N", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#475569")

    ax.annotate('', xy=(53, 40), xytext=(42, 60), arrowprops=dict(arrowstyle="->", color="#64748b", lw=1.5))
    ax.text(49, 52, "1 : N", ha="center", va="center", fontsize=8.5, fontweight='bold', color="#475569")

    plt.tight_layout()
    plt.savefig('report/images/database_er_diagram.png', bbox_inches='tight')
    plt.close()
    print("ER diagram created.")

if __name__ == '__main__':
    create_architecture_diagram()
    create_use_case_diagram()
    create_user_flow_diagram()
    create_er_diagram()
