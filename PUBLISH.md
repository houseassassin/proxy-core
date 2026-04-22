# 🚀 Инструкция по публикации Proxy-Core на GitHub

## Шаг 1: Инициализация Git репозитория

```bash
cd "/Users/houseassassin/My Projects/proxy-core"

# Инициализация репозитория
git init

# Добавление всех файлов
git add .

# Первый коммит
git commit -m "Initial commit: Proxy-Core v2.0.0

- Advanced VPN & Proxy Panel Auto-Installer
- Support for WireGuard, 3x-ui, Remnawave, Hysteria2
- Multi-language interface (EN/RU)
- SSL certificates management (3 methods)
- Backup & restore functionality
- Interactive management interface"
```

## Шаг 2: Создание репозитория на GitHub

1. Перейдите на https://github.com/new
2. Заполните форму:
   - **Repository name:** `proxy-core`
   - **Description:** `🚀 Advanced VPN & Proxy Panel Auto-Installer | WireGuard, 3x-ui, Remnawave, Hysteria2`
   - **Public** ✅
   - **Add README:** ❌ (уже есть)
   - **Add .gitignore:** ❌ (уже есть)
   - **Choose a license:** ❌ (уже есть MIT)

3. Нажмите **Create repository**

## Шаг 3: Подключение к GitHub

```bash
# Добавление remote
git remote add origin https://github.com/houseassassin/proxy-core.git

# Или через SSH (если настроен)
git remote add origin git@github.com:houseassassin/proxy-core.git

# Проверка
git remote -v
```

## Шаг 4: Отправка кода

```bash
# Отправка в main ветку
git branch -M main
git push -u origin main
```

## Шаг 5: Настройка репозитория на GitHub

### Topics (теги)

Добавьте следующие topics в настройках репозитория:

```
vpn, proxy, wireguard, xray, 3x-ui, remnawave, hysteria2, 
docker, bash, automation, installer, linux, ubuntu, debian, 
centos, ssl, letsencrypt, cloudflare, reverse-proxy
```

### About

```
🚀 Advanced VPN & Proxy Panel Auto-Installer with support for WireGuard, 3x-ui, Remnawave, and Hysteria2. Multi-language interface, SSL management, backup/restore functionality.
```

### Website

```
https://github.com/houseassassin/proxy-core
```

## Шаг 6: Создание Release

```bash
# Создание тега
git tag -a v2.0.0 -m "Release v2.0.0

Features:
- WireGuard support with client management
- 3x-ui panel integration
- Remnawave with Docker
- Hysteria2 proxy
- Multi-language interface (EN/RU)
- SSL certificates (Let's Encrypt, Cloudflare, Gcore)
- Backup & restore
- Interactive management interface
- BBR optimization
- Automatic swap creation"

# Отправка тега
git push origin v2.0.0
```

Затем на GitHub:
1. Перейдите в **Releases** → **Create a new release**
2. Выберите тег `v2.0.0`
3. Release title: `Proxy-Core v2.0.0 - Initial Release`
4. Описание: скопируйте из CHANGELOG в README.md
5. Нажмите **Publish release**

## Шаг 7: Настройка GitHub Actions (опционально)

Создайте `.github/workflows/shellcheck.yml`:

```yaml
name: ShellCheck

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: '.'
          severity: warning
```

## Шаг 8: Добавление бейджей в README

Бейджи уже добавлены в README.md:
- License: MIT
- Version: 2.0.0
- Bash: 5.0+
- Docker: 20.10+

## Шаг 9: Создание Wiki (опционально)

1. Перейдите в **Settings** → **Features** → включите **Wikis**
2. Создайте страницы:
   - Home (главная)
   - Installation Guide
   - Configuration
   - Troubleshooting
   - FAQ

## Шаг 10: Настройка Issues

1. Перейдите в **Settings** → **Features** → включите **Issues**
2. Создайте Issue Templates:
   - Bug Report
   - Feature Request
   - Question

## Шаг 11: Продвижение

### Поделитесь в:
- Reddit: r/selfhosted, r/VPN, r/linux
- Telegram: каналы про VPN и Linux
- Twitter/X: с хештегами #VPN #Linux #OpenSource
- Habr: статья о проекте

### Добавьте в списки:
- Awesome Lists на GitHub
- AlternativeTo
- Product Hunt

## Полезные команды Git

```bash
# Проверка статуса
git status

# Добавление изменений
git add .

# Коммит
git commit -m "feat: добавлена новая функция"

# Отправка
git push

# Создание новой ветки
git checkout -b feature/new-feature

# Слияние веток
git checkout main
git merge feature/new-feature

# Просмотр истории
git log --oneline --graph

# Откат изменений
git reset --hard HEAD~1
```

## Структура коммитов

Используйте Conventional Commits:

- `feat:` - новая функция
- `fix:` - исправление бага
- `docs:` - изменения в документации
- `style:` - форматирование кода
- `refactor:` - рефакторинг
- `test:` - добавление тестов
- `chore:` - обновление зависимостей

## Готово! 🎉

Ваш проект опубликован на GitHub!

**URL:** https://github.com/houseassassin/proxy-core

Не забудьте:
- ⭐ Попросить друзей поставить звезду
- 📢 Поделиться в соцсетях
- 📝 Отвечать на Issues
- 🔄 Регулярно обновлять проект
- 💬 Общаться с сообществом

Удачи! 🚀
