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
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/houseassassin/proxy-core)
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
bash <(curl -Ls https://raw.githubusercontent.com/houseassassin/proxy-core/main/install-advanced.sh)
```

### Метод 2: Скачать и запустить

```bash
wget https://raw.githubusercontent.com/houseassassin/proxy-core/main/install-advanced.sh
chmod +x install-advanced.sh
sudo ./install-advanced.sh
```

### Метод 3: Клонировать репозиторий

```bash
git clone https://github.com/houseassassin/proxy-core.git
cd proxy-core
chmod +x *.sh
sudo ./install-advanced.sh
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

### 🌍 Интерфейс

</div>

- 🇬🇧 **English** — полная поддержка английского языка
- 🇷🇺 **Русский** — полная поддержка русского языка
- 🎨 **Цветной вывод** — красивый и понятный интерфейс
- ⚡ **Spinner анимация** — визуализация длительных операций

---

## 📖 Документация

### 🚀 Быстрый старт

#### 1. Установка WireGuard

```bash
sudo ./install-advanced.sh
# Выберите: 1 (Install Panel) → 1 (WireGuard)
```

**Результат:**
- Сервер WireGuard на порту 51820 (или указанном)
- Конфигурация: `/etc/wireguard/wg0.conf`
- Автозапуск при загрузке системы

#### 2. Установка 3x-ui

```bash
sudo ./install-advanced.sh
# Выберите: 1 (Install Panel) → 2 (3x-ui)
```

**Результат:**
- Веб-панель: `http://YOUR_IP:2053`
- Логин: `admin` | Пароль: `admin` ⚠️ **СМЕНИТЕ!**

#### 3. Установка Remnawave

```bash
sudo ./install-advanced.sh
# Выберите: 1 (Install Panel) → 3 (Remnawave)
```

**Потребуется:**
- Домен (например: `vpn.example.com`)
- Email для SSL сертификата

**Результат:**
- Панель: `https://YOUR_DOMAIN`
- Логин и пароль будут показаны после установки

#### 4. Установка Hysteria2

```bash
sudo ./install-advanced.sh
# Выберите: 1 (Install Panel) → 4 (Hysteria2)
```

**Потребуется:**
- Домен для ACME сертификата
- Email для Let's Encrypt

**Результат:**
- Конфигурация: `/etc/hysteria/config.yaml`
- Пароль и порт будут показаны

---

### 🎮 Управление панелями

#### Запуск менеджера

```bash
sudo ./manage.sh
```

#### Меню менеджера

```
╔════════════════════════════════════════╗
║   VPN Panel Management                ║
╚════════════════════════════════════════╝

1. Управление WireGuard
2. Управление 3x-ui
3. Управление Remnawave
4. Управление Hysteria2
5. Системная информация
0. Выход
```

---

## 🔒 Безопасность

### ✅ Рекомендации после установки

1. **Смените пароли по умолчанию**
2. **Настройте firewall**
3. **Включите автообновления**
4. **Установите fail2ban**
5. **Настройте регулярные бэкапы**
6. **Мониторинг логов**

Подробнее в [полной документации](docs/SECURITY.md).

---

## 🐛 Troubleshooting

### Основные проблемы

- **WireGuard не запускается** → Проверьте IP forwarding
- **3x-ui недоступен** → Проверьте firewall и порт 2053
- **Remnawave не работает** → Проверьте Docker контейнеры
- **SSL сертификаты** → Проверьте DNS и порт 80

Подробнее в [разделе Troubleshooting](docs/TROUBLESHOOTING.md).

---

## 📊 Структура проекта

```
proxy-core/
├── 📄 install-advanced.sh      # Основной установщик
├── 🎮 manage.sh               # Менеджер панелей
├── 🔧 wg-manager.sh           # WireGuard менеджер
├── 🔄 update.sh               # Обновление
├── 📄 install.sh              # Базовый установщик
├── 📖 README.md               # Документация
└── 📜 LICENSE                 # MIT License
```

---

## 🤝 Благодарности

Проект основан на лучших практиках из:

- [3dp-manager](https://github.com/denpiligrim/3dp-manager)
- [remnawave-reverse-proxy](https://github.com/eGamesAPI/remnawave-reverse-proxy)
- [remnawave-scripts](https://github.com/DigneZzZ/remnawave-scripts)
- [RemnaSetup](https://github.com/Capybara-z/RemnaSetup)

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

### Version 2.0.0 (2026-04-22)

✨ **Новое:**
- Поддержка Hysteria2
- Улучшенное управление SSL (3 метода)
- Автоматическая настройка BBR
- Многоязычный интерфейс (EN/RU)
- Spinner анимация
- Система логирования

🔧 **Улучшения:**
- Оптимизированная установка Docker
- Автоопределение Docker Compose v1/v2
- Улучшенная обработка ошибок

---

<div align="center">

### 💖 Сделано с любовью by [houseassassin](https://github.com/houseassassin)

**Если проект помог вам, поставьте ⭐ звезду!**

[⬆ Наверх](#-proxy-core)

</div>
