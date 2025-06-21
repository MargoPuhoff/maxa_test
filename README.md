# Maxa Test - API для управления заметками

## Технологии

- **Ruby** 3.x
- **Rails** 7.2.2
- **SQLite3** (база данных)
- **RSpec** (тестирование)
- **Factory Bot** (фабрики для тестов)
- **Active Model Serializers** (сериализация JSON)

## Требования

- Ruby 3.x или выше
- Bundler
- SQLite3

## Установка и запуск

### 1. Клонирование проекта

git clone <URL_РЕПОЗИТОРИЯ>
cd maxa_test

### 2. Установка зависимостей

bundle install

### 3. Настройка базы данных

rails db:create
rails db:migrate


### 4. Запуск сервера

rails server

## API Endpoints

- `GET /notes` - Получить список всех заметок
- `GET /notes/:id` - Получить конкретную заметку
- `POST /notes` - Создать новую заметку
- `PUT /notes/:id` - Обновить заметку
- `DELETE /notes/:id` - Удалить заметку

### Параметры для создания/обновления заметки

{
  "title": "Заголовок заметки",
  "content": "Содержание заметки",
  "archived": false
}

## Тестирование

### Запуск тестов

bundle exec rspec - запустит все тесты

### Структура тестов

- `spec/models/` - тесты моделей
- `spec/controllers/` - тесты контроллеров
- `spec/requests/` - интеграционные тесты API
- `spec/factories/` - фабрики для тестовых данных
