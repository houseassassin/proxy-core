<div align="center">

# 🚀 Proxy-Core

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

[🚀 Установка](#-быстрая-установка) • [✨ Возможности](#-возможности) • [📖 Документация](#-документация) • [💬 Поддержка](#-поддержка)

</div>

---

## 📋 О проекте

**Proxy-Core** — мощный инструмент для автоматической установки и управления VPN/Proxy панелями. Объединяет лучшие практики из популярных проектов и предоставляет единый интерфейс для работы с различными протоколами.

<div align="center">

### 🎯 Поддерживаемые панели

| Панель | Протоколы | Особенности |
|:------:|:---------:|:-----------:|
| **WireGuard** | WireGuard | 🚀 Быстрый, современный, безопасный VPN |
| **3x-ui** | VLESS, VMess, Trojan, Shadowsocks | 🌐 Веб-панель Xray с множеством протоколов |
| **Remnawave** | Multi-protocol | 🐳 Современная панель с Docker |
| **Hysteria2** | Hysteria2 | ⚡ Высокоскоростной прокси с маскировкой |
| **MTProxy** | MTProxy | 📱 Официальный прокси для Telegram |

</div>

---

## ⚡ Быстрая установка

### Одна команда (рекомендуется)

```bash
bash <(curl -Ls https://raw.githubusercontent.com/houseassassin/proxy-core/main/install.sh)
```

### Альтернативный метод

```bash
git clone https://github.com/houseassassin/proxy-core.git
cd proxy-core
chmod +x install.sh
sudo ./install.sh
```

---

## ✨ Возможности

<table>
<tr>
<td width="50%">

### 🔧 Автоматизация
- ✅ Автоопределение ОС и версии
- ✅ Установка Docker и зависимостей
- ✅ Генерация безопасных паролей
- ✅ Настройка firewall (UFW/firewalld)
- ✅ BBR оптимизация TCP
- ✅ Автоматическое создание swap

### 🔐 SSL/TLS сертификаты
- 🔒 Let's Encrypt (HTTP-01)
- 🔒 Cloudflare DNS (DNS-01)
- 🔒 Gcore DNS
- 🔒 Самоподписанные сертификаты
- 🔒 Автообновление через cron

</td>
<td width="50%">

### 🎮 Управление
- 📊 Мониторинг сервисов и ресурсов
- 🔄 Простое обновление компонентов
- 💾 Резервное копирование
- 🔄 Восстановление из бэкапов
- 👥 Управление клиентами WireGuard
- 📱 Генерация QR-кодов

### 🎨 Дополнительно
- 🎭 Selfsteal маскировка трафика
- 🔄 Выбор Reverse Proxy (Nginx/Caddy)
- 📱 MTProxy с QR-кодами
- 🌍 Многоязычность (EN/RU)
- 🎨 Красивый интерфейс

</td>
</tr>
</table>

---

## 💻 Поддерживаемые ОС

<div align="center">

| Операционная система | Версии | Статус |
|:-------------------:|:------:|:------:|
| 🐧 **Ubuntu** | 18.04, 20.04, 22.04, 24.04 | ✅ Полная поддержка |
| 🐧 **Debian** | 10, 11, 12 | ✅ Полная поддержка |
| 🎩 **CentOS** | 7, 8, 9 | ✅ Полная поддержка |
| 🎩 **RHEL** | 7, 8, 9 | ✅ Полная поддержка |
| 🎩 **Fedora** | 35+ | ✅ Полная поддержка |

</div>

---

## 📖 Документация

### 🚀 Быстрый старт

<details>
<summary><b>1️⃣ Установка WireGuard</b></summary>

```bash
sudo ./install.sh
# Выберите: 1 (Install Panel) → 1 (WireGuard)
```

**Результат:**
- Установленный WireGuard сервер
- Первый клиент с конфигурацией
- QR-код для мобильных устройств
- Автоматическая настройка firewall

**Управление клиентами:**
```bash
sudo ./wg-manager.sh
```

</details>

<details>
<summary><b>2️⃣ Установка 3x-ui</b></summary>

```bash
sudo ./install.sh
# Выберите: 1 (Install Panel) → 2 (3x-ui)
```

**Результат:**
- Веб-панель 3x-ui
- Поддержка VLESS, VMess, Trojan, Shadowsocks
- SSL сертификаты
- Доступ через браузер

</details>

<details>
<summary><b>3️⃣ Установка Remnawave</b></summary>

```bash
sudo ./install.sh
# Выберите: 1 (Install Panel) → 3 (Remnawave)
# Затем выберите Reverse Proxy: 1 (Nginx) или 2 (Caddy)
```

**Результат:**
- Remnawave панель с Docker
- Выбранный reverse proxy (Nginx/Caddy)
- SSL сертификаты
- Готовая к использованию панель

</details>

<details>
<summary><b>4️⃣ Установка Hysteria2</b></summary>

```bash
sudo ./install.sh
# Выберите: 1 (Install Panel) → 4 (Hysteria2)
```

**Результат:**
- Высокоскоростной Hysteria2 прокси
- Маскировка трафика
- Оптимизированная конфигурация

</details>

<details>
<summary><b>5️⃣ Установка MTProxy</b></summary>

```bash
sudo ./install.sh
# Выберите: 1 (Install Panel) → 5 (MTProxy)
```

**Результат:**
- Прокси для Telegram
- Ссылка для подключения: `tg://proxy?server=...`
- QR-код для быстрого подключения
- Менеджер для управления

**Управление MTProxy:**
```bash
sudo ./mtproxy-manager.sh
```

**Функции менеджера:**
- 📱 Показать ссылку подключения и QR-код
- 🔑 Сгенерировать новый секрет
- 🔧 Изменить порт
- 🔄 Обновить конфигурацию Telegram
- 📊 Показать статистику
- 📋 Просмотр логов

</details>

---

### 🎭 Selfsteal - Маскировка трафика

Selfsteal позволяет замаскировать ваш прокси-сервер под обычный веб-сайт.

```bash
sudo ./install.sh
# Выберите: 6 (Selfsteal)
```

**Типы маскировки:**

| Тип | Описание | Использование |
|:---:|:--------:|:-------------:|
| 🎲 **Случайный сайт** | Автоматический выбор популярного сайта | Wikipedia, GitHub, StackOverflow |
| 🌐 **Пользовательский URL** | Укажите любой URL | Любой сайт на ваш выбор |
| 📄 **Локальный HTML** | Используйте свой HTML файл | Полный контроль над содержимым |

**Как это работает:**
1. При обращении к серверу по HTTP показывается обычный сайт
2. Прокси работает на других портах/протоколах
3. Для внешнего наблюдателя сервер выглядит как обычный веб-сайт

---

### 🔄 Reverse Proxy - Nginx vs Caddy

<div align="center">

| Функция | Nginx | Caddy |
|:-------:|:-----:|:-----:|
| **Производительность** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Простота настройки** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Автоматический HTTPS** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Гибкость** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Документация** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

</div>

**Когда использовать Nginx:**
- ✅ Production окружение с высокими нагрузками
- ✅ Требуется максимальная производительность
- ✅ Нужна гибкая конфигурация
- ✅ Есть опыт работы с Nginx

**Когда использовать Caddy:**
- ✅ Быстрый старт без опыта
- ✅ Автоматический HTTPS из коробки
- ✅ Простая конфигурация
- ✅ Малые и средние проекты

---

## 🔒 Безопасность

### ✅ Рекомендации после установки

<table>
<tr>
<td width="50%">

**Обязательно:**
1. 🔑 Смените пароли по умолчанию
2. 🛡️ Настройте firewall
3. 🔄 Включите автообновления
4. 🚫 Установите fail2ban
5. 💾 Настройте регулярные бэкапы

</td>
<td width="50%">

**Рекомендуется:**
6. 🎭 Используйте Selfsteal для маскировки
7. 📊 Настройте мониторинг логов
8. 🔐 Используйте сильные пароли
9. 🔄 Регулярно обновляйте систему
10. 📱 Включите 2FA где возможно

</td>
</tr>
</table>

---

## 🎮 Управление

### Основные команды

```bash
# Главный установщик
sudo ./install.sh

# Управление WireGuard
sudo ./wg-manager.sh

# Управление MTProxy
sudo ./mtproxy-manager.sh

# Общее управление панелями
sudo ./manage.sh

# Обновление компонентов
sudo ./update.sh
```

---

## 📊 Структура проекта

```
proxy-core/
├── 📄 install.sh              # Главный установщик v2.1.0
├── 🎮 manage.sh               # Менеджер панелей
├── 🔧 wg-manager.sh           # WireGuard менеджер
├── 📱 mtproxy-manager.sh      # MTProxy менеджер
├── 🔄 update.sh               # Обновление компонентов
├── 🎨 banner.sh               # ASCII баннер
├── 📖 README.md               # Документация
├── 📖 CONTRIBUTING.md         # Руководство для участников
├── 📖 PUBLISH.md              # Инструкция по публикации
└── 📜 LICENSE                 # MIT License
```

---

## 🤝 Благодарности

Проект основан на лучших практиках из:

<div align="center">

| Проект | Вклад |
|:------:|:-----:|
| [3dp-manager](https://github.com/denpiligrim/3dp-manager) | Docker management, Hysteria2 |
| [remnawave-reverse-proxy](https://github.com/eGamesAPI/remnawave-reverse-proxy) | SSL, multi-language |
| [remnawave-scripts](https://github.com/DigneZzZ/remnawave-scripts) | Backup system |
| [RemnaSetup](https://github.com/Capybara-z/RemnaSetup) | Beautiful UI, selfsteal |

</div>

Огромное спасибо авторам! 🙏

---

## 🔄 Changelog

### Version 2.1.0 (2026-04-22)

<details>
<summary><b>✨ Новое</b></summary>

- 📱 Поддержка MTProxy для Telegram
- 🔄 Выбор Reverse Proxy (Nginx/Caddy)
- 🎭 Selfsteal - маскировка под обычный сайт
- 📱 QR-коды для MTProxy
- 🎮 Менеджер MTProxy

</details>

<details>
<summary><b>🔧 Улучшения</b></summary>

- Интерактивный выбор компонентов
- Улучшенная система меню
- Больше опций конфигурации
- Исправлена ошибка создания директории логов

</details>

---

## 💬 Поддержка

<div align="center">

**Нужна помощь?**

[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-red?style=for-the-badge&logo=github)](https://github.com/houseassassin/proxy-core/issues)
[![Telegram](https://img.shields.io/badge/Telegram-@houseassassin-blue?style=for-the-badge&logo=telegram)](https://t.me/houseassassin)

</div>

---

## 📝 Лицензия

<div align="center">

**MIT License** - свободное использование и модификация

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

---

<div align="center">

### 💖 Сделано с любовью by [houseassassin](https://github.com/houseassassin)

**Если проект помог вам, поставьте ⭐ звезду!**

[![Star History](https://img.shields.io/github/stars/houseassassin/proxy-core?style=social)](https://github.com/houseassassin/proxy-core/stargazers)

[⬆ Наверх](#-proxy-core)

</div>
