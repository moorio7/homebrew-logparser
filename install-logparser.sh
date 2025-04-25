#!/bin/bash
# Скрипт для встановлення LogParser з зашифрованих файлів
# Цей скрипт використовується для встановлення LogParser з https://github.com/moorio7/LogParser

# Налаштування
VERSION="0.4.1"
TEMP_DIR="/tmp/logparser_install"

# URL репозиторію для завантаження
REPO_URL="https://github.com/moorio7/homebrew-logparser/releases/download/v$VERSION"

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

# Визначення системи
determine_system() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    ARCH=$(uname -m)
    ARCH_TYPE=$([ "$ARCH" = "arm64" ] && echo "arm64" || echo "intel")
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
  elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "win32"* ]]; then
    OS_TYPE="windows"
  else
    print_error "Непідтримувана ОС: $OSTYPE"
    exit 1
  fi
}



# Завантаження файлу
download_file() {
  mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

  # Формування URL для конкретної платформи
  if [ "$OS_TYPE" = "macos" ]; then
    ENC_FILE="LogParser-$VERSION-macos-$ARCH_TYPE.enc"
    SHA_FILE="LogParser-$VERSION-macos-$ARCH_TYPE.sha256"
  elif [ "$OS_TYPE" = "linux" ]; then
    ENC_FILE="LogParser-$VERSION-linux.enc"
    SHA_FILE="LogParser-$VERSION-linux.sha256"
  elif [ "$OS_TYPE" = "windows" ]; then
    ENC_FILE="LogParser-$VERSION-windows.enc"
    SHA_FILE="LogParser-$VERSION-windows.sha256"
  else
    print_error "Непідтримувана операційна система: $OS_TYPE"
    exit 1
  fi

  print_message "Завантаження зашифрованого файлу для $OS_TYPE..."
  curl -L -o "$ENC_FILE" "$REPO_URL/$ENC_FILE" || { print_error "Помилка завантаження зашифрованого файлу"; exit 1; }

  # Завантаження хеш-файлу для перевірки цілісності
  print_message "Завантаження хеш-файлу..."
  curl -L -o "$SHA_FILE" "$REPO_URL/$SHA_FILE" || { print_warning "Не вдалося завантажити хеш-файл"; }

  # Перевірка цілісності файлу
  if [ -f "$SHA_FILE" ]; then
    print_message "Перевірка цілісності файлу..."
    # Перевірка хешу з урахуванням різних команд на різних ОС
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS використовує shasum
      EXPECTED_HASH=$(cat "$SHA_FILE" | awk '{print $1}')
      ACTUAL_HASH=$(shasum -a 256 "$ENC_FILE" | awk '{print $1}')
    else
      # Linux використовує sha256sum
      EXPECTED_HASH=$(cat "$SHA_FILE" | awk '{print $1}')
      ACTUAL_HASH=$(sha256sum "$ENC_FILE" | awk '{print $1}')
    fi

    if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
      print_error "Пошкоджений файл. Хеш не співпадає."
      exit 1
    fi
    print_success "Цілісність файлу підтверджено"
  else
    print_warning "Неможливо перевірити цілісність файлу"
  fi
}

# Встановлення
main() {
  print_message "=== Встановлення LogParser $VERSION ==="
  determine_system
  download_file

  # Встановлення OpenSSL
  if ! command -v openssl &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      print_message "Встановлення OpenSSL..."
      brew install openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      print_message "Встановлення OpenSSL..."
      sudo apt-get update && sudo apt-get install -y openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
    fi
  fi

  print_message "Введіть ключ для розшифрування файлу:"
  read -s ENCRYPTION_KEY
  echo

  # Розшифрування файлу
  print_message "Розшифрування файлу..."
  if [ "$OS_TYPE" = "macos" ]; then
    # Розшифрування файлу
    DMG_FILE="LogParser-$VERSION-macos-$ARCH_TYPE.dmg"
    if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$DMG_FILE" -k "$ENCRYPTION_KEY"; then
      print_error "Неправильний ключ або пошкоджений файл"
      exit 1
    fi

    # Монтування DMG файлу
    print_message "Монтування DMG файлу..."
    hdiutil attach "$DMG_FILE" -nobrowse -noautoopen

    # Використовуємо прямий шлях до тому
    VOLUME_NAME="LogParser-$VERSION-$ARCH_TYPE"
    MOUNT_POINT="/Volumes/$VOLUME_NAME"

    # Перевірка чи існує точка монтування
    if [ ! -d "$MOUNT_POINT" ]; then
      print_error "Не вдалося змонтувати DMG файл"
      # Спробуємо знайти точку монтування іншим способом
      MOUNT_POINT=$(df | grep LogParser | awk '{print $NF}')
      if [ -z "$MOUNT_POINT" ] || [ ! -d "$MOUNT_POINT" ]; then
        print_error "Не вдалося знайти точку монтування"
        exit 1
      fi
    fi

    print_message "Точка монтування: $MOUNT_POINT"

    # Перевірка вмісту точки монтування
    print_message "Вміст точки монтування:"
    ls -la "$MOUNT_POINT"

    # Пошук додатку в змонтованому томі
    APP_PATH=""
    for app in "$MOUNT_POINT"/*.app; do
      if [ -d "$app" ]; then
        APP_PATH="$app"
        break
      fi
    done

    if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
      print_error "Не вдалося знайти додаток в змонтованому томі"
      # Спробуємо знайти будь-який додаток
      APP_PATH=$(find "$MOUNT_POINT" -name "*.app" -type d 2>/dev/null | head -1)
      if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
        print_error "Не знайдено жодного додатку"
        hdiutil detach "$MOUNT_POINT" -force || print_warning "Помилка відмонтування DMG"
        exit 1
      fi
    fi

    APP_NAME=$(basename "$APP_PATH")
    print_message "Знайдено додаток: $APP_NAME"

    # Копіювання в Applications
    print_message "Копіювання $APP_NAME в /Applications..."
    [ -d "/Applications/$APP_NAME" ] && rm -rf "/Applications/$APP_NAME"
    cp -R "$APP_PATH" /Applications/

    # Видалення з карантину
    print_message "Видалення з карантину..."
    xattr -rd com.apple.quarantine "/Applications/$APP_NAME" || print_warning "Помилка видалення з карантину"

    # Відмонтування DMG
    hdiutil detach "$MOUNT_POINT" -force || print_warning "Помилка відмонтування DMG"

    print_success "Встановлено в /Applications"
    open "/Applications/$APP_NAME" || print_warning "Помилка запуску додатку"
  elif [ "$OS_TYPE" = "linux" ]; then
    # Розшифрування файлу
    DEB_FILE="LogParser-$VERSION-linux.deb"
    if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$DEB_FILE" -k "$ENCRYPTION_KEY"; then
      print_error "Неправильний ключ або пошкоджений файл"
      exit 1
    fi

    # Перевірка наявності DEB файлу
    if [ ! -f "$DEB_FILE" ]; then
      print_error "DEB файл не знайдено після розшифрування"
      exit 1
    fi

    # Встановлення пакету
    print_message "Встановлення DEB пакету..."
    if ! sudo apt install -y "./$DEB_FILE"; then
      print_error "Помилка встановлення DEB пакету"
      exit 1
    fi

    print_success "Встановлено через apt"

  elif [ "$OS_TYPE" = "windows" ]; then
    # Розшифрування файлу
    EXE_FILE="LogParser-$VERSION-windows.exe"
    if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$EXE_FILE" -k "$ENCRYPTION_KEY"; then
      print_error "Неправильний ключ або пошкоджений файл"
      exit 1
    fi

    # Перевірка наявності EXE файлу
    if [ ! -f "$EXE_FILE" ]; then
      print_error "EXE файл не знайдено після розшифрування"
      exit 1
    fi

    # Копіювання на робочий стіл
    print_message "Копіювання на робочий стіл..."
    if ! cp "$EXE_FILE" "$HOME/Desktop/"; then
      print_error "Помилка копіювання на робочий стіл"
      exit 1
    fi

    print_success "Скопійовано на робочий стіл"
  fi

  cd / && rm -rf "$TEMP_DIR"
  print_success "Встановлення завершено!"
}

main



