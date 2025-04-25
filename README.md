<meta name="robots" content="noindex">

# Homebrew Tap for LogParser

Цей репозиторій містить Homebrew формулу для встановлення [LogParser](https://github.com/moorio7/LogParser) - програми для аналізу та перегляду лог-файлів з підтримкою різних форматів та зручним інтерфейсом.

> **Примітка**: Homebrew підтримує лише macOS. Для Windows використовуйте захищений ZIP-архів (див. Варіант 2).

## Встановлення

### Варіант 1: Встановлення через Homebrew (рекомендовано для macOS)

1. Встановіть Homebrew, якщо він ще не встановлений:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Додайте tap для LogParser:
   ```bash
   brew tap moorio7/logparser
   ```

3. Встановіть LogParser:
   ```bash
   brew install logparser
   ```

4. Запустіть скрипт встановлення:
   ```bash
   install-logparser
   ```

5. **ВАЖЛИВО**: Для розпакування архіву вам знадобиться пароль. Зверніться до розробника для отримання пароля.

#### Оновлення LogParser

Для оновлення LogParser до нової версії:

```bash
brew update
brew upgrade logparser
install-logparser
```

#### Перевстановлення LogParser

Якщо виникли проблеми з встановленням, ви можете перевстановити LogParser:

```bash
brew reinstall logparser
install-logparser
```

#### Вирішення проблем з встановленням

##### Проблеми з кешем Homebrew

Якщо виникають помилки з кешем або хешами:

```bash
# Очистити кеш Homebrew
brew cleanup
brew cleanup --prune=all

# Оновити Homebrew та формули
brew update
brew update-reset

# Перевстановити формулу
brew reinstall logparser
```

##### Проблеми з хешами

Якщо виникає помилка "SHA256 mismatch":

```bash
# Очистити кеш завантажень
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"

# Оновити формулу та перевстановити
brew update
brew reinstall logparser
```

##### Проблеми з версіями

Якщо потрібно встановити конкретну версію:

```bash
# Встановити конкретну версію (наприклад, 0.4.1)
brew install logparser@0.4.1
```

Для перевірки доступних версій:

```bash
brew info logparser
```

##### Проблеми з правами доступу

Якщо виникають проблеми з правами доступу:

```bash
# Виправити права доступу для Homebrew
sudo chown -R $(whoami) $(brew --prefix)/*

# Перевстановити формулу
brew reinstall logparser
```

##### Повне скидання

Для повного скидання та перевстановлення:

```bash
# Видалити формулу
brew uninstall --force logparser

# Видалити tap
brew untap moorio7/logparser

# Очистити кеш
brew cleanup --prune=all

# Додати tap знову
brew tap moorio7/logparser

# Встановити формулу
brew install logparser
install-logparser
```

#### Видалення LogParser

Для видалення LogParser:

```bash
brew uninstall logparser
```

Для видалення tap:

```bash
brew untap moorio7/logparser
```

### Варіант 2: Встановлення через захищений ZIP-архів (Windows)

1. Завантажте захищений ZIP-архів з останнього релізу:
   ```
   https://github.com/moorio7/homebrew-logparser/releases/download/vX.Y.Z/LogParser-X.Y.Z-windows.zip
   ```
   (Замініть X.Y.Z на актуальну версію, наприклад 0.4.1)

2. Розпакуйте архів за допомогою 7-Zip або іншого архіватора, який підтримує захищені паролем архіви.

3. При запиті пароля введіть ENCRYPTION_KEY (зверніться до розробника для отримання ключа).

4. Після розпакування ви отримаєте виконуваний EXE-файл, який можна скопіювати на робочий стіл або запустити безпосередньо.

#### Вимоги для Windows

- Для розпакування архіву потрібен 7-Zip або інший архіватор, який підтримує захищені паролем ZIP-архіви.

## Підтримувані платформи

- macOS (Intel та Apple Silicon)
- Windows

## Особливості

- Аналіз та перегляд лог-файлів різних форматів
- Зручний інтерфейс користувача
- Фільтрація та пошук у логах
- Підсвічування синтаксису
- Експорт результатів

## Вирішення проблем з версіями

Якщо виникають проблеми з версіями:

1. **Перевірте поточну версію**:
   - Виконайте команду: `brew info logparser`
   - Перевірте версію встановленої формули: `brew list --versions logparser`

2. **Перевірте, чи співпадають версії**:
   - Версія формули: `brew info logparser | grep "logparser:" | awk '{print $3}'`
   - Версія в репозиторії: `brew tap-info moorio7/logparser --json | grep -o '"version":"[^"]*"'`

3. **Оновіть кеш формул**:
   - Виконайте команду: `brew update-reset`
   - Потім: `brew update`

4. **Видаліть стару версію**:
   - Виконайте команду: `brew uninstall --force logparser`
   - Очистіть кеш: `brew cleanup --prune=all`

5. **Встановіть конкретну версію**:
   - Виконайте команду: `brew install logparser@X.Y.Z`

6. **Повне скидання Homebrew**:
   Якщо проблеми з версіями не вирішуються:
   ```bash
   # Видаліть всі tap
   brew untap --force moorio7/logparser

   # Очистіть кеш
   brew cleanup --prune=all

   # Скиньте Homebrew
   cd "$(brew --repo)" && git reset --hard && git clean -df

   # Додайте tap знову
   brew tap moorio7/logparser

   # Встановіть LogParser
   brew install logparser
   ```

## Безпека

Програма розповсюджується у вигляді захищених файлів для захисту інтелектуальної власності.
Для отримання ключа для розшифрування файлів або розпакування архівів зверніться до розробника програми.

Для macOS використовується шифрування AES-256, а для Windows - захищені паролем ZIP-архіви. Для перевірки цілісності файлів використовуються SHA-256 хеші.

## Ліцензія

Всі права захищені. Несанкціоноване копіювання, розповсюдження або модифікація програми заборонені.
