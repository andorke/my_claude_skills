# My Claude Code Config

Полная конфигурация [Claude Code](https://docs.anthropic.com/en/docs/claude-code) для быстрой настройки с нуля.

## Что внутри

| Файл / Директория | Описание |
|---|---|
| `CLAUDE.md` | Глобальные инструкции (правила, troubleshooting) |
| `settings.json` | Настройки (язык, statusline) |
| `statusline.sh` | Строка состояния с rate limits, директорией и git-веткой ([claude-statusline](https://github.com/kamranahmedse/claude-statusline)) |
| `agents/` | Кастомные агенты (code-optimizer, interviewer) |
| `commands/` | Slash-команды (симлинки на скиллы) |
| `skills/` | Скиллы (visual-explainer, HumanCompiler) |

## Установка

```bash
# 1. Клонировать в ~/.claude
git clone git@github.com:andorke/my_claude_skills.git ~/.claude

# 2. Установить statusline (требует jq, curl, git)
npx @kamranahmedse/claude-statusline

# 3. Готово — перезапустить Claude Code
```

> При установке на машину, где уже есть `~/.claude/`, сначала сделай бэкап `settings.local.json` (локальные разрешения — не трекаются в git).

## Skills

### visual-explainer
Генерирует self-contained HTML-страницы для визуального объяснения систем, изменений кода, планов и данных.

| Команда | Описание |
|---|---|
| `/generate-web-diagram` | Standalone HTML-диаграммы (архитектура, flowchart, ER, mind map) |
| `/diff-review` | Визуальное сравнение до/после с анализом изменений |
| `/plan-review` | Обзор плана реализации vs текущее состояние кода |
| `/project-recap` | Обзор состояния проекта, решений и когнитивного долга |
| `/fact-check` | Проверка фактов в документе на соответствие кодовой базе |

### HumanCompiler (`/compile-human`)
Глубокое поведенческое интервью, компилирующее человека в AI-агент плагин. 8 фаз: Identity, Communication, Decision-Making, Domain Expertise, Work Patterns, Edge Cases, Artifact Analysis, Calibration.

### `/taste`
Senior UI/UX Engineer. Проектирование интерфейсов с metric-based правилами, строгой компонентной архитектурой и CSS hardware acceleration.

## Agents

| Агент | Описание |
|---|---|
| `code-optimizer` | Оптимизация, рефакторинг и модернизация кода |
| `interviewer` | Проведение поведенческих интервью для HumanCompiler |

## Структура

```
~/.claude/
├── .gitignore
├── CLAUDE.md
├── README.md
├── settings.json
├── statusline.sh
├── agents/
│   ├── code-optimizer.md
│   └── interviewer.md
├── commands/
│   ├── taste.md
│   ├── diff-review.md      -> skills/visual-explainer/prompts/...
│   ├── fact-check.md        -> ...
│   ├── generate-web-diagram.md -> ...
│   ├── plan-review.md      -> ...
│   └── project-recap.md    -> ...
└── skills/
    ├── HumanCompiler/
    └── visual-explainer/
```
