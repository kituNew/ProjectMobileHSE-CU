# ProjectMobile

Мобильный проект состоит из двух приложений: iOS-приложения `LectureHSE1` и Android-приложения `ProjectAndroid`. Оба приложения работают с новостями NYTimes, заметками, задачами и избранными новостями.

## Структура проекта

| Приложение | Папка | Платформа |
| --- | --- | --- |
| LectureHSE1 | `LectureHSE1/` | iOS |
| ProjectAndroid | `ProjectAndroid/` | Android |

## iOS-приложение

### Главная

- Показывает список новостей из NYTimes Article Search API.
- Использует запрос к эндпоинту `https://api.nytimes.com/svc/search/v2/articlesearch.json`.
- Поддерживает поиск новостей по строке запроса.
- Загружает изображения новостей через репозиторий и отдельный use case.
- При ошибке сети может показывать данные, сохраненные в локальном кеше.
- Каждая новость открывается на отдельном экране деталей.

### Детали новости

- Показывают заголовок, описание, дату публикации, автора и изображение новости.
- Позволяют открыть полную новость по ссылке.
- Поддерживают добавление и удаление новости из избранного через кнопку со звездой.
- Для открытия полной статьи используется отдельный `WebViewController`.

### Избранное

- Отдельная вкладка `Избранное` в tab bar.
- Показывает новости, которые пользователь добавил в избранное.
- Избранные новости достаются из локального Core Data-кеша.
- В избранном хранится полный объект новости, поэтому вкладка работает без повторного запроса к API.
- Новость можно удалить из избранного.
- Из избранного можно перейти на экран деталей новости.

### Задачи

- Отдельная вкладка `Задачи`.
- Позволяет просматривать список напоминаний.
- Поддерживает создание, редактирование и удаление задач.
- Данные задач сохраняются в Core Data.
- Экран построен через `ReminderView`, `ReminderViewModel` и `CoreDataReminderRepository`.

### Записи

- Отдельная вкладка `Записи`.
- Позволяет создавать пользовательские заметки.
- Поддерживает просмотр, редактирование и удаление заметок.
- Заметки сохраняются в Core Data.
- Для работы с заметками используются presenter, router, use cases и repository.

### Локальное хранение

- Новости кешируются в Core Data.
- Избранные новости сохраняются в Core Data как отдельная сущность.
- Задачи сохраняются в Core Data.
- Заметки сохраняются в Core Data.
- Core Data stack включает автоматическую миграцию модели.

### Архитектура

iOS-приложение разделено по feature-модулям и использует clean-подход:

- `View` отображает интерфейс.
- `Presenter` управляет состоянием экрана и пользовательскими действиями.
- `Router` отвечает за переходы между экранами.
- `UseCase` содержит сценарии приложения.
- `Repository` скрывает источник данных.
- `RemoteDataSource` работает с сетью.
- `CoreDataStack` отвечает за локальное хранение.
- `DIContainer` собирает зависимости и создает экраны.

### Основные iOS-файлы

- `LectureHSE1/LectureHSE1/DIContainer.swift`
- `LectureHSE1/LectureHSE1/Persistence/CoreDataStack.swift`
- `LectureHSE1/LectureHSE1/Screens/Home/`
- `LectureHSE1/LectureHSE1/Screens/Favorites/`
- `LectureHSE1/LectureHSE1/Screens/Note/`
- `LectureHSE1/LectureHSE1/Screens/Reminder/`

### Проверка iOS

```bash
xcodebuild -project LectureHSE1/LectureHSE1.xcodeproj -scheme LectureHSE1 -destination 'generic/platform=iOS Simulator' build
xcodebuild -project LectureHSE1/LectureHSE1.xcodeproj -scheme LectureHSE1 -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' test
```

## Android-приложение

### Главная

- Показывает список новостей из NYTimes Article Search API.
- Использует Retrofit-сервис для запроса новостей.
- Поддерживает поиск по новостям.
- Логирует отправляемый сетевой запрос для отладки.
- Загружает изображения через общий `ImageLoaderProvider`.
- Использует отдельный DNS-резолвер `PublicIpv4Dns`, чтобы избежать проблем с IPv6 на некоторых сетях.
- При сетевой ошибке может показать локально сохраненные новости или fallback-новость.

### Карточка новости

- Показывает изображение, раздел, заголовок, описание, автора и дату публикации.
- Поддерживает добавление и удаление новости из избранного через кнопку со звездой.
- Открывает native-экран деталей новости.

### Детали новости

- WebView для деталей новости больше не используется.
- Экран деталей открывается внутри приложения как обычный Compose-экран.
- Показывает изображение, раздел, заголовок, `abstract`, `lead_paragraph`, `snippet`, автора, дату и source.
- Внизу экрана есть ссылка на полную новость NYTimes.
- Ссылку можно открыть отдельно через системный обработчик ссылок.
- Из деталей можно добавить новость в избранное или убрать ее оттуда.

### Избранное

- Отдельная вкладка `Избранное`.
- Показывает только новости, которые пользователь добавил в избранное.
- Избранные новости достаются из локального кеша.
- В кеше хранится полный объект новости, поэтому вкладка не зависит от повторного сетевого запроса.
- Избранную новость можно открыть на экране деталей.
- Новость можно убрать из избранного.

### Задачи

- Отдельная вкладка `Задачи`.
- Показывает список напоминаний.
- Поддерживает создание новых напоминаний.
- Поддерживает удаление напоминаний.
- Для напоминаний используется локальный кеш.
- При первом запуске репозиторий может заполнить список стартовыми примерами.

### Записи

- Отдельная вкладка `Записи`.
- Поддерживает список заметок.
- Поддерживает создание заметки.
- Поддерживает просмотр и редактирование заметки.
- Поддерживает удаление заметки.
- Заметки сохраняются в локальный кеш.

### Локальное хранение

- Новости кешируются для offline-сценариев.
- Избранные новости сохраняются в `SharedPreferences` как сериализованный JSON.
- Заметки сохраняются в `SharedPreferences` как сериализованный JSON.
- Напоминания сохраняются в `SharedPreferences` как сериализованный JSON.
- Модели новостей, заметок и напоминаний сериализуются через `kotlinx.serialization`.

### Архитектура

Android-приложение разделено по feature-модулям и использует clean-подход:

- `View` содержит Compose UI.
- `ViewModel` управляет состоянием экрана.
- `UseCase` описывает сценарии приложения.
- `Repository` скрывает источник данных.
- `RemoteDataSource` и Retrofit-сервис работают с сетью.
- `AppContainer` выполняет роль простого DI-контейнера.
- `NetworkModule` настраивает сетевой слой.

### Основные Android-файлы

- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/MainActivity.kt`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/DI/AppContainer.kt`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/Home/`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/Favorites/`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/Notes/`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/Reminder/`
- `ProjectAndroid/app/src/main/java/com/example/projectmobileandroid/Network/`

### Проверка Android

```bash
cd ProjectAndroid
./gradlew :app:compileDebugKotlin
./gradlew :app:testDebugUnitTest
```

## API

Оба приложения используют NYTimes Article Search API:

```text
https://api.nytimes.com/svc/search/v2/articlesearch.json?q=beer&api-key=<API_KEY>
```

Ключ API задается в конфигурации приложения. Для Android ключ может попадать в `BuildConfig`, для iOS используется сетевой слой приложения.

## Тесты

- В iOS есть unit-тесты для use cases новостей и заметок.
- В Android есть unit-тесты проекта, запускаемые через Gradle.
- Перед сдачей проекта рекомендуется запускать build и test для обеих платформ.
