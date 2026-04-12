---
description: Install base skill set into the current project from ~/.claude/project-kit.json
---

Install the standard skill set into the current project's `.claude/skills/` directory, verify the Superpowers plugin is available, write OpenSpec + Superpowers composition rules to `AGENTS.md`, scaffold the core project docs (`AGENTS.md`, `DEVELOPMENT.md`, `CONTEXT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`), and copy filled-in example docs from `~/.claude/templates/project-docs/` into `<project>/example_docs/`.

Read the manifest at `~/.claude/project-kit.json` to get the list of skills to install.

## Steps

### 1. Check prerequisites
- Verify the current directory has a `.claude/` folder (create if missing)
- Verify `.claude/skills/` exists (create if missing)
- Read `~/.claude/project-kit.json` for the skill list

### 2. Verify Superpowers plugin is installed globally
Superpowers is distributed as a Claude Code plugin and lives at user scope, not per-project. Check that it is present before continuing:

- Read `~/.claude/plugins/installed_plugins.json`
- Look for a key matching `superpowers@*` (e.g. `superpowers@claude-plugins-official`)
- If found — report version and continue
- If missing — stop and tell the user to run `/plugin install obra/superpowers` (or the marketplace equivalent) before re-running `/setup-project`

Do **not** vendor Superpowers files into the project. It is global by design.

### 3. Install tessl-managed skills
For each entry in `"tessl"` array:
- Run `tessl install <name>` via the tessl MCP tool
- If already installed, check if an update is available via `tessl outdated` and offer to update
- Report success/failure for each

### 4. Copy local skills
For each entry in `"copy"` array:
- Check if `~/.claude/skills/<name>/` exists as source
- Check if `.claude/skills/<name>/` already exists in the project
- If it exists, ask the user whether to overwrite
- If not, copy the entire skill directory: `cp -r ~/.claude/skills/<name>/ .claude/skills/<name>/`
- Report success/failure for each

### 5. Write OpenSpec + Superpowers composition rules to project AGENTS.md

The goal: every project should have an explicit rule block that tells the agent how OpenSpec and Superpowers are expected to cooperate, and how the core project docs are maintained. Without this block, Superpowers TDD / code-review / verification skills do **not** auto-activate inside `/opsx:apply`, which is the single most common failure mode of the pair.

**Target file:** `<project>/AGENTS.md` (create if missing).

**Why AGENTS.md and not CLAUDE.md:** `AGENTS.md` is the cross-agent convention used by OpenSpec and Superpowers. Claude Code still auto-loads `CLAUDE.md`, so we also write a thin proxy `CLAUDE.md` that points to `AGENTS.md` (see Step 6).

**Language:** the managed block narrative is in Russian because the user prefers it. Skill identifiers (`brainstorming`, `writing-plans`, `test-driven-development`, etc.) stay in English as they are code references.

**Behavior for AGENTS.md:**
- If `AGENTS.md` does not exist — create it using the full template below (header + managed block).
- If `AGENTS.md` exists and contains the managed marker `<!-- BEGIN openspec-superpowers-composition -->` — replace the block between `BEGIN` and `END` markers in place. Preserve all other content.
- If `AGENTS.md` exists but has no marker — append the managed block at the end with a blank line separator. Do not touch existing content.

**Managed block to write (verbatim, including markers):**

```markdown
<!-- BEGIN openspec-superpowers-composition -->
## Рабочий процесс проекта: OpenSpec + Superpowers

Проект использует **OpenSpec** для персистентного планирования и **Superpowers** для методологии исполнения. Это независимые системы — правила ниже явно их композируют.

### Порядок чтения для новых агентов
Прежде чем что-либо делать, прочитай эти файлы в следующем порядке:
1. `AGENTS.md` — этот файл. Точка входа, правила, глоссарий.
2. `DEVELOPMENT.md` — стек, структура репозитория, паттерны кода, локальный запуск.
3. `CONTEXT.md` — текущий статус, последние решения, журнал «что сделано».
4. `ROADMAP.md` — фазы и чекпойнты.
5. `REQUIREMENTS.md` — функциональные и нефункциональные требования.
6. `ARCHITECTURE.md` — C4-диаграммы, API-контракты, ключевые архитектурные решения.

### Роли
- **OpenSpec** владеет персистентным планированием отдельных изменений: `proposal.md`, `design.md`, `tasks.md`, `archive/`. Источник истины для того, ЧТО мы строим и ЗАЧЕМ, на уровне одной фичи.
- **Superpowers** владеет методологией исполнения: TDD, systematic debugging, code review, git worktrees, subagent dispatch. Источник истины для того, КАК мы строим.
- **Документы проекта** (`AGENTS.md`, `CONTEXT.md`, `DEVELOPMENT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`) владеют глобальным, долгоживущим контекстом проекта. OpenSpec работает в scope одного изменения, эти файлы — в scope всего проекта.

### Поток на одну фичу
1. `brainstorming` (Superpowers) — уточнить идею в чате. Без персистентного файла.
2. `/opsx:propose <name>` — OpenSpec генерирует `proposal.md`, `design.md`, `tasks.md`. Просмотри и отредактируй руками перед следующим шагом.
3. `/opsx:apply <name>` — реализация задач. Во время apply правила ниже — обязательные.
4. Финальный code review через Superpowers `requesting-code-review` на всё изменение.
5. `/opsx:archive <name>` — только после того как все тесты зелёные и code review закрыт.
6. После archive — обнови `CONTEXT.md` (журнал «что сделано») и, если change закрыл запланированный пункт, переключи соответствующий чекбокс в `ROADMAP.md`.

### Обязательные правила во время /opsx:apply
1. Каждая задача в `tasks.md` реализуется через **test-driven-development**: RED (failing test) → GREEN (минимальный код) → REFACTOR. Не пишем код без сначала failing теста.
2. Перед тем как переключить `- [ ]` → `- [x]` на задаче, запусти **verification-before-completion** как внутреннюю само-проверку.
3. Используй **systematic-debugging**, когда тест падает по неочевидной причине. Не гадай.
4. Для независимых подзадач, которые можно запускать параллельно, используй **dispatching-parallel-agents**.
5. Используй **using-git-worktrees** для изолированных веток, когда изменение трогает много файлов или есть риск конфликта редактирований.
6. Перед `/opsx:archive` — обязательный **requesting-code-review** на всё изменение.

### Заполнение документов проекта через Superpowers
Шесть файлов в корне проекта (`AGENTS.md`, `DEVELOPMENT.md`, `CONTEXT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`) создаются как скелеты с секциями и `TODO`-плейсхолдерами. Заполняй их итеративно — не пытайся написать 1000 строк в первый день.

- В папке `example_docs/` лежат **заполненные примеры** тех же файлов для вымышленного проекта NoteHub. Это референс структуры и детализации, **не шаблон для копирования содержимого**. Перед заполнением соответствующего скелета — прочитай его пример из `example_docs/`.
- Используй Superpowers **`brainstorming`**, чтобы задавать пользователю уточняющие вопросы и извлекать информацию для любой `TODO`-секции. По одному сфокусированному вопросу за раз. Не выдумывай контент.
- Используй Superpowers **`writing-plans`** только для превращения решённого scope в фазы `ROADMAP.md`. Фазы должны быть крупными — детальные подзадачи живут в OpenSpec changes, не в `ROADMAP.md`.
- Обновляй `CONTEXT.md` после каждого значимого решения или завершённого change. Это журнал, а не спека — добавляй записи сверху, не переписывай историю.
- Обновляй `ARCHITECTURE.md` только когда принято решение. Держи его фактическим, не aspirational. C4-диаграммы опциональны на старте; начни с прозы об компонентах и границах.
- `DEVELOPMENT.md` фиксируется один раз на выбор стека. Обновляй только при смене стека, структуры или паттернов кода — не per-feature.
- `REQUIREMENTS.md` — зафиксированные функциональные (FR) и нефункциональные (NFR) требования. Обновляй при добавлении / удалении / изменении требований, не при реализации.

### Управление потоком изменений
- **Не** запускай автоматически следующий этап (propose/apply/archive) после завершения текущего. Пользователь сам управляет потоком через команды `/opsx:propose`, `/opsx:apply`, `/opsx:archive`. Завершил текущий этап — доложи результат и жди команды.
- **Не** запускай Superpowers скиллы (brainstorming, writing-plans и др.) для автоматического перехода к следующему change.
- Subagent'ы могут запускаться только по явному запросу пользователя.

### Границы (что НЕ делать)
- **Не** используй Superpowers `writing-plans` для планирования на уровне фичи, когда активен OpenSpec change. `tasks.md` — авторитетный план фичи. `writing-plans` — только для высокоуровневых фаз `ROADMAP.md`.
- **Не** запускай Superpowers `brainstorming` во время `/opsx:apply`. Brainstorming — это фаза до `/opsx:propose`.
- **Не** создавай параллельные планирующие доки внутри `openspec/changes/<name>/`. OpenSpec-артефакты — единственный источник плана.
- **Не** запускай `/opsx:archive`, если хотя бы одна задача в `tasks.md` не отмечена, тесты падают или code review не закрыт.
- **Не** используй OpenSpec для задач короче ~30 минут. Для тривиальных правок — Superpowers напрямую, без change.
- **Не** дублируй контент между `AGENTS.md` / `CONTEXT.md` / `ARCHITECTURE.md` / `REQUIREMENTS.md`. Каждый файл владеет своим scope; вместо копирования делай перекрёстные ссылки.
- **Не** копируй содержимое из `example_docs/` в скелеты. Примеры — про структуру, не про контент.

### Заметка про version drift
Superpowers ≥ v5 начал добавлять собственные скиллы генерации spec/plan документов. Они пересекаются с OpenSpec. Если после обновления Superpowers ты видишь дублирующиеся планирующие артефакты — перечитай этот блок и отключи конфликтующий Superpowers-скилл для этого проекта.
<!-- END openspec-superpowers-composition -->
```

**AGENTS.md header (только при создании нового файла — не перезаписывать существующий header):**

```markdown
# {{PROJECT_NAME}}

> Точка входа для coding-агентов. Прочитай этот файл первым.

## Что это за проект
TODO — один абзац: что делает проект, для кого он, на какой стадии находится.

## Порядок чтения
1. `AGENTS.md` (этот файл)
2. `DEVELOPMENT.md`
3. `CONTEXT.md`
4. `ROADMAP.md`
5. `REQUIREMENTS.md`
6. `ARCHITECTURE.md`

## Глоссарий
TODO — термины предметной области, которые незнакомы новому агенту.

```

Replace `{{PROJECT_NAME}}` with the current directory's basename.

### 6. Scaffold core project docs

Create the remaining files **only if they do not already exist**. Never overwrite existing content — if a file is already present, skip it and report "skipped (exists)".

Each file is a short scaffold with clearly-labelled `TODO` sections in **Russian**. It is **not** supposed to be comprehensive at creation time. Superpowers `brainstorming` fills these in iteratively, using the filled-in examples from `example_docs/` (copied in Step 7) as structural references.

**Also write a thin proxy `CLAUDE.md`** at the project root so Claude Code's auto-load still finds the rules. If `CLAUDE.md` already exists, leave it untouched and only report.

#### CLAUDE.md (proxy, only if missing)

```markdown
# Правила проекта лежат в AGENTS.md

См. `./AGENTS.md` — полная точка входа для агента, порядок чтения и правила композиции OpenSpec + Superpowers.
```

#### DEVELOPMENT.md (only if missing)

```markdown
# Правила разработки

> Прочитай перед началом работы.

> **Пример заполнения:** `example_docs/DEVELOPMENT.md`

## Технологический стек
TODO — версии языков, фреймворки, базы данных, ключевые библиотеки.

## Структура репозитория
TODO — дерево директорий с однострочными описаниями каждой папки верхнего уровня.

## Локальный запуск
TODO — команды установки, сборки, тестов, запуска. Порты, переменные окружения, docker-compose если есть.

## Паттерны кода
TODO — архитектурный стиль (например Clean Architecture, hexagonal, MVC), правила зависимостей, naming conventions, обработка ошибок.

## Стратегия тестирования
TODO — unit / integration / e2e split, инструменты, целевое покрытие, где живут тесты.

## Стиль и тулинг
TODO — линтер, форматтер, pre-commit hooks, convention коммитов.
```

#### CONTEXT.md (only if missing)

```markdown
# Контекст проекта

> **Пример заполнения:** `example_docs/CONTEXT.md`

## Текущий статус
- **Этап:** TODO
- **Последнее обновление:** {{TODAY}}

## Что сделано
| Дата | Что сделано |
|------|-------------|
| {{TODAY}} | Проект scaffolded через /setup-project |

> Новые записи добавляются **сверху**. Не переписывай историю — это журнал, а не спека.

## Текущая задача
TODO — одно предложение.

## Ключевые архитектурные решения
| Решение | Выбор | Обоснование |
|---------|-------|-------------|
| TODO    | TODO  | TODO        |

## Риски
| Риск | Вероятность | Влияние | Митигация |
|------|-------------|---------|-----------|
| TODO | TODO        | TODO    | TODO      |

## Следующие шаги
- [ ] TODO
```

Replace `{{TODAY}}` with the current date in `YYYY-MM-DD` format.

#### ROADMAP.md (only if missing)

```markdown
# План разработки

> Высокоуровневые фазы. Детальные подзадачи живут в OpenSpec changes, не здесь.

> **Пример заполнения:** `example_docs/ROADMAP.md`

## Обзор фаз
| Фаза | Название | Статус |
|------|----------|--------|
| 0    | Настройка проекта | ⏳ В процессе |
| 1    | TODO     | ⏸️ Ожидает |
| 2    | TODO     | ⏸️ Ожидает |

## Фаза 0: Настройка проекта
- [x] Репозиторий инициализирован
- [x] Документы scaffolded
- [ ] Стек выбран, `DEVELOPMENT.md` заполнен
- [ ] Первая фича описана через `/opsx:propose`

## Фаза 1: TODO
- [ ] TODO
```

#### REQUIREMENTS.md (only if missing)

```markdown
# Требования к продукту

> Функциональные (FR) и нефункциональные (NFR) требования.

> **Пример заполнения:** `example_docs/REQUIREMENTS.md`

## Описание продукта
TODO — один абзац: что это за продукт, какую задачу решает, для кого.

## Бизнес-контекст
### Целевая аудитория
TODO

### Критерий успеха MVP
TODO — список измеримых критериев.

## Функциональные требования

### FR-1: TODO
- **FR-1.1** TODO

## Нефункциональные требования

### NFR-1: Производительность
| Метрика | Требование |
|---------|-----------|
| TODO    | TODO       |

### NFR-2: Надёжность
TODO

### NFR-3: Безопасность
TODO

### NFR-4: Совместимость
TODO

## Ограничения MVP (out of scope)
1. TODO

## Глоссарий
| Термин | Определение |
|--------|-------------|
| TODO   | TODO        |
```

#### ARCHITECTURE.md (only if missing)

```markdown
# Архитектура

> Глобальные, долгоживущие архитектурные решения. Per-change design живёт в `openspec/changes/<name>/design.md`.

> **Пример заполнения:** `example_docs/ARCHITECTURE.md` (включая C4-диаграммы в Mermaid)

## 1. Обзор системы
TODO — один абзац, описывающий систему, её основные компоненты и их границы.

## 2. C4 Level 1 — System Context
TODO — диаграмма контекста системы (Mermaid). Опционально на старте.

## 3. Компоненты
TODO — список каждого компонента с однострочным описанием его ответственности.

## 4. Ключевые интерфейсы
TODO — публичные API, message contracts, точки интеграции с внешними системами.

## 5. Модель данных
TODO — основные сущности и их связи. Вынеси в отдельный файл, если она разрастается.

## 6. Ключевые архитектурные решения
| Решение | Выбор | Обоснование |
|---------|-------|-------------|
| TODO    | TODO  | TODO        |

## 7. Безопасность
TODO — auth, шифрование, валидация, защита от OWASP top-10.

## 8. Развёртывание
TODO — где живёт прод, какие сервисы, CI/CD, мониторинг.
```

### 7. Copy filled-in examples to `example_docs/`

The user's primary reference for filling in the scaffolds is `<project>/example_docs/`. This folder contains filled-in versions of all five docs for a hypothetical project called **NoteHub** (a web app for notes with tags, full-text search, and sync). The agent reads these as a structural reference when filling in the real scaffolds — it does **not** copy their content into the real files.

**Source:** `~/.claude/templates/project-docs/` — contains `README.md` + 5 filled example docs in Russian.

**Destination:** `<project>/example_docs/`

**Behavior:**
- If `<project>/example_docs/` does not exist — create it and copy all files from the source.
- If `<project>/example_docs/` already exists — **skip** with status `skipped (exists)`. Do not overwrite. The user may have customized it.

**Command (when source is present):**

```bash
mkdir -p example_docs
cp ~/.claude/templates/project-docs/*.md example_docs/
```

Files copied:
- `example_docs/README.md` — explanation of how to use these examples
- `example_docs/CONTEXT.md`
- `example_docs/DEVELOPMENT.md`
- `example_docs/ROADMAP.md`
- `example_docs/REQUIREMENTS.md`
- `example_docs/ARCHITECTURE.md`

### 8. Add `example_docs/` to `.gitignore`

The `example_docs/` folder is identical for every project (it's copied from the same templates), so committing it adds noise to the repository. Add it to `.gitignore` by default so each project can commit it explicitly if the team wants to keep it under version control.

**Behavior:**
- If `.gitignore` does not exist — create it with the block below.
- If `.gitignore` exists and already contains `example_docs/` — skip (reported as "already ignored").
- If `.gitignore` exists and does not contain `example_docs/` — append the block below with a blank line separator.

**Block to add:**

```
# Reference docs (copied from ~/.claude/templates/project-docs/)
# Same for every project — not worth committing. Remove this entry if your team wants to version it.
example_docs/
```

### 9. Summary

Print a table showing:

| Item | Type | Status |
|------|------|--------|
| superpowers plugin | plugin-check | installed / missing |
| `<skill-name>` | tessl / copy | installed / updated / skipped / failed |
| AGENTS.md composition block | rules-block | created / updated / appended |
| CLAUDE.md proxy | proxy-file | created / skipped (exists) |
| DEVELOPMENT.md | scaffold | created / skipped (exists) |
| CONTEXT.md | scaffold | created / skipped (exists) |
| ROADMAP.md | scaffold | created / skipped (exists) |
| REQUIREMENTS.md | scaffold | created / skipped (exists) |
| ARCHITECTURE.md | scaffold | created / skipped (exists) |
| example_docs/ | reference-copy | copied / skipped (exists) |
| .gitignore entry | gitignore | added / already ignored |

Close with a one-line next step (in Russian):

> Запусти `/opsx:explore` или начни brainstorming-сессию, чтобы заполнить TODO-секции. Референсы в `example_docs/`.

## Flags

- `--dry-run` — show what would be installed or written, without making changes
- `--tessl-only` — only install tessl-managed skills (skip copy + rules block + scaffolds + examples)
- `--copy-only` — only copy local skills (skip tessl + rules block + scaffolds + examples)
- `--rules-only` — only write the OpenSpec + Superpowers composition rules block to `AGENTS.md`, skip skill installation and doc scaffolds
- `--docs-only` — only scaffold the project docs (`AGENTS.md`, `CLAUDE.md` proxy, `DEVELOPMENT.md`, `CONTEXT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, `ARCHITECTURE.md`), copy `example_docs/`, update `.gitignore`, skip everything else
