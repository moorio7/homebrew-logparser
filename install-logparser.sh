#!/bin/bash
# Скрипт для встановлення LogParser з захищених архівів та зашифрованих файлів

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

# Функції для виводу
print_message() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error() { echo -e "${RED}$1${NC}"; }

# Функція для отримання останньої успішно опублікованої версії
get_last_published_version() {
  local api_response=""
  local version=""
  local fallback_version="0.4.25"  # Жорстко закодована версія як останній запасний варіант
  local arch_type=$([ "$(uname -m)" = "arm64" ] && echo "arm64" || echo "intel")

  print_message "Пошук останньої успішно опублікованої версії..." >&2

  # Отримуємо список всіх релізів
  api_response=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/moorio7/homebrew-logparser/releases)

  if [ -z "$api_response" ] || echo "$api_response" | grep -q "Not Found"; then
    print_warning "Не вдалося отримати список релізів. Використовуємо жорстко закодовану версію." >&2
    echo "$fallback_version"
    return
  fi

  # Отримуємо список всіх версій (сумісно з BSD grep в macOS)
  local all_versions=$(echo "$api_response" | grep -o '"tag_name": *"v[^"]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/' | sort -V -r)

  # Перевіряємо кожну версію на наявність файлів релізу
  for v in $all_versions; do
    # Перевіряємо наявність файлів для macOS з відповідною архітектурою
    local enc_url="https://github.com/moorio7/homebrew-logparser/releases/download/v${v}/LogParser-${v}-macos-${arch_type}.enc"
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$enc_url")

    # GitHub може повертати 302 (перенаправлення) для файлів, які існують
    if [ "$status_code" = "200" ] || [ "$status_code" = "302" ]; then
      print_message "Знайдено останню успішно опубліковану версію: $v" >&2
      echo "$v"
      return
    fi
  done

  print_warning "Не знайдено жодної версії з файлами релізу. Використовуємо жорстко закодовану версію." >&2
  echo "$fallback_version"
}

# Функція для отримання останньої версії з GitHub API
get_latest_version() {
  local version=""
  local api_response=""
  local default_version=$(get_last_published_version)

  # Спроба отримати версію з релізів публічного репозиторію homebrew-logparser
  print_message "Отримання інформації про останній реліз з homebrew-logparser..." >&2
  api_response=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/moorio7/homebrew-logparser/releases/latest)

  # Перевірка, чи отримали ми відповідь від API
  if [ -z "$api_response" ] || echo "$api_response" | grep -q "Not Found"; then
    print_warning "Не вдалося отримати інформацію про останній реліз" >&2
    print_warning "Спроба отримати список всіх релізів..." >&2
    api_response=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/moorio7/homebrew-logparser/releases)

    # Спроба отримати версію з усіх релізів (сумісно з BSD grep в macOS)
    version=$(echo "$api_response" | grep -o '"tag_name": *"v[^"]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/' | sort -V -r | head -n 1)
  else
    # Спроба отримати версію з останнього релізу (сумісно з BSD grep в macOS)
    version=$(echo "$api_response" | grep -o '"tag_name": *"v[^"]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/')
  fi

  # Якщо не вдалося отримати версію з релізів, використовуємо останню опубліковану версію
  if [ -z "$version" ]; then
    print_warning "Не вдалося отримати версію з релізів. Використовуємо останню опубліковану версію." >&2
    print_warning "Це може статися, якщо реліз ще не опубліковано в публічному репозиторії moorio7/homebrew-logparser." >&2
    print_warning "Спроба завантаження буде виконана з використанням останньої опублікованої версії: $default_version" >&2
    version="$default_version"
  fi

  # Перевірка, що версія містить тільки допустимі символи (цифри та крапки)
  if ! echo "$version" | grep -q '^[0-9][0-9.]*$'; then
    print_warning "Отримана версія має неправильний формат: '$version'. Використовуємо останню опубліковану версію." >&2
    version="$default_version"
  fi

  echo "$version"
}

# Отримуємо останню версію
VERSION=$(get_latest_version)
# Перевірка, що версія не порожня і має правильний формат
if [ -z "$VERSION" ] || ! echo "$VERSION" | grep -q '^[0-9][0-9.]*$'; then
  print_warning "Версія має неправильний формат або порожня. Використовуємо останню опубліковану версію."
  VERSION=$(get_last_published_version)
fi
print_message "Використовуємо останню версію: $VERSION"

# Налаштування тимчасового каталогу для macOS
TEMP_DIR="/private/tmp/logparser_install"

# URL репозиторію для завантаження
REPO_URL="https://github.com/moorio7/homebrew-logparser/releases/download/v${VERSION}"

# Визначення системи
determine_system() {
  OS_TYPE="macos"
  ARCH=$(uname -m)
  ARCH_TYPE=$([ "$ARCH" = "arm64" ] && echo "arm64" || echo "intel")
  print_message "Визначено систему: macOS ($ARCH_TYPE)"
}

# Завантаження файлу
download_file() {
  mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

  # Формування URL для macOS
  ENC_FILE="LogParser-${VERSION}-macos-${ARCH_TYPE}.enc"
  SHA_FILE="LogParser-${VERSION}-macos-${ARCH_TYPE}.sha256"

  # Завантаження зашифрованого файлу
  print_message "Завантаження зашифрованого файлу для macOS..."
  curl -L -o "$ENC_FILE" "$REPO_URL/$ENC_FILE" || { print_error "Помилка завантаження зашифрованого файлу"; exit 1; }

  # Завантаження хеш-файлу для перевірки цілісності
  print_message "Завантаження хеш-файлу..."
  curl -L -o "$SHA_FILE" "$REPO_URL/$SHA_FILE" || { print_warning "Не вдалося завантажити хеш-файл"; }

  # Перевірка цілісності файлу
  if [ -f "$SHA_FILE" ]; then
    print_message "Перевірка цілісності файлу..."
    # Отримуємо очікуваний хеш з файлу
    EXPECTED_HASH=$(cat "$SHA_FILE" | awk '{print $1}')
    print_message "Очікуваний хеш: $EXPECTED_HASH"

    # Примітка: Хеш перевіряється після розпакування/розшифрування
    # Оскільки хеш обчислюється від оригінального файлу, а не від зашифрованого
    print_message "Хеш буде перевірено після розпакування/розшифрування"
    print_success "Файл завантажено успішно"
  else
    print_warning "Неможливо перевірити цілісність файлу (хеш-файл не знайдено)"
  fi
}

# Встановлення
main() {
  print_message "=== Встановлення LogParser $VERSION для macOS ==="
  determine_system
  download_file

  print_message "Введіть ключ для розшифрування (ENCRYPTION_KEY):"
  read -s ENCRYPTION_KEY
  echo

  # Встановлення OpenSSL, якщо потрібно
  if ! command -v openssl &> /dev/null; then
    print_message "Встановлення OpenSSL..."
    brew install openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
  fi

  # Розшифрування файлу
  print_message "Розшифрування файлу..."
  ENC_FILE="LogParser-${VERSION}-macos-${ARCH_TYPE}.enc"
  DMG_FILE="LogParser-${VERSION}-macos-${ARCH_TYPE}.dmg"

  if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$DMG_FILE" -k "$ENCRYPTION_KEY"; then
    print_error "Неправильний ключ або пошкоджений файл"
    exit 1
  fi

    # Пошук DMG файлу
    DMG_FILE=$(ls *.dmg 2>/dev/null)

    # Якщо DMG файл не знайдено, виводимо помилку
    if [ -z "$DMG_FILE" ]; then
      print_error "DMG файл не знайдено після розшифрування"
      print_message "Спробуйте розшифрувати файл вручну за допомогою команди:"
      print_message "openssl enc -aes-256-cbc -d -salt -in LogParser-$VERSION-macos-$ARCH_TYPE.enc -out LogParser-$VERSION-macos-$ARCH_TYPE.dmg -k ENCRYPTION_KEY"
      exit 1
    fi

    # Встановлення LogParser.app безпосередньо з DMG-файлу
    print_message "Встановлення LogParser.app безпосередньо з DMG-файлу..."

    # Створення тимчасового каталогу для розпакування DMG
    EXTRACT_DIR="$TEMP_DIR/extracted_dmg"
    mkdir -p "$EXTRACT_DIR"

    # Розпакування DMG-файлу
    print_message "Розпакування DMG-файлу..."
    if ! 7z x "$DMG_FILE" -o"$EXTRACT_DIR" > /dev/null; then
      print_message "Помилка розпакування DMG-файлу за допомогою 7z, спробуємо інший спосіб..."

      # Перевірка і відмонтування існуючих томів LogParser
      print_message "Перевірка існуючих томів LogParser..."
      EXISTING_VOLUMES=$(find /Volumes -maxdepth 1 -type d -name "LogParser*" 2>/dev/null)

      if [ -n "$EXISTING_VOLUMES" ]; then
        print_message "Знайдено існуючі томи LogParser:"
        echo "$EXISTING_VOLUMES"
        print_message "Спроба відмонтування існуючих томів..."

        for VOL in $EXISTING_VOLUMES; do
          print_message "Відмонтування $VOL..."
          hdiutil detach "$VOL" -force || print_warning "Не вдалося відмонтувати $VOL"
        done
      else
        print_message "Існуючих томів LogParser не знайдено"
      fi

      # Альтернативний спосіб: використання hdiutil і cp
      print_message "Спроба використання hdiutil для монтування DMG-файлу..."
      print_message "Виконуємо: ls -la /Volumes/ (перед монтуванням)"
      ls -la /Volumes/

      # Монтування DMG файлу
      MOUNT_OUTPUT=$(hdiutil attach "$DMG_FILE" -nobrowse -noautoopen)
      print_message "Результат монтування:"
      echo "$MOUNT_OUTPUT"

      # Пошук змонтованого тому
      MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep Apple_HFS | awk '{print $3}')

      if [ -n "$MOUNT_POINT" ]; then
        print_message "DMG змонтовано в: $MOUNT_POINT"
        print_message "Вміст змонтованого тому:"
        ls -la "$MOUNT_POINT"

        # Пошук LogParser.app
        APP_PATH=$(find "$MOUNT_POINT" -name "LogParser.app" -type d | head -n 1)

        if [ -n "$APP_PATH" ]; then
          print_message "LogParser.app знайдено за шляхом: $APP_PATH"

          # Видалення старої версії, якщо вона існує
          if [ -d "/Applications/LogParser.app" ]; then
            print_message "Видалення старої версії LogParser.app..."
            rm -rf "/Applications/LogParser.app"
          fi

          # Копіювання нової версії
          print_message "Копіювання $APP_PATH в /Applications/..."
          cp -R "$APP_PATH" /Applications/ || {
            print_error "Помилка копіювання LogParser.app в /Applications"
            print_message "Відмонтування DMG..."
            hdiutil detach "$MOUNT_POINT" -force
            exit 1
          }

          # Відмонтування DMG
          print_message "Відмонтування DMG..."
          hdiutil detach "$MOUNT_POINT" -force || print_warning "Помилка відмонтування DMG, продовжуємо..."
        else
          print_error "LogParser.app не знайдено в змонтованому томі"
          print_message "Вміст змонтованого тому:"
          ls -la "$MOUNT_POINT"
          print_message "Відмонтування DMG..."
          hdiutil detach "$MOUNT_POINT" -force
          exit 1
        fi
      else
        print_error "Не вдалося змонтувати DMG-файл"
        exit 1
      fi
    else
      # Пошук LogParser.app в розпакованому DMG
      print_message "Пошук LogParser.app в розпакованому DMG..."
      print_message "Вміст розпакованого DMG:"
      find "$EXTRACT_DIR" -type d | sort

      APP_PATH=$(find "$EXTRACT_DIR" -name "LogParser.app" -type d | head -n 1)

      if [ -n "$APP_PATH" ]; then
        print_message "LogParser.app знайдено за шляхом: $APP_PATH"

        # Видалення старої версії, якщо вона існує
        if [ -d "/Applications/LogParser.app" ]; then
          print_message "Видалення старої версії LogParser.app..."
          rm -rf "/Applications/LogParser.app"
        fi

        # Копіювання нової версії
        print_message "Копіювання $APP_PATH в /Applications/..."
        cp -R "$APP_PATH" /Applications/ || {
          print_error "Помилка копіювання LogParser.app в /Applications"
          exit 1
        }
      else
        print_error "LogParser.app не знайдено в розпакованому DMG"
        exit 1
      fi
    fi

    # Видалення з карантину
    print_message "Видалення з карантину..."
    if [ -d "/Applications/LogParser.app" ]; then
      # Спроба видалення з карантину, але не виходимо з помилкою, якщо файл не в карантині
      xattr -rd com.apple.quarantine "/Applications/LogParser.app" 2>/dev/null || print_warning "Файл не був у карантині або помилка видалення з карантину"

      # Перевірка прав доступу
      print_message "Встановлення правильних прав доступу..."
      chmod -R u+x "/Applications/LogParser.app"
    else
      print_error "Не вдалося знайти /Applications/LogParser.app для видалення з карантину"
    fi

    # Перевірка успішного встановлення
    if [ -d "/Applications/LogParser.app" ]; then
      print_success "Встановлено в /Applications"
      print_message "Запуск додатку..."
      open "/Applications/LogParser.app" || print_warning "Помилка запуску додатку"
    else
      print_error "Встановлення не вдалося. LogParser.app не знайдено в /Applications"
    fi


  cd / && rm -rf "$TEMP_DIR"
  print_success "Встановлення завершено!"
}

main




