# 🚀 Proxy-Core

<div align="center">

```
╔═══════════════════════════════════════════════════════════════════╗
║  ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗      ██████╗ ██████╗ ║
║  ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝     ██╔════╝██╔═══██╗║
║  ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝█████╗██║     ██║   ██║║
║  ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝ ╚════╝██║     ██║   ██║║
║  ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║        ╚██████╗╚██████╔╝║
║  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝         ╚═════╝ ╚═════╝ ║
║                                                                     ║
║            Advanced VPN & Proxy Panel Auto-Installer               ║
╚═══════════════════════════════════════════════════════════════════╝
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/houseassassin/proxy-core)
[![Bash](https://img.shields.io/badge/bash-5.0+-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/docker-20.10+-blue.svg)](https://www.docker.com/)

**Универсальный установщик и менеджер VPN/Proxy панелей с поддержкой множества протоколов**

[Установка](#-быстрая-установка) • [Возможности](#-возможности) • [Документация](#-документация) • [Поддержка](#-поддержка)

</div>

---

## 📋 О проекте

**Proxy-Core** — это мощный инструмент для автоматической установки и управления VPN/Proxy панелями. Объединяет лучшие практики из популярных проектов и предоставляет единый интерфейс для работы с различными протоколами.

### 🎯 Поддерживаемые панели

| Панель | Протоколы | Особенности |
|--------|-----------|-------------|
| **WireGuard** | WireGuard | Быстрый, современный, безопасный VPN |
| **3x-ui** | VLESS, VMess, Trojan, Shadowsocks, XTLS | Веб-панель Xray с множеством протоколов |
| **Remnawave** | Multi-protocol | Современная панель с Docker и reverse proxy |
| **Hysteria2** | Hysteria2 | Высокоскоростной прокси с маскировкой трафика |
| **MTProxy** | MTProxy | Официальный прокси для Telegram |

### 🔄 Reverse Proxy

| Сервер | Особенности | Рекомендуется для |
|--------|-------------|-------------------|
| **Nginx** | Высокая производительность, стабильность | Production, высокие нагрузки |
| **Caddy** | Автоматический HTTPS, простая конфигурация | Быстрый старт, малые проекты |

### 💻 Поддерживаемые ОС

<div align="center">

| OS | Версии | Статус |
|:--:|:------:|:------:|
| 🐧 **Ubuntu** | 18.04, 20.04, 22.04, 24.04 | ✅ Полная поддержка |
| 🐧 **Debian** | 10, 11, 12 | ✅ Полная поддержка |
| 🎩 **CentOS** | 7, 8, 9 | ✅ Полная поддержка |
| 🎩 **RHEL** | 7, 8, 9 | ✅ Полная поддержка |
| 🎩 **Fedora** | 35+ | ✅ Полная поддержка |

</div>

---

## ⚡ Быстрая установка

### Метод 1: Одна команда (рекомендуется)

```bash
bash <(curl -Ls https://raw.githubusercontent.com/houseassassin/proxy-core/main/install-advanced-v2.sh)
```

### Метод 2: Скачать и запустить

```bash
wget https://raw.githubusercontent.com/houseassassin/proxy-core/main/install-advanced-v2.sh
chmod +x install-advanced-v2.sh
sudo ./install-advanced-v2.sh
```

### Метод 3: Клонировать репозиторий

```bash
git clone https://github.com/houseassassin/proxy-core.git
cd proxy-core
chmod +x *.sh
sudo ./install-advanced-v2.sh
```

---

## 🌟 Возможности

<div align="center">

### 🔧 Автоматизация

</div>

- ✅ **Автоопределение ОС** — автоматическое определение дистрибутива и версии
- ✅ **Установка зависимостей** — Docker, Docker Compose, certbot и все необходимое
- ✅ **Генерация паролей** — автоматическая генерация безопасных паролей и ключей
- ✅ **Настройка firewall** — автоматическая конфигурация UFW/firewalld
- ✅ **BBR оптимизация** — включение BBR для улучшения производительности TCP
- ✅ **Swap управление** — автоматическое создание swap при нехватке RAM

<div align="center">

### 🔐 SSL/TLS сертификаты

</div>

- 🔒 **Let's Encrypt** — HTTP-01 challenge для обычных доменов
- 🔒 **Cloudflare DNS** — DNS-01 challenge с поддержкой wildcard сертификатов
- 🔒 **Gcore DNS** — альтернативный DNS провайдер
- 🔒 **Самоподписанные** — для тестирования и локальных сетей
- 🔒 **Автообновление** — автоматическое обновление сертификатов через cron

<div align="center">

### 🎮 Управление

</div>

- 📊 **Мониторинг** — статус сервисов, использование ресурсов, логи
- 🔄 **Обновления** — простое обновление всех компонентов
- 💾 **Резервное копирование** — ручное и автоматическое создание бэкапов
- 🔄 **Восстановление** — быстрое восстановление из резервных копий
- 👥 **Управление клиентами** — добавление, удаление, просмотр клиентов WireGuard
- 📱 **QR-коды** — генерация QR-кодов для мобильных устройств

<div align="center">

### 🎨 Дополнительные функции

</div>

- 🎭 **Selfsteal** — маскировка под обычный сайт
- 🔄 **Выбор Reverse Proxy** — Nginx или Caddy на выбор
- 📱 **MTProxy** — официальный прокси для Telegram с QR-кодами
- 🌍 **Многоязычность** — English + Русский
- 🎨 **Цветной вывод** — красивый и понятный интерфейс
- ⚡ **Spinner анимация** — визуализация длительных операций

---

## 📖 Документация

### 🚀 Быстрый старт

#### 1. Установка WireGuard

```bash
sudo ./install-advanced-v2.sh
# Выберите: 1 (Install Panel) → 1 (WireGuard)
```

#### 2. Установка 3x-ui

```bash
sudo ./install-advanced-v2.sh
# Выберите: 1 (Install Panel) → 2 (3x-ui)
```

#### 3. Установка Remnawave с выбором Reverse Proxy

```bash
sudo ./install-advanced-v2.sh
# Выберите: 1 (Install Panel) → 3 (Remnawave)
# Затем выберите: 1 (Nginx) или 2 (Caddy)
```

#### 4. Установка Hysteria2

```bash
sudo ./install-advanced-v2.sh
# Выберите: 1 (Install Panel) → 4 (Hysteria2)
```

#### 5. Установка MTProxy для Telegram

```bash
sudo ./install-advanced-v2.sh
# Выберите: 1 (Install Panel) → 5 (MTProxy)
```

**Результат:**
- Прокси для Telegram
- Ссылка для подключения: `tg://proxy?server=...`
- QR-код для быстрого подключения
- Конфигурация: `/opt/MTProxy/`

**Управление:**
```bash
sudo ./mtproxy-manager.sh
```

---

### 🎭 Selfsteal - Маскировка трафика

Selfsteal позволяет замаскировать ваш прокси-сервер под обычный веб-сайт.

#### Установка Selfsteal

```bash
sudo ./install-advanced-v2.sh
# Выберите: 6 (Selfsteal)
```

#### Типы Selfsteal:

**1. Случайный сайт**
- Автоматически выбирается популярный сайт
- Wikipedia, GitHub, StackOverflow, Reddit, Medium

**2. Пользовательский URL**
- Укажите любой URL
- Скрипт скачает и настроит страницу

**3. Локальный HTML файл**
- Используйте свой HTML файл
- Полный контроль над содержимым

#### Как это работает:

1. При обращении к серверу по HTTP показывается обычный сайт
2. Прокси работает на других портах/протоколах
3. Для внешнего наблюдателя сервер выглядит как обычный веб-сайт

---

### 🔄 Reverse Proxy - Nginx vs Caddy

#### Когда использовать Nginx:

✅ **Production окружение**
- Высокие нагрузки (1000+ одновременных подключений)
- Требуется максимальная производительность
- Нужна гибкая конфигурация
- Есть опыт работы с Nginx

#### Когда использовать Caddy:

✅ **Быстрый старт**
- Автоматический HTTPS из коробки
- Простая конфигурация
- Малые и средние проекты
- Нет опыта с веб-серверами

#### Сравнение:

| Функция | Nginx | Caddy |
|---------|-------|-------|
| Производительность | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Простота настройки | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Автоматический HTTPS | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Гибкость | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Документация | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

### 📱 MTProxy Management

#### Показать ссылку подключения

```bash
sudo ./mtproxy-manager.sh
# Выберите: 1 (Показать ссылку подключения)
```

Получите:
- Ссылку для Telegram: `tg://proxy?server=...`
- QR-код для быстрого подключения
- Параметры для ручной настройки

#### Сгенерировать новый секрет

```bash
sudo ./mtproxy-manager.sh
# Выберите: 2 (Сгенерировать новый секрет)
```

⚠️ **Внимание:** Все текущие подключения будут разорваны!

#### Изменить порт

```bash
sudo ./mtproxy-manager.sh
# Выберите: 3 (Изменить порт)
```

#### Обновить конфигурацию Telegram

```bash
sudo ./mtproxy-manager.sh
# Выберите: 4 (Обновить конфигурацию)
```

Обновляет:
- `proxy-secret` - секреты Telegram
- `proxy-multi.conf` - конфигурация серверов

#### Показать статистику

```bash
sudo ./mtproxy-manager.sh
# Выберите: 5 (Показать статистику)
```

Показывает:
- Статус сервиса
- Использование CPU и RAM
- Количество активных подключений

---

## 🔒 Безопасность

### ✅ Рекомендации после установки

1. **Смените пароли по умолчанию**
2. **Настройте firewall**
3. **Включите автообновления**
4. **Установите fail2ban**
5. **Настройте регулярные бэкапы**
6. **Используйте Selfsteal для маскировки**
7. **Мониторинг логов**

Подробнее в [SECURITY.md](docs/SECURITY.md).

---

## 📊 Структура проекта

```
proxy-core/
├── 📄 install-advanced-v2.sh   # Основной установщик v2.1
├── 📄 install-advanced.sh      # Установщик v2.0
├── 🎮 manage.sh               # Менеджер панелей
├── 🔧 wg-manager.sh           # WireGuard менеджер
├── 📱 mtproxy-manager.sh      # MTProxy менеджер
├── 🔄 update.sh               # Обновление
├── 🎨 banner.sh               # ASCII баннер
├── 📖 README.md               # Документация
├── 📖 CONTRIBUTING.md         # Руководство для участников
├── 📖 PUBLISH.md              # Инструкция по публикации
└── 📜 LICENSE                 # MIT License
```

---

## 🤝 Благодарности

Проект основан на лучших практиках из:

- [3dp-manager](https://github.com/denpiligrim/3dp-manager) - Docker management, Hysteria2
- [remnawave-reverse-proxy](https://github.com/eGamesAPI/remnawave-reverse-proxy) - SSL, multi-language
- [remnawave-scripts](https://github.com/DigneZzZ/remnawave-scripts) - Backup system
- [RemnaSetup](https://github.com/Capybara-z/RemnaSetup) - Beautiful UI, selfsteal

Огромное спасибо авторам! 🙏

---

## 📝 Лицензия

MIT License - свободное использование и модификация

---

## 💬 Поддержка

- **GitHub Issues:** [github.com/houseassassin/proxy-core/issues](https://github.com/houseassassin/proxy-core/issues)
- **Telegram:** [@houseassassin](https://t.me/houseassassin)

---

## 🔄 Changelog

### Version 2.1.0 (2026-04-22)

✨ **Новое:**
- 📱 Поддержка MTProxy для Telegram
- 🔄 Выбор Reverse Proxy (Nginx/Caddy)
- 🎭 Selfsteal - маскировка под обычный сайт
- 📱 QR-коды для MTProxy
- 🎮 Менеджер MTProxy

🔧 **Улучшения:**
- Интерактивный выбор компонентов
- Улучшенная система меню
- Больше опций конфигурации

### Version 2.0.0 (2026-04-22)

✨ **Новое:**
- Поддержка Hysteria2
- Улучшенное управление SSL (3 метода)
- Автоматическая настройка BBR
- Многоязычный интерфейс (EN/RU)
- Spinner анимация
- Система логирования

---

<div align="center">

### 💖 Сделано с любовью by [houseassassin](https://github.com/houseassassin)

**Если проект помог вам, поставьте ⭐ звезду!**

[⬆ Наверх](#-proxy-core)

</div>
