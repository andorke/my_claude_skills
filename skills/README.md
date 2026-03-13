# My Claude Code Skills

Коллекция кастомных скиллов и команд для [Claude Code](https://claude.ai/claude-code).

## Skills

### visual-explainer
Генерирует красивые self-contained HTML-страницы для визуального объяснения систем, изменений кода, планов и данных. Включает подкоманды:

| Команда | Описание |
|---|---|
| `/generate-web-diagram` | Создание standalone HTML-диаграмм (архитектура, flowchart, ER, mind map и др.) |
| `/diff-review` | Визуальное сравнение до/после с анализом изменений кода |
| `/plan-review` | Визуальный обзор плана реализации vs текущее состояние кода |
| `/project-recap` | Визуальный обзор текущего состояния проекта, решений и когнитивного долга |
| `/fact-check` | Проверка фактов в документе на соответствие реальной кодовой базе |

Автор: [nicobailon](https://github.com/nicobailon) | Лицензия: MIT

### HumanCompiler (`/compile-human`)
Глубокое поведенческое интервью с человеком и компиляция его в устанавливаемый AI-агент плагин для Claude Code. Проводит 8 фаз структурированного интервью:

1. **Identity** — роль, ответственности, цели
2. **Communication** — стиль письма, тон, паттерны
3. **Decision-Making** — фреймворки принятия решений, приоритеты
4. **Domain Expertise** — глубокие знания, технические навыки
5. **Work Patterns** — рабочие привычки, инструменты, коллаборация
6. **Edge Cases** — поведение в конфликтах, под давлением
7. **Artifact Analysis** — анализ реальных рабочих артефактов
8. **Calibration** — финальная калибровка и коррекция профиля

На выходе — Claude Code плагин с автономным и advisory режимами агента.

## Commands

### `/taste`
Senior UI/UX Engineer скилл. Проектирование цифровых интерфейсов с переопределением дефолтных LLM-предубеждений. Включает:
- Metric-based правила дизайна (DESIGN_VARIANCE, MOTION_INTENSITY, VISUAL_DENSITY)
- Строгую компонентную архитектуру (React/Next.js, RSC safety)
- CSS hardware acceleration и Tailwind CSS конвенции
- Анти-emoji политику и отзывчивый дизайн

## Структура репозитория

```
.
├── HumanCompiler/          # Скилл compile-human
│   ├── skills/             # Определение скилла и фазы интервью
│   ├── agents/             # Определение агента-интервьюера
│   ├── scripts/            # TypeScript скрипты и шаблоны
│   └── tests/              # Тесты
├── visual-explainer/       # Скилл визуальных объяснений
│   ├── prompts/            # Подкоманды (diff-review, fact-check и др.)
│   ├── templates/          # HTML шаблоны
│   └── references/         # CSS паттерны и библиотеки
├── commands/
│   └── taste.md            # Standalone команда taste
└── compile-human -> HumanCompiler/skills/compile-human  # Симлинк
```

## Установка

```bash
git clone git@github.com:andorke/my_claude_skills.git ~/.claude/skills
```

Команды из `commands/` нужно слинковать в `~/.claude/commands/`:

```bash
ln -s ~/.claude/skills/commands/taste.md ~/.claude/commands/taste.md
ln -s ~/.claude/skills/visual-explainer/prompts/diff-review.md ~/.claude/commands/diff-review.md
ln -s ~/.claude/skills/visual-explainer/prompts/fact-check.md ~/.claude/commands/fact-check.md
ln -s ~/.claude/skills/visual-explainer/prompts/generate-web-diagram.md ~/.claude/commands/generate-web-diagram.md
ln -s ~/.claude/skills/visual-explainer/prompts/plan-review.md ~/.claude/commands/plan-review.md
ln -s ~/.claude/skills/visual-explainer/prompts/project-recap.md ~/.claude/commands/project-recap.md
```
