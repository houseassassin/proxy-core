# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.1] - 2026-04-24

### Added
- ✨ **Полная реализация функций установки всех панелей**
  - `install_wireguard()` - автоматическая установка и настройка WireGuard
  - `install_3xui()` - установка 3x-ui через официальный скрипт
  - `install_remnawave()` - установка Remnawave с Docker и генерацией паролей
  - `install_hysteria2()` - установка Hysteria2 с сертификатами и systemd
  - Улучшенная `install_mtproxy()` с сохранением конфигурации
- 📱 **QR-код для MTProxy** - автоматическая генерация при установке
- 💾 **Сохранение конфигурации MTProxy** в `/opt/MTProxy/.config`
- 🔄 **Опция "Установить всё"** - последовательная установка всех панелей
- 🔁 **Цикл меню в wg-manager.sh** - меню больше не закрывается после действия
- 📚 **Общая библиотека функций** `lib/common.sh`:
  - Функции валидации (порты, имена, IP)
  - Сетевые утилиты (получение IP, генерация портов)
  - Системные проверки (root, OS detection)
  - Утилиты (spinner, confirm, генерация паролей)
- 📚 **Библиотека WireGuard** `lib/wireguard.sh` - общие функции для управления клиентами
- 📚 **Библиотека логирования** `lib/logging.sh` - централизованное логирование
- ⚙️ **Конфигурационный файл** `config/defaults.conf` - настройки по умолчанию
- 🔧 **Reverse Proxy Manager** `reverse-proxy-manager.sh`:
  - Установка и настройка Nginx, Caddy, HAProxy
  - Автоматическая настройка для 3x-ui
  - Балансировка нагрузки с HAProxy
  - Гибридные конфигурации (Nginx + Caddy)
  - Подсказки и рекомендации по выбору
- 📁 **Структура проекта** - добавлены директории `lib/`, `config/`, `tests/`

### Fixed
- 🐛 **Критический баг**: функции установки панелей не были реализованы (только комментарии)
- 🐛 **Критический баг**: MTProxy конфигурация (SECRET и PORT) не сохранялась
- 🐛 **Критический баг**: Selfsteal падал с ошибкой если Remnawave не установлен
- 🐛 **Баг**: wg-manager.sh закрывался после каждого действия (отсутствовал цикл)
- 🐛 **Баг**: устаревшая команда `docker-compose` (заменена на `docker compose`)

### Changed
- 🔄 **Обновлено на Docker Compose v2** - использование `docker compose` вместо `docker-compose`
- 🔍 **Улучшена проверка зависимостей** в Selfsteal - автоопределение reverse proxy
- 🎨 **Улучшен UX** - добавлены подтверждения для критических операций
- 📝 **Улучшены сообщения об ошибках** - более информативные и понятные

### Security
- 🔒 **Валидация пользовательского ввода** - проверка портов, имён, IP адресов
- 🔒 **Безопасная генерация паролей** - использование `openssl rand`
- 🔒 **Проверка доступности портов** перед использованием

## [2.1.0] - 2026-04-22

### Added
- 📱 Поддержка MTProxy для Telegram
- 🔄 Выбор Reverse Proxy (Nginx/Caddy)
- 🎭 Selfsteal - маскировка под обычный сайт
- 📱 QR-коды для MTProxy
- 🎮 Менеджер MTProxy

### Changed
- Интерактивный выбор компонентов
- Улучшенная система меню
- Больше опций конфигурации

### Fixed
- Исправлена ошибка создания директории логов

## [2.0.0] - 2026-04-20

### Added
- Поддержка WireGuard VPN
- Поддержка 3x-ui Panel
- Поддержка Remnawave Panel
- Поддержка Hysteria2 Proxy
- Автоматическая установка Docker
- Настройка firewall (UFW/firewalld)
- BBR оптимизация TCP
- Автоматическое создание swap
- SSL/TLS сертификаты (Let's Encrypt, Cloudflare DNS, Gcore DNS)
- Мониторинг сервисов и ресурсов
- Резервное копирование и восстановление
- Управление клиентами WireGuard
- Генерация QR-кодов
- Многоязычность (EN/RU)

### Changed
- Полностью переписан установщик
- Улучшен интерфейс
- Добавлена модульность

## [1.0.0] - 2026-04-15

### Added
- Первый релиз
- Базовая установка VPN панелей
- Простое меню управления

---

## Типы изменений

- `Added` - новые функции
- `Changed` - изменения в существующем функционале
- `Deprecated` - функции, которые скоро будут удалены
- `Removed` - удалённые функции
- `Fixed` - исправления багов
- `Security` - исправления уязвимостей

---

## Ссылки

- [GitHub Repository](https://github.com/houseassassin/proxy-core)
- [Issues](https://github.com/houseassassin/proxy-core/issues)
- [Pull Requests](https://github.com/houseassassin/proxy-core/pulls)
