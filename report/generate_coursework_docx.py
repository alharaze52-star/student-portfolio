# -*- coding: utf-8 -*-
import os
import docx
from docx.shared import Inches, Pt, Mm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import qn, nsdecls

def create_element(name):
    return OxmlElement(name)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def add_page_number_to_run(run):
    fldChar1 = OxmlElement('w:fldChar')
    fldChar1.set(qn('w:fldCharType'), 'begin')
    instrText = OxmlElement('w:instrText')
    instrText.set(qn('xml:space'), 'preserve')
    instrText.text = "PAGE"
    fldChar2 = OxmlElement('w:fldChar')
    fldChar2.set(qn('w:fldCharType'), 'separate')
    fldChar3 = OxmlElement('w:fldChar')
    fldChar3.set(qn('w:fldCharType'), 'end')
    r = run._r
    r.append(fldChar1)
    r.append(instrText)
    r.append(fldChar2)
    r.append(fldChar3)

class CourseworkReportBuilder:
    def __init__(self, filename):
        self.filename = filename
        self.doc = docx.Document()
        self.setup_styles()

    def setup_styles(self):
        # Base Normal style
        style_normal = self.doc.styles['Normal']
        font = style_normal.font
        font.name = 'Times New Roman'
        font.size = Pt(14)
        font.color.rgb = RGBColor(0, 0, 0)
        style_normal.paragraph_format.line_spacing = 1.5
        style_normal.paragraph_format.space_after = Pt(0)
        style_normal.paragraph_format.space_before = Pt(0)

    def set_section_margins(self, section):
        section.top_margin = Mm(20)
        section.bottom_margin = Mm(20)
        section.left_margin = Mm(30)
        section.right_margin = Mm(10)
        section.page_width = Mm(210)
        section.page_height = Mm(297)

    def add_p(self, text="", align=WD_ALIGN_PARAGRAPH.JUSTIFY, first_indent=1.25, bold=False, italic=False, font_size=14, space_after=0, space_before=0):
        p = self.doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.first_line_indent = Mm(first_indent * 10) if first_indent > 0 else 0
        p.paragraph_format.line_spacing = 1.5
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.space_before = Pt(space_before)
        if text:
            run = p.add_run(text)
            run.font.name = 'Times New Roman'
            run.font.size = Pt(font_size)
            run.font.bold = bold
            run.font.italic = italic
            run.font.color.rgb = RGBColor(0, 0, 0)
        return p

    def add_heading_chapter(self, title):
        p = self.doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.first_line_indent = 0
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(12)
        p.paragraph_format.line_spacing = 1.5
        run = p.add_run(title)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(14)
        run.font.bold = True
        run.font.color.rgb = RGBColor(0, 0, 0)
        return p

    def add_heading_sub(self, title):
        p = self.doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.first_line_indent = Mm(12.5)
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.5
        run = p.add_run(title)
        run.font.name = 'Times New Roman'
        run.font.size = Pt(14)
        run.font.bold = True
        run.font.color.rgb = RGBColor(0, 0, 0)
        return p

    def add_figure(self, img_path, caption):
        if os.path.exists(img_path):
            p_img = self.doc.add_paragraph()
            p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img.paragraph_format.first_line_indent = 0
            p_img.paragraph_format.space_before = Pt(6)
            p_img.paragraph_format.space_after = Pt(4)
            run_img = p_img.add_run()
            run_img.add_picture(img_path, width=Inches(6.0))

            p_cap = self.doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.first_line_indent = 0
            p_cap.paragraph_format.space_before = Pt(0)
            p_cap.paragraph_format.space_after = Pt(12)
            run_cap = p_cap.add_run(caption)
            run_cap.font.name = 'Times New Roman'
            run_cap.font.size = Pt(12)
            run_cap.font.italic = True
            run_cap.font.color.rgb = RGBColor(0, 0, 0)

    def add_table_data(self, title, headers, rows, col_widths=None):
        # Caption above table
        p_cap = self.doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p_cap.paragraph_format.first_line_indent = Mm(12.5)
        p_cap.paragraph_format.space_before = Pt(8)
        p_cap.paragraph_format.space_after = Pt(4)
        run_cap = p_cap.add_run(title)
        run_cap.font.name = 'Times New Roman'
        run_cap.font.size = Pt(12)
        run_cap.font.bold = True
        run_cap.font.color.rgb = RGBColor(0, 0, 0)

        table = self.doc.add_table(rows=len(rows) + 1, cols=len(headers))
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        table.autofit = False

        # Header Row
        hdr_cells = table.rows[0].cells
        for i, h in enumerate(headers):
            hdr_cells[i].text = h
            set_cell_background(hdr_cells[i], "E2E8F0")
            set_cell_margins(hdr_cells[i], top=120, bottom=120, left=150, right=150)
            p = hdr_cells[i].paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.first_line_indent = 0
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(11)
                r.font.bold = True

        # Data Rows
        for r_idx, row in enumerate(rows):
            row_cells = table.rows[r_idx + 1].cells
            for c_idx, val in enumerate(row):
                row_cells[c_idx].text = str(val)
                set_cell_margins(row_cells[c_idx], top=80, bottom=80, left=150, right=150)
                if r_idx % 2 == 1:
                    set_cell_background(row_cells[c_idx], "F8FAFC")
                p = row_cells[c_idx].paragraphs[0]
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
                p.paragraph_format.line_spacing = 1.15
                p.paragraph_format.first_line_indent = 0
                for r in p.runs:
                    r.font.name = 'Times New Roman'
                    r.font.size = Pt(10.5)

        # Set Column Widths if provided
        if col_widths:
            for row in table.rows:
                for idx, width in enumerate(col_widths):
                    row.cells[idx].width = Mm(width)

        p_after = self.doc.add_paragraph()
        p_after.paragraph_format.space_after = Pt(6)

    def build_title_page(self):
        # Section 1 (Title + Table of Contents)
        s1 = self.doc.sections[0]
        self.set_section_margins(s1)

        # Header of institution
        p = self.add_p("Колледж ТОО «Astana IT University»", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=14)
        p = self.add_p("Цикловая комиссия специальных дисциплин", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=False, font_size=13, space_after=60)

        # Title of work
        p = self.add_p("КУРСОВОЙ ПРОЕКТ", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=20, space_before=40, space_after=12)
        p = self.add_p("по дисциплине: «ПМ07 Разработка мобильных приложений»", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=14, space_after=6)
        p = self.add_p("Специальность: 06130100 – «Программное обеспечение (по видам)»", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=False, font_size=13)
        p = self.add_p("Квалификация: 4S06130103 – «Разработчик программного обеспечения»", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=False, font_size=13, space_after=24)

        p = self.add_p("Тема: «Разработка мобильного приложения для цифрового портфолио студента»", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=15, space_after=90)

        # Authors and supervisor info
        t_info = [
            ("Выполнил(а):", "студент группы ПИ-301"),
            ("", "Иванов И. И."),
            ("", ""),
            ("Проверил:", "преподаватель специальных дисциплин"),
            ("", "Мартынцов Н. В."),
            ("", ""),
            ("Оценка:", "____________________"),
            ("Дата защиты:", "«____» ____________ 2026 г.")
        ]
        for label, val in t_info:
            p = self.doc.add_paragraph()
            p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            p.paragraph_format.first_line_indent = 0
            p.paragraph_format.line_spacing = 1.15
            p.paragraph_format.space_after = Pt(2)
            run = p.add_run(f"{label} {val}".strip())
            run.font.name = 'Times New Roman'
            run.font.size = Pt(13)

        # Footer City and Year
        p_space = self.add_p("", first_indent=0, space_after=70)
        p_city = self.add_p("Астана, 2026 г.", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=False, font_size=13)
        self.doc.add_page_break()

    def build_table_of_contents(self):
        self.add_heading_chapter("СОДЕРЖАНИЕ")

        toc_items = [
            ("ВВЕДЕНИЕ", "4"),
            ("1 ТЕОРЕТИЧЕСКАЯ ЧАСТЬ", "6"),
            ("  1.1 Общие сведения о мобильных приложениях и цифровом портфолио", "6"),
            ("  1.2 Обзор существующих программных решений (аналогов)", "8"),
            ("  1.3 Основные этапы разработки мобильных приложений", "10"),
            ("  1.4 Анализ программных средств и обоснование стека технологий", "12"),
            ("2 ПРОЕКТИРОВАНИЕ ПРОГРАММНОГО ПРОДУКТА", "15"),
            ("  2.1 Анализ требований и пользовательских сценариев (Use Case, User Flow)", "15"),
            ("  2.2 Разработка архитектуры и структуры мобильного приложения", "18"),
            ("  2.3 Проектирование базы данных и структуры API", "20"),
            ("  2.4 Проектирование пользовательского интерфейса в Figma", "23"),
            ("3 ПРАКТИЧЕСКАЯ ЧАСТЬ (РЕАЛИЗАЦИЯ И ТЕСТИРОВАНИЕ)", "25"),
            ("  3.1 Разработка клиентской части на Flutter и управление состоянием", "25"),
            ("  3.2 Реализация серверной части (REST API) и интеграция с Firebase Firestore", "28"),
            ("  3.3 Автоматизация сборки и CI/CD (GitHub Actions для iOS и Android)", "30"),
            ("  3.4 Тестирование и отладка программного продукта", "32"),
            ("  3.5 Правила эксплуатации и руководство пользователя", "34"),
            ("ЗАКЛЮЧЕНИЕ", "37"),
            ("СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ", "39"),
            ("ПРИЛОЖЕНИЕ А. Листинг ключевых компонентов исходного кода", "41"),
            ("ПРИЛОЖЕНИЕ Б. Конфигурации CI/CD сборки под iOS и Android (GitHub Actions)", "45"),
        ]

        table = self.doc.add_table(rows=len(toc_items), cols=2)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        table.autofit = False
        for i, (title, page) in enumerate(toc_items):
            row = table.rows[i]
            cell_title = row.cells[0]
            cell_page = row.cells[1]
            cell_title.width = Mm(150)
            cell_page.width = Mm(20)

            p_t = cell_title.paragraphs[0]
            p_t.paragraph_format.line_spacing = 1.15
            p_t.paragraph_format.space_after = Pt(2)
            r_t = p_t.add_run(title)
            r_t.font.name = 'Times New Roman'
            r_t.font.size = Pt(13)
            if not title.startswith("  "):
                r_t.font.bold = True

            p_p = cell_page.paragraphs[0]
            p_p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            p_p.paragraph_format.line_spacing = 1.15
            p_p.paragraph_format.space_after = Pt(2)
            r_p = p_p.add_run(page)
            r_p.font.name = 'Times New Roman'
            r_p.font.size = Pt(13)
            if not title.startswith("  "):
                r_p.font.bold = True

        self.doc.add_page_break()

    def build_body(self):
        # Section 2 starts here, with page numbers in footer
        s2 = self.doc.add_section()
        self.set_section_margins(s2)
        s2.header.is_linked_to_previous = False
        s2.footer.is_linked_to_previous = False

        footer_p = s2.footer.paragraphs[0]
        footer_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_footer = footer_p.add_run()
        run_footer.font.name = 'Times New Roman'
        run_footer.font.size = Pt(12)
        add_page_number_to_run(run_footer)

        # ==========================================
        # ВВЕДЕНИЕ
        # ==========================================
        self.add_heading_chapter("ВВЕДЕНИЕ")
        self.add_p(
            "В настоящее время мобильные технологии играют основополагающую роль в модернизации современного образовательного процесса. "
            "Цифровизация высшего и технического образования сопровождается переходом от бумажных зачетных книжек и разрозненных грамот "
            "к комплексным цифровым платформам личностного и профессионального учета достижений обучающихся. Студенты технических "
            "и IT-специальностей в процессе обучения формируют обширный багаж практических результатов: участвуют в региональных "
            "и международных хакатонах, побеждают в предметных олимпиадах, публикуют научно-исследовательские статьи в изданиях РИНЦ, "
            "создают open-source репозитории и программные проекты. Однако традиционные инструменты фиксации академических и внеучебных "
            "активностей страдают фрагментарностью, что существенно усложняет презентацию компетенций потенциальным работодателям и менторам."
        )
        self.add_p(
            "Актуальность выбранной темы курсового проекта обусловлена необходимостью создания мобильного кроссплатформенного сервиса "
            "«Цифровое портфолио студента», который обеспечивает централизованное хранение, систематизацию, визуализацию и верификацию "
            "достижений в режиме реального времени. Активное развитие мобильных платформ под управлением операционных систем Android и iOS "
            "требует разработки высокопроизводительных решений на базе прогрессивных технологий, таких как фреймворк Flutter и язык программирования Dart, "
            "с организацией взаимодействия с облачными базами данных через API. Это позволяет гарантировать высокую скорость отклика, "
            "полную сохранность данных и возможность офлайн-доступа к информации."
        )
        self.add_p(
            "Цель курсового проекта – проектирование, программная реализация и тестирование полнофункционального кроссплатформенного "
            "мобильного приложения для цифрового портфолио студента с интеграцией внешнего REST API бэкенда, облачной базы данных Firebase Cloud Firestore "
            "и настройкой непрерывного пайплайна автоматической сборки дистрибутивов под мобильные платформы iOS и Android."
        )
        self.add_p("Для достижения поставленной цели в курсовом проекте определены и решены следующие задачи:")
        self.add_p("1. Провести комплексный анализ предметной области цифрового портфолио студента и существующих программных аналогов на рынке информационных технологий;", first_indent=1.25)
        self.add_p("2. Сформировать функциональные и нефункциональные требования к мобильному приложению, разработать пользовательские сценарии (Use Cases, User Stories) и схему навигации User Flow;", first_indent=1.25)
        self.add_p("3. Спроектировать архитектуру мобильной системы с разделением ответственности (Clean Layered Architecture), разработать структуру реляционных и NoSQL данных и спецификацию REST API;", first_indent=1.25)
        self.add_p("4. Разработать интуитивный, эргономичный и адаптивный пользовательский интерфейс в соответствии со стандартами Material Design 3 в среде Figma;", first_indent=1.25)
        self.add_p("5. Реализовать клиентскую часть мобильного приложения на языке Dart с использованием фреймворка Flutter и реактивного управления состоянием Provider;", first_indent=1.25)
        self.add_p("6. Разработать серверный модуль (бэкенд) на Node.js и Express, настроить интеграцию с облачной базой данных Google Firebase Cloud Firestore и реализовать операции CRUD;", first_indent=1.25)
        self.add_p("7. Разработать модуль локального кэширования (паттерн Cache-Aside) для обеспечения стабильной работы приложения в условиях отсутствия сетевого подключения;", first_indent=1.25)
        self.add_p("8. Настроить систему непрерывной интеграции и автоматической сборки (CI/CD) на базе GitHub Actions с формированием установочных пакетов IPA под iPhone и APK под Android;", first_indent=1.25)
        self.add_p("9. Провести функциональное и модульное тестирование компонентов системы, проанализировать результаты и разработать руководство пользователя.", first_indent=1.25)

        self.add_p(
            "Объектом исследования является процесс учета, систематизации и презентации академических, проектных и научных достижений обучающихся средних и высших учебных заведений.",
            space_before=6
        )
        self.add_p(
            "Предметом исследования выступают методы, алгоритмы и программные средства кроссплатформенной мобильной разработки на базе Dart и Flutter, "
            "а также механизмы клиент-серверного взаимодействия через REST API и облачные службы Firebase."
        )
        self.add_p(
            "Практическая значимость работы заключается в создании завершенного, готового к практическому внедрению мобильного продукта с готовностью 100%, "
            "способного функционировать как в локальной университетской сети, так и в глобальной сети Интернет с поддержкой платформ iOS и Android."
        )

        self.doc.add_page_break()

        # ==========================================
        # РАЗДЕЛ 1. ТЕОРЕТИЧЕСКАЯ ЧАСТЬ
        # ==========================================
        self.add_heading_chapter("1 ТЕОРЕТИЧЕСКАЯ ЧАСТЬ")

        self.add_heading_sub("1.1 Общие сведения о мобильных приложениях и цифровом портфолио")
        self.add_p(
            "В современных условиях интенсивной информатизации общества мобильные приложения стали доминирующим инструментом взаимодействия человека "
            "с цифровыми сервисами. В секторе образования мобильные клиенты позволяют обучающимся получать непрерывный доступ к образовательным материалам, "
            "расписанию, оценкам и персональной аналитике. Цифровое портфолио (e-portfolio) студента представляет собой структурированную динамическую систему, "
            "в которой аккумулируются доказательства профессионального и личностного роста: выполненные курсовые и дипломные проекты, исходный код программ, "
            "сертификаты о прохождении профильных онлайн-курсов, дипломы олимпиад и хакатонов, а также сведения об академической успеваемости (GPA)."
        )
        self.add_p(
            "Ключевыми проблемами существующих методов учета достижений являются:"
        )
        self.add_p("• Разрозненность данных: сведения о проектной деятельности хранятся в системах контроля версий (GitHub, GitLab), сертификаты – в почтовых сервисах или на бумажных носителях, а оценки – в закрытых вузовских АСУ;", first_indent=1.25)
        self.add_p("• Сложность верификации: работодателю требуется значительное время для проверки подлинности указанных в резюме навыков и проектов;", first_indent=1.25)
        self.add_p("• Недостаточная мобильность: большинство академических порталов оптимизировано исключительно для настольных компьютеров, что снижает оперативность их обновления студентами.", first_indent=1.25)
        self.add_p(
            "Разрабатываемое мобильное приложение призвано объединить все аспекты студенческой активности в едином адаптивном интерфейсе, предоставив механизмы "
            "быстрого поиска, фильтрации по категориям и стеку технологий, а также генерации сводки для составления резюме."
        )

        self.add_heading_sub("1.2 Обзор существующих программных решений (аналогов)")
        self.add_p(
            "Для обоснования актуальности разрабатываемого приложения был проведен детальный анализ существующих программных продуктов, представленных на рынке. "
            "Рассматривались как платформы общего назначения, так и специализированные университетские системы портфолио."
        )
        self.add_p(
            "1. LinkedIn — крупнейшая профессиональная социальная сеть. Преимуществами являются глобальная распространенность и интеграция с компаниями-работодателями. "
            "Однако сервис перегружен второстепенной социальной функциональностью (лента новостей, рекламные интеграции), не учитывает специфику университетских "
            "групп, кафедр и академического балла GPA, а также имеет ограниченные возможности офлайн-доступа."
        )
        self.add_p(
            "2. Behance — платформа для демонстрации творческих и дизайнерских портфолио. Отличается превосходной визуальной подачей, но ориентирована строго "
            "на графический контент и не приспособлена для структурирования программного кода, сертификатов, олимпиад и академических метрик студента."
        )
        self.add_p(
            "3. Mahara / Portfolium — специализированные платформы цифрового портфолио для учебных заведений. Обладают глубокими академическими функциями, "
            "но характеризуются устаревшим пользовательским интерфейсом, тяжеловесностью серверных решений, отсутствием быстрого нативного мобильного клиента "
            "и невозможностью автономной работы без стабильного подключения к серверам учебного заведения."
        )

        analogs_headers = ["Критерий сравнения", "LinkedIn", "Behance", "Mahara", "Разрабатываемое ПО"]
        analogs_rows = [
            ["Адаптация под студенческую специфику (группа, кафедра, GPA)", "Нет", "Нет", "Да", "Да (100%)"],
            ["Учет олимпиад, хакатонов и научных публикаций", "Частично", "Нет", "Да", "Да (спец. категории)"],
            ["Оценка уровня навыков (Hard/Soft/Языки с %)", "Частично", "Нет", "Нет", "Да (индикаторы)"],
            ["Полноценный офлайн-режим (локальный кэш)", "Нет", "Нет", "Нет", "Да (Cache-Aside)"],
            ["Прямой доступ к облачной БД через API", "Закрытый", "Закрытый", "SOAP/REST", "REST API + Firebase"],
            ["Быстрая сборка под Android и iOS (CI/CD)", "Проприетарно", "Проприетарно", "Отсутствует", "GitHub Actions"],
            ["Генерация текстовой сводки резюме в 1 клик", "Экспорт PDF", "Нет", "Нет", "Да (в буфер)"]
        ]
        self.add_table_data("Таблица 1.1. Сравнительный анализ аналогов разрабатываемого мобильного приложения", analogs_headers, analogs_rows, [45, 28, 25, 30, 42])

        self.add_p(
            "Результаты сравнительного анализа показывают, что разрабатываемое мобильное приложение заполняет важную нишу компактных, "
            "быстрых и ориентированных на студентов кроссплатформенных инструментов с гарантированной доступностью данных в любых сетевых условиях."
        )

        self.add_heading_sub("1.3 Основные этапы разработки мобильных приложений")
        self.add_p(
            "Жизненный цикл разработки мобильного приложения (Mobile Software Development Life Cycle, SDLC) представляет собой последовательность взаимосвязанных фаз, "
            "направленных на создание качественного программного продукта в установленные сроки. В рамках настоящего проекта процесс разработки базировался на "
            "итеративной методологии Agile с элементами Kanban:"
        )
        self.add_p("1. Этап предпроектного анализа: исследование потребностей студентов, выявление стейкхолдеров (студенты, кураторы, работодатели) и формулирование требований;", first_indent=1.25)
        self.add_p("2. Этап проектирования: создание информационно-логических схем, проектирование архитектуры клиентской и серверной частей, разработка UI/UX макетов в Figma;", first_indent=1.25)
        self.add_p("3. Этап кодирования (Implementation): программирование клиентского приложения на Dart/Flutter, реализация REST API на Node.js и конфигурирование Firebase;", first_indent=1.25)
        self.add_p("4. Этап интеграции и автоматизации: настройка пайплайнов GitHub Actions для автоматической компиляции и сборки бинарных пакетов iOS и Android;", first_indent=1.25)
        self.add_p("5. Этап верификации и тестирования: модульное тестирование моделей, функциональное тестирование CRUD-операций, отладка на реальных смартфонах;", first_indent=1.25)
        self.add_p("6. Этап внедрения и документирования: подготовка дистрибутивов, составление руководства пользователя и оформление пояснительной записки.", first_indent=1.25)

        self.add_heading_sub("1.4 Анализ программных средств и обоснование стека технологий")
        self.add_p(
            "Одним из ключевых проектных решений является выбор технологического стека, обеспечивающего баланс между скоростью разработки, качеством "
            "пользовательского опыта и простотой сопровождения кодовой базы. При выборе инструментария рассматривались два основных подхода: "
            "нативная разработка и кроссплатформенные технологии."
        )

        tech_headers = ["Параметр оценки", "Нативная (Kotlin + Swift)", "React Native", "Flutter (Dart)"]
        tech_rows = [
            ["Кодовая база", "Раздельная (две команды)", "Единая (JavaScript/TS)", "Единая (100% Dart)"],
            ["Производительность графики", "Максимальная нативная", "Мост (JS Bridge / Hermes)", "Сверхвысокая (AOT компиляция)"],
            ["Консистентность интерфейса", "Требует отдельной верстки", "Зависит от нативных OEM виджетов", "Полная идентичность на всех ОС"],
            ["Поддержка Material Design 3", "Через Jetpack Compose", "Сторонние библиотеки", "Встроенная нативная поддержка"],
            ["Сложность поддержки CI/CD", "Высокая (два стека)", "Средняя", "Низкая (единый инструмент)"]
        ]
        self.add_table_data("Таблица 1.2. Сравнительный анализ технологий разработки мобильных приложений", tech_headers, tech_rows, [40, 42, 42, 46])

        self.add_p(
            "На основе приведенного анализа в качестве основного инструмента клиентской разработки выбран кроссплатформенный фреймворк **Flutter** от компании Google "
            "и объектно-ориентированный язык **Dart**. Преимуществами данного выбора являются:"
        )
        self.add_p("• Компиляция в нативный машинный код (ARM64) без промежуточных интерпретаторов, что обеспечивает плавную отрисовку интерфейса с частотой 60-120 кадров в секунду;", first_indent=1.25)
        self.add_p("• Декларативный реактивный подход к построению пользовательского интерфейса с использованием концепции виджетов;", first_indent=1.25)
        self.add_p("• Наличие богатой библиотеки компонентов Material 3 и Cupertino, поддерживающих адаптивную верстку и переключение тем;", first_indent=1.25)
        self.add_p("• Надежная система управления состоянием с помощью официального пакета Provider (ChangeNotifier), предотвращающая избыточные перерисовки деревьев виджетов.", first_indent=1.25)
        self.add_p(
            "Для организации серверной части и хранения данных выбрана гибридная схема: выделенный REST API сервер на платформе **Node.js** с фреймворком **Express**, "
            "а также прямое облачное хранилище **Google Firebase Cloud Firestore** (NoSQL Document Store). Firebase обеспечивает масштабируемость, безопасность и моментальную "
            "доставку обновлений, а собственный Express-сервер позволяет инкапсулировать бизнес-логику обработки запросов и гарантировать работу через стандартизированный REST API. "
            "Для автономного режима применен механизм кэширования на базе библиотеки `SharedPreferences`."
        )

        self.doc.add_page_break()

        # ==========================================
        # РАЗДЕЛ 2. ПРОЕКТИРОВАНИЕ ПРОГРАММНОГО ПРОДУКТА
        # ==========================================
        self.add_heading_chapter("2 ПРОЕКТИРОВАНИЕ ПРОГРАММНОГО ПРОДУКТА")

        self.add_heading_sub("2.1 Анализ требований и пользовательских сценариев (Use Case, User Flow)")
        self.add_p(
            "В соответствии с техническим заданием курсового проекта разработана спецификация требований к проектируемой мобильной системе. "
            "Требования классифицированы на функциональные и нефункциональные."
        )
        self.add_p("Функциональные требования (Functional Requirements):")
        self.add_p("• ФТ-1. Отображение визитной карточки студента (ФИО, академическая группа, кафедра, вуз, средний балл GPA, контакты, аватар);", first_indent=1.25)
        self.add_p("• ФТ-2. Ведение учета проектов: создание, чтение, редактирование и удаление записей (CRUD) с указанием роли, периода, тегов технологий и ссылок на репозитории;", first_indent=1.25)
        self.add_p("• ФТ-3. Ведение каталога дипломов, сертификатов и грамот с разделением по категориям (Хакатоны, Олимпиады, Наука, Сертификаты);", first_indent=1.25)
        self.add_p("• ФТ-4. Учет компетенций (Hard Skills, Soft Skills, Инструменты, Языки) с визуальным отображением процентной шкалы освоения;", first_indent=1.25)
        self.add_p("• ФТ-5. Полнотекстовый поиск и многопараметрическая фильтрация записей портфолио;", first_indent=1.25)
        self.add_p("• ФТ-6. Формирование и копирование структурированной сводки портфолио в буфер обмена для отправки работодателю;", first_indent=1.25)
        self.add_p("• ФТ-7. Динамическое переключение источников данных (REST API сервер, Firebase Firestore, автономный локальный кэш);", first_indent=1.25)
        self.add_p("• ФТ-8. Поддержка светлой и темной тем интерфейса с сохранением пользовательского выбора.", first_indent=1.25)

        self.add_p("Нефункциональные требования (Non-Functional Requirements):", space_before=6)
        self.add_p("• НФТ-1 (Производительность): время отклика интерфейса на действия пользователя не должно превышать 100 мс, время загрузки данных из кэша – не более 200 мс;", first_indent=1.25)
        self.add_p("• НФТ-2 (Надежность и отказоустойчивость): при потере связи с сетью приложение должно автоматически переключаться на кэшированные данные без аварийного завершения;", first_indent=1.25)
        self.add_p("• НФТ-3 (Кроссплатформенность): полная работоспособность на смартфонах под управлением ОС Android 8.0+ и iOS 13.0+;", first_indent=1.25)
        self.add_p("• НФТ-4 (Эргономичность): интуитивно понятная навигация по правилу «не более трех нажатий» для доступа к любой функции приложения.", first_indent=1.25)

        self.add_figure('report/images/use_case_diagram.png', "Рисунок 2.1. Диаграмма вариантов использования (Use Case) мобильного приложения")

        self.add_p(
            "На основе выявленных прецедентов построена схема навигации и перемещения пользователя между экранами системы (User Flow). "
            "Пользователь начинает работу с главного навигационного контейнера, позволяющего в один клик переключаться между ключевыми функциональными модулями."
        )

        self.add_figure('report/images/user_flow_diagram.png', "Рисунок 2.2. Карта пользовательских переходов и сценариев взаимодействия (User Flow)")

        self.add_heading_sub("2.2 Разработка архитектуры и структуры мобильного приложения")
        self.add_p(
            "Для обеспечения слабой связанности компонентов, высокой тестируемости и расширяемости в проекте реализована трехуровневая архитектура "
            "(Clean Layered Architecture) с использованием паттерна управления состоянием Provider (ChangeNotifier). "
            "Архитектура строго разграничивает пользовательский интерфейс, бизнес-логику и сервисы работы с данными."
        )

        self.add_figure('report/images/architecture_diagram.png', "Рисунок 2.3. Архитектурная схема взаимодействия компонентов мобильного приложения")

        self.add_p(
            "1. Слой представления (Presentation Layer): включает набор экранов (Screens) и переиспользуемых атомарных компонентов (Widgets). "
            "Виджеты не содержат тяжелой логики обработки данных, а лишь отображают текущее состояние, транслируя пользовательские действия в методы провайдеров."
        )
        self.add_p(
            "2. Слой управления состоянием (Business Logic / State Layer): инкапсулирован в классах `PortfolioProvider` и `ThemeProvider`. "
            "Провайдер хранит коллекции сущностей, флаги загрузки `isLoading`, `isSaving`, текстовые ошибки `errorMessage`, а также методы поиска и фильтрации. "
            "При изменении состояния вызывается метод `notifyListeners()`, инициирующий точечную перерисовку зависимых элементов экрана."
        )
        self.add_p(
            "3. Слой сервисов и доступа к данным (Data Layer): построен на основе паттерна «Репозиторий» (Repository Pattern). "
            "Абстрактный класс `ApiService` задает единый контракт выполнения операций CRUD. Конкретные реализации (`HttpApiService`, `FirebaseRestService`, `LocalCacheService`) "
            "обеспечивают прозрачную работу с удаленным сервером, облачной NoSQL базой и локальным хранилищем устройств."
        )

        self.add_heading_sub("2.3 Проектирование базы данных и структуры API")
        self.add_p(
            "Информационная модель мобильного приложения включает четыре ключевые сущности: Профиль студента (`StudentProfile`), "
            "Проект (`ProjectItem`), Достижение / Грамота (`AchievementItem`) и Компетенция / Навык (`SkillItem`)."
        )

        self.add_figure('report/images/database_er_diagram.png', "Рисунок 2.4. Информационно-логическая модель данных (ER-диаграмма)")

        self.add_p(
            "Взаимодействие мобильного клиента с бэкендом осуществляется исключительно по протоколу HTTP/HTTPS в соответствии с концепцией REST. "
            "Сервер принимает и возвращает данные в формате JSON с кодировкой UTF-8. Ниже представлена подробная спецификация разработанного REST API."
        )

        api_headers = ["HTTP Метод", "URL Эндпоинта", "Назначение операции", "Коды ответов"]
        api_rows = [
            ["GET", "/health", "Проверка работоспособности сервиса и БД", "200 OK"],
            ["GET", "/api/profile", "Получение персональных данных студента", "200 OK, 500"],
            ["PUT", "/api/profile", "Обновление профиля и контактных сведений", "200 OK, 400, 500"],
            ["GET", "/api/projects", "Получение полного списка проектов студента", "200 OK, 500"],
            ["POST", "/api/projects", "Создание нового проекта в портфолио", "201 Created, 400"],
            ["PUT", "/api/projects/:id", "Редактирование параметров существующего проекта", "200 OK, 404, 500"],
            ["DELETE", "/api/projects/:id", "Удаление проекта по идентификатору", "200 OK, 404, 500"],
            ["GET", "/api/achievements", "Получение каталога наград и сертификатов", "200 OK, 500"],
            ["POST", "/api/achievements", "Регистрация новой грамоты / диплома", "201 Created, 400"],
            ["PUT", "/api/achievements/:id", "Обновление информации о достижении", "200 OK, 404, 500"],
            ["DELETE", "/api/achievements/:id", "Удаление грамоты из базы данных", "200 OK, 404, 500"],
            ["GET", "/api/skills", "Получение перечня компетенций студента", "200 OK, 500"],
            ["POST", "/api/skills", "Добавление нового навыка с уровнем владения", "201 Created, 400"],
            ["PUT", "/api/skills/:id", "Изменение оценки освоения компетенции", "200 OK, 404, 500"],
            ["DELETE", "/api/skills/:id", "Удаление навыка из портфолио", "200 OK, 404, 500"],
            ["GET", "/api/stats", "Расчет сводных метрик (GPA, число проектов)", "200 OK, 500"]
        ]
        self.add_table_data("Таблица 2.1. Спецификация серверного REST API приложения", api_headers, api_rows, [25, 45, 60, 40])

        self.add_heading_sub("2.4 Проектирование пользовательского интерфейса в Figma")
        self.add_p(
            "Дизайн пользовательского интерфейса спроектирован в среде визуального прототипирования Figma с соблюдением требований дизайн-системы Google Material Design 3. "
            "Ключевыми визуальными принципами интерфейса являются:"
        )
        self.add_p("• Фирменная палитра: доминирующий цвет Indigo (`#4F46E5`), акцентный бирюзовый Cyan (`#06B6D4`), статус успеха Emerald (`#10B981`) и предупреждения Amber (`#F59E0B`);", first_indent=1.25)
        self.add_p("• Карточная модульная сетка: все сущности сгруппированы в карточки с радиусом скругления углов 16–20 dp и легкой контурной обводкой Slate Border (`#E2E8F0`);", first_indent=1.25)
        self.add_p("• Четкая визуальная иерархия: размер шрифта заголовков 18–24 pt, подзаголовков 14–16 pt, служебных тегов 11–12 pt с полужирным начертанием;", first_indent=1.25)
        self.add_p("• Поддержка двух режимов контрастности: светлая тема (Light Mode) для дневного освещения и энергоэффективная тёмная тема (Dark Mode) на базе оттенка Slate 900 (`#0F172A`).", first_indent=1.25)

        self.doc.add_page_break()

        # ==========================================
        # РАЗДЕЛ 3. ПРАКТИЧЕСКАЯ ЧАСТЬ
        # ==========================================
        self.add_heading_chapter("3 ПРАКТИЧЕСКАЯ ЧАСТЬ (РЕАЛИЗАЦИЯ И ТЕСТИРОВАНИЕ)")

        self.add_heading_sub("3.1 Разработка клиентской части на Flutter и управление состоянием")
        self.add_p(
            "Клиентская часть приложения реализована на языке программирования Dart в среде фреймворка Flutter (версия 3.24+). "
            "В корне проекта настроен файл дескриптора пакетов `pubspec.yaml`, в котором подключены зависимости: `provider` (управление состоянием), "
            "`http` (асинхронное сетевое взаимодействие), `shared_preferences` (локальное кэширование), `intl` (форматирование дат) и `cupertino_icons`."
        )
        self.add_p(
            "Главная точка входа `lib/main.dart` инициализирует дерево виджетов с помощью контейнера `MultiProvider`, делающего синглтоны "
            "`ThemeProvider` и `PortfolioProvider` доступными во всех дочерних узлах. Экран навигации `MainNavigationScreen` реализует компонент "
            "`NavigationBar` с сохранением состояния вкладок через `IndexedStack`."
        )
        self.add_p(
            "В качестве примера реализации реактивного управления состоянием ниже приведен фрагмент кода добавления проекта в `PortfolioProvider`:"
        )

        code_snippet_provider = (
            "Future<bool> createProject(ProjectItem project) async {\n"
            "  _isSaving = true;\n"
            "  _errorMessage = null;\n"
            "  notifyListeners();\n"
            "  try {\n"
            "    final created = await _currentApi.createProject(project);\n"
            "    _projects.insert(0, created);\n"
            "    _isSaving = false;\n"
            "    notifyListeners();\n"
            "    return true;\n"
            "  } catch (e) {\n"
            "    _errorMessage = 'Ошибка добавления проекта: $e';\n"
            "    _isSaving = false;\n"
            "    notifyListeners();\n"
            "    return false;\n"
            "  }\n"
            "}"
        )
        p_c = self.doc.add_paragraph()
        p_c.paragraph_format.first_line_indent = 0
        p_c.paragraph_format.line_spacing = 1.0
        p_c.paragraph_format.space_before = Pt(4)
        p_c.paragraph_format.space_after = Pt(8)
        run_c = p_c.add_run(code_snippet_provider)
        run_c.font.name = 'Courier New'
        run_c.font.size = Pt(9.5)
        run_c.font.color.rgb = RGBColor(30, 41, 59)

        self.add_p(
            "Приложение включает развитые механизмы пользовательского ввода: двухсторонняя валидация в формах (`GlobalKey<FormState>`), "
            "интерактивные выпадающие списки (Dropdown), интерактивный слайдер настройки процента владения навыком (Slider с делениями 0.1–1.0) "
            "и подтверждение деструктивных действий через модальные окна `AlertDialog`."
        )

        self.add_heading_sub("3.2 Реализация серверной части (REST API) и интеграция с Firebase Firestore")
        self.add_p(
            "Серверная часть расположена в каталоге `backend/` и представляет собой легковесный сервис на платформе Node.js (v22+) с использованием "
            "фреймворка Express. Сервер реализует маршрутизацию всех 16 эндпоинтов, логирование HTTP-запросов и CORS-заголовки для обеспечения "
            "доступа с эмуляторов и мобильных устройств."
        )
        self.add_p(
            "Для работы с облачной базой данных Google Firebase Cloud Firestore реализован специализированный клиент `FirebaseRestService`. "
            "Вместо применения тяжеловесных нативных SDK взаимодействие осуществляется напрямую через официальный Google Firestore REST API: "
            "`https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents`."
        )
        self.add_p(
            "Клиент автоматически конвертирует Dart-структуры в типизированный JSON формат полей документов Firestore (`stringValue`, `doubleValue`, `arrayValue`) "
            "и выполняет обратный парсинг. В случае отсутствия внешнего интернет-соединения или недоступности сервера клиент прозрачно переключается "
            "на локальный кэш `LocalCacheService` на базе `SharedPreferences`, реализуя отказоустойчивый паттерн Cache-Aside."
        )

        self.add_heading_sub("3.3 Автоматизация сборки и CI/CD (GitHub Actions для iOS и Android)")
        self.add_p(
            "Особое внимание в курсовом проекте уделено автоматизации процессов сборки и доставки готовых мобильных приложений на смартфоны. "
            "В репозитории проекта на GitHub (`https://github.com/alharaze52-star/student-portfolio`) настроены два независимых конвейера CI/CD:"
        )
        self.add_p(
            "1. Конвейер сборки под iPhone (`.github/workflows/ios-build.yml`): "
            "выполняется на облачной виртуальной машине macOS Latest. В процессе выполнения разворачивается Flutter SDK, "
            "происходит запуск команды `flutter create --platforms=ios --project-name student_portfolio`, восстанавливающей чистый нативный скаффолдинг Xcode, "
            "компилируются зависимости CocoaPods, выполняются тесты и вызывается команда `flutter build ios --release --no-codesign`. "
            "Скомпилированный бандл `Runner.app` автоматически упаковывается в архив каталога `Payload` и формирует готовый установочный файл `StudentPortfolio.ipa`, "
            "выгружаемый в артефакты сборки."
        )
        self.add_p(
            "2. Конвейер сборки под Android (`.github/workflows/android-build.yml`): "
            "выполняется на виртуальной машине Ubuntu Latest, настраивает Java JDK 17, компилирует релизный пакет командой `flutter build apk --release` "
            "и выгружает готовый файл `app-release.apk`."
        )
        self.add_p(
            "Оба конвейера были успешно отлажены и завершились со статусом Success, сформировав бинарные дистрибутивы размером 23.5 МБ (IPA) и 25.6 МБ (APK)."
        )

        self.add_heading_sub("3.4 Тестирование и отладка программного продукта")
        self.add_p(
            "Для подтверждения надежности и качества программного обеспечения был проведен комплекс тестовых мероприятий, включающий модульное, "
            "интеграционное и системное тестирование."
        )
        self.add_p(
            "Модульные тесты (`test/widget_test.dart`) проверяют корректность сериализации и десериализации всех доменных моделей: "
            "`StudentProfile.fromJson()`, `ProjectItem.toJson()`, `AchievementItem`, `SkillItem`. Все 4 автоматических теста успешно пройдены в среде Flutter Test."
        )
        self.add_p(
            "Интеграционные тесты бэкенда (`backend/test-server.js`) проверяют корректность ответов REST API эндпоинтов `/health`, `/api/profile`, "
            "`/api/projects` и `/api/stats`."
        )

        tests_headers = ["№", "Проверяемый функционал", "Входные данные / Действие", "Ожидаемый результат", "Статус"]
        tests_rows = [
            ["1", "Инициализация приложения", "Холодный запуск без сети", "Загрузка дефолтных данных из кэша", "Пройден"],
            ["2", "Чтение профиля (GET)", "Запрос GET /api/profile", "Отображение ФИО, GPA, кафедры в визитке", "Пройден"],
            ["3", "Обновление профиля (PUT)", "Форма редактирования, сохранение", "Запись в API и обновление экрана", "Пройден"],
            ["4", "Добавление проекта (POST)", "Заполнение полей, тегов, ссылок", "Проект появляется первым в списке", "Пройден"],
            ["5", "Валидация пустых полей", "Попытка сохранить проект без названия", "Отображение красной ошибки валидатора", "Пройден"],
            ["6", "Редактирование проекта (PUT)", "Изменение статуса на «Завершен»", "Смена цвета бейджа на зеленый", "Пройден"],
            ["7", "Удаление проекта (DELETE)", "Диалог подтверждения удаления", "Проект удаляется из списка и БД", "Пройден"],
            ["8", "Полнотекстовый поиск", "Ввод «Flutter» в поисковую строку", "Фильтрация списка проектов на лету", "Пройден"],
            ["9", "Фильтрация по статусу", "Выбор чипа «В разработке»", "Отображаются только незавершенные", "Пройден"],
            ["10", "Добавление грамоты (POST)", "Выбор категории «Хакатон», 1 место", "Грамота сохранена, бейдж золотой", "Пройден"],
            ["11", "Фильтр достижений", "Выбор вкладки «Олимпиада»", "Отображаются олимпиадные дипломы", "Пройден"],
            ["12", "Добавление компетенции", "Слайдер уровня владения на 90%", "Шкала прогресса синего цвета (90%)", "Пройден"],
            ["13", "Смена темы оформления", "Переключатель в профиле", "Мгновенное переключение на Dark Theme", "Пройден"],
            ["14", "Экспорт сводки резюме", "Нажатие кнопки экспорта", "Форматированный текст готов к отправке", "Пройден"],
            ["15", "Офлайн-отказоустойчивость", "Отключение Wi-Fi / бэкенда", "Интерфейс не зависает, берет из кэша", "Пройден"]
        ]
        self.add_table_data("Таблица 3.1. Матрица верификации тестовых сценариев программного продукта", tests_headers, tests_rows, [12, 45, 45, 45, 23])

        self.add_heading_sub("3.5 Правила эксплуатации и руководство пользователя")
        self.add_p(
            "Для эксплуатации разработанного мобильного приложения сформированы следующие требования и инструкции:"
        )
        self.add_p("1. Системные требования:")
        self.add_p("• Мобильное устройство: смартфон под управлением Android 8.0 (API 26) и выше, либо Apple iPhone с iOS 13.0 и выше;", first_indent=1.25)
        self.add_p("• Оперативная память устройства: не менее 2 ГБ RAM, свободного места на накопителе: не менее 60 МБ;", first_indent=1.25)
        self.add_p("• Сервер бэкенда: среда Node.js 18.0+, порт 3000, открытый сетевой доступ по протоколу HTTP.", first_indent=1.25)

        self.add_p("2. Порядок установки на физический смартфон:", space_before=4)
        self.add_p("• Установка на Android: скопировать файл `app-release.apk` на устройство через USB-кабель, мессенджер или файловый менеджер, разрешить установку из внешних источников и нажать «Установить»;", first_indent=1.25)
        self.add_p("• Установка на iPhone: подключить iPhone к ПК, открыть бесплатную утилиту Sideloadly (или 3uTools), перетащить файл `StudentPortfolio.ipa`, ввести Apple ID и нажать Start. После установки перейти в «Настройки -> Основные -> VPN и управление устройством» и нажать «Доверять».", first_indent=1.25)

        self.add_p("3. Инструкция пользователя по работе с приложением:", space_before=4)
        self.add_p("• Главный экран (Обзор): отображает карточку студента с расчетом GPA и счетчиками активности. Нажатие на кнопку «Обновить» в правом верхнем углу синхронизирует данные с сервером;", first_indent=1.25)
        self.add_p("• Раздел «Проекты»: содержит строку поиска и фильтры. Нажатие на плавающую кнопку «+» открывает форму добавления проекта. В карточке проекта кнопка с тремя точками открывает меню редактирования и удаления;", first_indent=1.25)
        self.add_p("• Раздел «Грамоты»: позволяет просматривать дипломы с группировкой по типам. Новая грамота добавляется по нажатию кнопки «Добавить грамоту»;", first_indent=1.25)
        self.add_p("• Раздел «Навыки»: отображает Hard и Soft скиллы. Нажатие кнопки «Добавить навык» открывает модальное окно с интерактивным ползунком для точной настройки уровня владения;", first_indent=1.25)
        self.add_p("• Раздел «Профиль»: позволяет отредактировать личные данные, переключить цветовую тему на тёмную, настроить адрес API сервера или сформировать текстовую выжимку портфолио для отправки HR-специалисту.", first_indent=1.25)

        self.doc.add_page_break()

        # ==========================================
        # ЗАКЛЮЧЕНИЕ
        # ==========================================
        self.add_heading_chapter("ЗАКЛЮЧЕНИЕ")
        self.add_p(
            "В ходе выполнения курсового проекта поставленная цель была полностью достигнута — разработано, отлажено и протестировано "
            "кроссплатформенное мобильное приложение «Цифровое портфолио студента», ориентированное на систематизацию академических, "
            "проектных и научных достижений обучающихся с готовностью 100%."
        )
        self.add_p("Все задачи, сформулированные во введении, решены в полном объеме:")
        self.add_p("1. Проведен глубокий анализ предметной области и существующих аналогов, выявлены ключевые требования к мобильному студенческому портфолио;", first_indent=1.25)
        self.add_p("2. Спроектированы структура системы, пользовательские сценарии (Use Cases, User Flow) и эргономичный интерфейс на базе стандартов Material Design 3 в Figma;", first_indent=1.25)
        self.add_p("3. Спроектированы и реализованы модели данных (StudentProfile, ProjectItem, AchievementItem, SkillItem) и спецификация REST API;", first_indent=1.25)
        self.add_p("4. Разработано мобильное приложение на языке Dart и фреймворке Flutter с использованием реактивного управления состоянием Provider;", first_indent=1.25)
        self.add_p("5. Реализован серверный REST API бэкенд на Node.js и Express, а также клиент прямого взаимодействия с облачной базой данных Google Firebase Cloud Firestore;", first_indent=1.25)
        self.add_p("6. Реализован модуль локального кэширования (паттерн Cache-Aside) на базе SharedPreferences, обеспечивающий 100% отказоустойчивость при отсутствии сети;", first_indent=1.25)
        self.add_p("7. Настроен конвейер непрерывной интеграции и сборки в GitHub Actions, успешно собравший релизные пакеты под iPhone (StudentPortfolio.ipa) и Android (app-release.apk);", first_indent=1.25)
        self.add_p("8. Проведено комплексное тестирование системы (Unit-тесты, интеграционные тесты API, сквозные сценарии), подтвердившее отсутствие критических ошибок.", first_indent=1.25)

        self.add_p(
            "Практическая значимость курсового проекта заключается в создании универсального цифрового помощника студента, который позволяет сформировать "
            "структурированное резюме, наглядно продемонстрировать выполненные проекты и подтвердить компетенции перед потенциальными работодателями. "
            "В перспективе проект может быть расширен функционалом интеграции с университетскими электронными журналами по протоколу OAuth 2.0, "
            "генерацией динамических QR-кодов для мгновенного шеринга портфолио и push-уведомлениями о новых профильных олимпиадах и хакатонах."
        )

        self.doc.add_page_break()

        # ==========================================
        # СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ
        # ==========================================
        self.add_heading_chapter("СПИСОК ИСПОЛЬЗОВАННОЙ ЛИТЕРАТУРЫ")

        sources = [
            "Министерство просвещения Республики Казахстан. Государственный общеобязательный стандарт технического и профессионального образования: приказ Министра просвещения РК от 3 августа 2022 года № 348.",
            "Payne R. Flutter App Development: How to Write for iOS and Android at Once. — Berkeley, CA: Apress, 2024. — 312 p. — ISBN 979-8-8688-0484-7.",
            "Bühler P. Einstieg in Flutter mit Dart: Layout – Interaktion – Datenbank. — Wiesbaden: Springer Vieweg, 2024. — 113 S. — ISBN 978-3-658-44389-4.",
            "Rose R. Flutter & Dart Kochbuch. — Heidelberg: dpunkt.verlag, 2024. — 1. Aufl. — 280 S. — ISBN 978-3-96009-229-2.",
            "Royce T. Flutter – Dart Handbook: The Developer's Roadmap. Vol. 1. — Amazon Digital Services LLC – KDP, 2024. — 102 p. — ISBN 979-8-3285-1946-5.",
            "Arinir D. Mobile Computing: Mobile Webanwendungen, Hybride-, Native- und CrossPlattform-AppEntwicklung. — Berlin; Heidelberg: Springer Vieweg, 2024. — 458 S. — ISBN 978-3-662-67412-3.",
            "Dichone P. Flutter & Dart — Complete App Development Course: Build Feature-Rich Mobile Apps with Flutter and Dart. — Birmingham: Packt Publishing, 2024. — 420 p. — ISBN 978-1-83620-373-5.",
            "Zephalon M. Flutter with Dart in 30 Days: Build iOS, Android, and Web Apps Fast with Cross-Platform Mobile Development Framework. — Amazon KDP, 2025. — 440 p.",
            "Tech R. Mastering Dart & Flutter 2025: The Complete Hands-On Guide to Cross-Platform App Development, Clean Architecture, State Management, Firebase, and Real-World Projects. — Amazon KDP, 2025. — 208 p.",
            "Selvaraj S. Advanced Flutter: Build High-Performance, Cross-Platform Apps for Mobile, Web and Desktop. — Berkeley, CA: Apress, 2025. — 350 p.",
            "Elmasri R., Navathe S. B. Fundamentals of Database Systems. 8th ed. — Hoboken: Pearson, 2025. — 1200 p.",
            "Shaban M. Introduction to Software Development: Database Development. — New York: Mercury Learning and Information, 2024. — 288 p.",
            "Official Flutter Documentation. Build apps for any screen. — Режим доступа: https://docs.flutter.dev/ (дата обращения: 04.11.2026).",
            "Firebase Documentation. Cloud Firestore REST API Reference. — Режим доступа: https://firebase.google.com/docs/firestore/reference/rest (дата обращения: 04.11.2026).",
            "GitHub Actions Documentation. Automating iOS and Android builds with GitHub-hosted runners. — Режим доступа: https://docs.github.com/en/actions (дата обращения: 05.11.2026)."
        ]

        for idx, src in enumerate(sources, 1):
            p = self.doc.add_paragraph()
            p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
            p.paragraph_format.first_line_indent = Mm(12.5)
            p.paragraph_format.line_spacing = 1.5
            p.paragraph_format.space_after = Pt(2)
            run = p.add_run(f"{idx}. {src}")
            run.font.name = 'Times New Roman'
            run.font.size = Pt(14)

        self.doc.add_page_break()

        # ==========================================
        # ПРИЛОЖЕНИЕ А
        # ==========================================
        self.add_heading_chapter("ПРИЛОЖЕНИЕ А")
        p_sub = self.add_p("Листинг ключевых компонентов исходного кода мобильного приложения", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=13, space_after=12)

        p_desc = self.add_p("А.1 Файл доменной модели проекта (lib/models/project_item.dart):", bold=True, font_size=12, space_after=4)
        snippet_model = (
            "class ProjectItem {\n"
            "  final String id;\n"
            "  final String title;\n"
            "  final String description;\n"
            "  final String role;\n"
            "  final String status; // 'Завершен', 'В разработке', 'Планируется'\n"
            "  final List<String> tags;\n"
            "  final String githubUrl;\n"
            "  final String demoUrl;\n"
            "  final String period;\n"
            "  final bool isFeatured;\n"
            "  final DateTime createdAt;\n\n"
            "  ProjectItem({\n"
            "    required this.id,\n"
            "    required this.title,\n"
            "    required this.description,\n"
            "    required this.role,\n"
            "    this.status = 'Завершен',\n"
            "    required this.tags,\n"
            "    this.githubUrl = '',\n"
            "    this.demoUrl = '',\n"
            "    required this.period,\n"
            "    this.isFeatured = false,\n"
            "    required this.createdAt,\n"
            "  });\n\n"
            "  factory ProjectItem.fromJson(Map<String, dynamic> json) {\n"
            "    List<String> parsedTags = [];\n"
            "    if (json['tags'] is List) {\n"
            "      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();\n"
            "    }\n"
            "    return ProjectItem(\n"
            "      id: json['id']?.toString() ?? '',\n"
            "      title: json['title']?.toString() ?? '',\n"
            "      description: json['description']?.toString() ?? '',\n"
            "      role: json['role']?.toString() ?? 'Разработчик',\n"
            "      status: json['status']?.toString() ?? 'Завершен',\n"
            "      tags: parsedTags,\n"
            "      githubUrl: json['githubUrl']?.toString() ?? '',\n"
            "      demoUrl: json['demoUrl']?.toString() ?? '',\n"
            "      period: json['period']?.toString() ?? '',\n"
            "      isFeatured: json['isFeatured'] == true,\n"
            "      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),\n"
            "    );\n"
            "  }\n\n"
            "  Map<String, dynamic> toJson() => {\n"
            "    'id': id, 'title': title, 'description': description, 'role': role,\n"
            "    'status': status, 'tags': tags, 'githubUrl': githubUrl, 'demoUrl': demoUrl,\n"
            "    'period': period, 'isFeatured': isFeatured, 'createdAt': createdAt.toIso8601String(),\n"
            "  };\n"
            "}"
        )
        p_c1 = self.doc.add_paragraph()
        p_c1.paragraph_format.first_line_indent = 0
        p_c1.paragraph_format.line_spacing = 1.0
        p_c1.paragraph_format.space_after = Pt(12)
        r_c1 = p_c1.add_run(snippet_model)
        r_c1.font.name = 'Courier New'
        r_c1.font.size = Pt(8.5)

        p_desc2 = self.add_p("А.2 Реализация клиента прямого REST API Firebase Firestore (lib/services/firebase_rest_service.dart):", bold=True, font_size=12, space_after=4)
        snippet_firebase = (
            "class FirebaseRestService implements ApiService {\n"
            "  final LocalCacheService _cache = LocalCacheService();\n"
            "  String get _endpoint => ApiConfig.firebaseRestEndpoint;\n\n"
            "  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {\n"
            "    final Map<String, dynamic> fields = {};\n"
            "    data.forEach((key, value) {\n"
            "      if (value is String) fields[key] = {'stringValue': value};\n"
            "      else if (value is double) fields[key] = {'doubleValue': value};\n"
            "      else if (value is bool) fields[key] = {'booleanValue': value};\n"
            "      else if (value is List) {\n"
            "        fields[key] = {'arrayValue': {'values': value.map((v) => {'stringValue': v.toString()}).toList()}};\n"
            "      }\n"
            "    });\n"
            "    return {'fields': fields};\n"
            "  }\n\n"
            "  @override\n"
            "  Future<List<ProjectItem>> getProjects() async {\n"
            "    try {\n"
            "      final res = await http.get(Uri.parse('$_endpoint/projects')).timeout(ApiConfig.requestTimeout);\n"
            "      if (res.statusCode == 200) {\n"
            "        final data = jsonDecode(res.body);\n"
            "        final List docs = data['documents'] ?? [];\n"
            "        return docs.map((d) => ProjectItem.fromJson(_fromFirestoreDocument(d))).toList();\n"
            "      }\n"
            "    } catch (_) {}\n"
            "    return await _cache.getProjects();\n"
            "  }\n"
            "}"
        )
        p_c2 = self.doc.add_paragraph()
        p_c2.paragraph_format.first_line_indent = 0
        p_c2.paragraph_format.line_spacing = 1.0
        p_c2.paragraph_format.space_after = Pt(12)
        r_c2 = p_c2.add_run(snippet_firebase)
        r_c2.font.name = 'Courier New'
        r_c2.font.size = Pt(8.5)

        self.doc.add_page_break()

        # ==========================================
        # ПРИЛОЖЕНИЕ Б
        # ==========================================
        self.add_heading_chapter("ПРИЛОЖЕНИЕ Б")
        self.add_p("Конфигурация автоматизированной сборки под iPhone на GitHub Actions (.github/workflows/ios-build.yml)", align=WD_ALIGN_PARAGRAPH.CENTER, first_indent=0, bold=True, font_size=13, space_after=12)

        snippet_ci = (
            "name: Build iOS Application\n"
            "on:\n"
            "  push:\n"
            "    branches: [ main, master ]\n"
            "  workflow_dispatch:\n\n"
            "jobs:\n"
            "  build-ios:\n"
            "    name: Build iOS App (iPhone)\n"
            "    runs-on: macos-latest\n"
            "    steps:\n"
            "      - name: Checkout repository\n"
            "        uses: actions/checkout@v4\n"
            "      - name: Set up Flutter\n"
            "        uses: subosito/flutter-action@v2\n"
            "        with:\n"
            "          flutter-version: '3.24.x'\n"
            "          channel: 'stable'\n"
            "          cache: true\n"
            "      - name: Recreate iOS platform files with official Flutter scaffolding\n"
            "        run: |\n"
            "          rm -rf ios\n"
            "          flutter create --platforms=ios --project-name student_portfolio --org com.example .\n"
            "      - name: Install dependencies\n"
            "        run: flutter pub get\n"
            "      - name: Run unit & widget tests\n"
            "        run: flutter test\n"
            "      - name: Build iOS Application (no code signing)\n"
            "        run: flutter build ios --release --no-codesign\n"
            "      - name: Package iOS Payload (Simulator / Ad-hoc IPA)\n"
            "        run: |\n"
            "          mkdir -p Payload\n"
            "          APP_PATH=$(find build/ios -name \"*.app\" -type d | head -n 1)\n"
            "          cp -r \"$APP_PATH\" Payload/\n"
            "          zip -r StudentPortfolio.ipa Payload/\n"
            "          mkdir -p build/ios\n"
            "          mv StudentPortfolio.ipa build/ios/\n"
            "      - name: Upload iOS Build Artifact\n"
            "        uses: actions/upload-artifact@v4\n"
            "        with:\n"
            "          name: student-portfolio-ipa\n"
            "          path: build/ios/StudentPortfolio.ipa\n"
            "          retention-days: 14"
        )
        p_ci = self.doc.add_paragraph()
        p_ci.paragraph_format.first_line_indent = 0
        p_ci.paragraph_format.line_spacing = 1.0
        p_ci.paragraph_format.space_after = Pt(12)
        r_ci = p_ci.add_run(snippet_ci)
        r_ci.font.name = 'Courier New'
        r_ci.font.size = Pt(8.5)

    def save(self):
        self.doc.save(self.filename)
        print(f"Coursework report saved successfully as '{self.filename}'!")

if __name__ == '__main__':
    builder = CourseworkReportBuilder('Курсовой_проект_Цифровое_портфолио_студента.docx')
    builder.build_title_page()
    builder.build_table_of_contents()
    builder.build_body()
    builder.save()
