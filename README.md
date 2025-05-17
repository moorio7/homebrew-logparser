<meta name="robots" content="noindex, nofollow">
<meta name="googlebot" content="noindex, nofollow">
<meta name="bingbot" content="noindex, nofollow">
<meta name="slurp" content="noindex, nofollow">
<meta name="duckduckbot" content="noindex, nofollow">
<meta name="baiduspider" content="noindex, nofollow">
<meta name="yandexbot" content="noindex, nofollow">
<meta name="sogou" content="noindex, nofollow">
<meta name="ia_archiver" content="noindex, nofollow">

# Homebrew Tap for LogParser

Цей репозиторій містить Homebrew формулу для встановлення [LogParser](https://github.com/moorio7/LogParser) - програми для аналізу та перегляду лог-файлів з підтримкою різних форматів та зручним інтерфейсом.

> **Примітка**: Homebrew рекомендується для macOS. Для Linux використовуйте спеціальний скрипт встановлення або захищений архів (див. Варіант 2). Для Windows використовуйте захищений ZIP-архів (див. Варіант 2).

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

5. **ВАЖЛИВО**: Скрипт автоматично встановить останню доступну версію. Для розпакування архіву вам знадобиться пароль. Зверніться до розробника для отримання пароля.

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

<details>
<summary><b>Вирішення проблем з встановленням</b></summary>

### Проблеми з кешем Homebrew

Очистити кеш Homebrew:

```bash
brew cleanup
```

```bash
brew cleanup --prune=all
```

Оновити Homebrew та формули:

```bash
brew update
```

```bash
brew update-reset
```

### Проблеми з хешами

Якщо виникає помилка "SHA256 mismatch":

Очистити кеш завантажень:

```bash
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
```

Оновити формулу:

```bash
brew update
```

Перевстановити:

```bash
brew reinstall logparser
```

### Проблеми з правами доступу

Якщо виникають проблеми з правами доступу:

Виправити права доступу для Homebrew:

```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```

Перевстановити формулу:

```bash
brew reinstall logparser
```

### Повне скидання Homebrew

Для повного скидання та перевстановлення:

1. Видалити всі кешовані файли LogParser:
```bash
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
```

2. Очистити кеш Homebrew:
```bash
brew cleanup --prune=all
```

3. Оновити Homebrew:
```bash
brew update
```

4. Видалити формулу LogParser:
```bash
brew uninstall logparser
```

5. Видалити теп репозиторію:
```bash
brew untap moorio7/logparser
```

6. Додати теп знову:
```bash
brew tap moorio7/logparser
```

7. Встановити LogParser заново:
   ```bash
   brew install logparser
   install-logparser
   ```
</details>

#### Видалення LogParser

Для видалення LogParser:

```bash
brew uninstall logparser
```

Для видалення tap:

```bash
brew untap moorio7/logparser
```

### Варіант 2: Встановлення через захищені архіви

#### Для Linux (рекомендовано):

##### Метод A: Використання скрипту встановлення

1. Завантажте скрипт встановлення:
   ```bash
   curl -L -o install-logparser-linux.sh https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser-linux.sh
   ```

2. Зробіть скрипт виконуваним:
   ```bash
   chmod +x install-logparser-linux.sh
   ```

3. Запустіть скрипт встановлення:
   ```bash
   ./install-logparser-linux.sh
   ```

4. При запиті введіть ключ для розшифрування (зверніться до розробника для отримання ключа).

##### Метод B: Ручне встановлення

1. Завантажте захищений файл з останнього релізу:
   ```bash
   curl -L -o LogParser-0.4.25-linux.enc https://github.com/moorio7/homebrew-logparser/releases/download/v0.4.25/LogParser-0.4.25-linux.enc
   ```
   (Замініть 0.4.25 на актуальну версію, якщо потрібно)

2. Розшифруйте файл за допомогою OpenSSL:
   ```bash
   openssl enc -aes-256-cbc -d -salt -in LogParser-0.4.25-linux.enc -out LogParser-0.4.25-linux.deb -k ENCRYPTION_KEY
   ```
   (Замініть ENCRYPTION_KEY на ключ, отриманий від розробника)

3. Встановіть DEB-пакет:
   ```bash
   sudo apt install -y ./LogParser-0.4.25-linux.deb
   ```

4. Запустіть програму:
   ```bash
   logparser
   ```

#### Для Windows:

1. Завантажте захищений ZIP-архів з останнього релізу:
   ```
   https://github.com/moorio7/homebrew-logparser/releases/download/v0.4.25/LogParser-0.4.25-windows.zip
   ```
   (Замініть 0.4.25 на актуальну версію, якщо потрібно)

2. Розпакуйте архів за допомогою 7-Zip або іншого архіватора, який підтримує захищені паролем архіви.

3. При запиті пароля введіть ENCRYPTION_KEY (зверніться до розробника для отримання ключа).

4. Після розпакування ви отримаєте виконуваний EXE-файл, який можна скопіювати на робочий стіл або запустити безпосередньо.

#### Вимоги для Windows

- Для розпакування архіву потрібен 7-Zip або інший архіватор, який підтримує захищені паролем ZIP-архіви.
- Windows 7/8/10/11 (32 або 64-біт)

#### Вимоги для Linux

- Debian/Ubuntu або інший дистрибутив, що підтримує DEB-пакети
- OpenSSL для розшифрування файлів

## Підтримувані платформи

- macOS (Intel та Apple Silicon)
- Linux (Debian/Ubuntu)
- Windows

## Особливості

- Аналіз та перегляд лог-файлів різних форматів
- Зручний інтерфейс користувача
- Фільтрація та пошук у логах
- Підсвічування синтаксису
- Покращена робота з DPI

## Безпека

Програма розповсюджується у вигляді захищених файлів для захисту інтелектуальної власності.
Для отримання ключа для розшифрування файлів або розпакування архівів зверніться до розробника програми.

Для macOS та Linux використовується шифрування AES-256, а для Windows - захищені паролем ZIP-архіви. Для перевірки цілісності файлів використовуються SHA-256 хеші.

## Ліцензія

Всі права захищені. Несанкціоноване копіювання, розповсюдження або модифікація програми заборонені.
