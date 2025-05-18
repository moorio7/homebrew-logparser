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

Homebrew формула для встановлення [LogParser](https://github.com/moorio7/LogParser) - програми для аналізу лог-файлів з підтримкою різних форматів.

<details>
<summary><b>Підтримувані платформи</b></summary>

- **macOS**: Встановлення через Homebrew (Intel та Apple Silicon)
- **Linux**: Встановлення через скрипт або DEB-пакет
- **Windows**: Встановлення через захищений ZIP-архів
</details>

## Швидке встановлення

### Для macOS

1. Встановіть Homebrew, якщо він ще не встановлений:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Встановіть LogParser:
   ```bash
   brew tap moorio7/logparser
   brew install logparser
   install-logparser  # Введіть ключ, коли буде запропоновано
   ```

> **Примітка**: Для розпакування архіву вам знадобиться ключ. Зверніться до розробника для отримання ключа.

#### Оновлення та обслуговування

```bash
# Оновлення LogParser до нової версії
brew update
brew upgrade logparser
install-logparser

# Перевстановлення LogParser (якщо виникли проблеми)
brew reinstall logparser
install-logparser
```

<details>
<summary><b>Вирішення проблем з встановленням</b></summary>

### Швидке вирішення проблем

```bash
# Очистити кеш і оновити Homebrew
brew cleanup --prune=all
brew update

# Перевстановити LogParser
brew reinstall logparser
install-logparser
```

### Проблеми з хешами (SHA256 mismatch)

```bash
# Очистити кеш завантажень і перевстановити
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
brew update
brew reinstall logparser
```

### Проблеми з правами доступу

```bash
# Виправити права доступу і перевстановити
sudo chown -R $(whoami) $(brew --prefix)/*
brew reinstall logparser
```

### Повне скидання Homebrew

```bash
# Видалити кеш і формулу
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
brew cleanup --prune=all
brew update
brew uninstall logparser
brew untap moorio7/logparser

# Встановити заново
brew tap moorio7/logparser
brew install logparser
install-logparser
```
</details>

#### Видалення LogParser

```bash
# Видалення програми та репозиторію
brew uninstall logparser
brew untap moorio7/logparser
```

### Для Linux

```bash
# Встановіть curl, якщо його немає
sudo apt update
sudo apt install -y curl

# Швидке встановлення
curl -L -o install-logparser-linux.sh https://github.com/moorio7/homebrew-logparser/releases/latest/download/install-logparser-linux.sh
chmod +x install-logparser-linux.sh
./install-logparser-linux.sh  # Введіть ключ, коли буде запропоновано
```

### Для Windows

1. Завантажте останню версію LogParser з [сторінки релізів](https://github.com/moorio7/homebrew-logparser/releases/latest)
2. Розпакуйте ZIP-архів за допомогою 7-Zip чи іншого архіватора (введіть ключ, коли буде запропоновано)
3. Запустіть розпакований EXE-файл

<details>
<summary><b>Видалення LogParser</b></summary>

### Для macOS (встановлено через Homebrew):
```bash
brew uninstall logparser
```

### Для Linux:
```bash
sudo apt-get remove logparser
sudo apt-get purge logparser  # Видаляє також конфігураційні файли
```

### Для Windows:
Видаліть папку з розпакованими файлами LogParser
</details>

<details>
<summary><b>Системні вимоги</b></summary>

**Windows**:
- Windows 7/8/10/11 (32 або 64-біт)
- Архіватор з підтримкою захищених паролем ZIP-архівів

**Linux**:
- Debian/Ubuntu або інший дистрибутив з підтримкою DEB-пакетів
- OpenSSL для розшифрування файлів

**macOS**:
- macOS 10.14 або новіше (Intel або Apple Silicon)
- Homebrew
</details>

<details>
<summary><b>Особливості LogParser</b></summary>

- Аналіз та перегляд лог-файлів різних форматів
- Зручний інтерфейс користувача з підтримкою тем
- Фільтрація та пошук у логах з регулярними виразами
- Підсвічування синтаксису та кольорове кодування
</details>

<details>
<summary><b>Безпека та ліцензування</b></summary>

### Безпека
- Шифрування AES-256 для macOS та Linux
- Захищені паролем ZIP-архіви для Windows
- Перевірка цілісності файлів через SHA-256 хеші

### Ліцензія
Всі права захищені. Несанкціоноване копіювання, розповсюдження або модифікація програми заборонені.
</details>
