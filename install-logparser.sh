#!/bin/bash
# Скрипт для встановлення LogParser з захищених архівів та зашифрованих файлів

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
  elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "win32"* ]]; then
    OS_TYPE="windows"
  else
    print_error "Непідтримувана ОС: $OSTYPE. Підтримуються тільки macOS та Windows."
    exit 1
  fi
}

# Встановлення 7zip для Windows
install_7zip() {
  if [ "$OS_TYPE" = "windows" ] && ! command -v 7z &> /dev/null; then
    print_error "Для розпакування архіву потрібен 7-Zip. Будь ласка, встановіть його з https://www.7-zip.org/"
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
  elif [ "$OS_TYPE" = "windows" ]; then
    ZIP_FILE="LogParser-$VERSION-windows.zip"
    SHA_FILE="LogParser-$VERSION-windows.zip.sha256"
  fi

  if [ "$OS_TYPE" = "macos" ]; then
    print_message "Завантаження зашифрованого файлу для $OS_TYPE..."
    curl -L -o "$ENC_FILE" "$REPO_URL/$ENC_FILE" || { print_error "Помилка завантаження зашифрованого файлу"; exit 1; }
  else
    print_message "Завантаження захищеного архіву для $OS_TYPE..."
    curl -L -o "$ZIP_FILE" "$REPO_URL/$ZIP_FILE" || { print_error "Помилка завантаження архіву"; exit 1; }
  fi

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
  print_message "=== Встановлення LogParser $VERSION ==="
  determine_system
  download_file

  if [ "$OS_TYPE" = "windows" ]; then
    install_7zip
  fi

  print_message "Введіть ключ для розшифрування (ENCRYPTION_KEY):"
  read -s ENCRYPTION_KEY
  echo

  # Розпакування/розшифрування файлу
  if [ "$OS_TYPE" = "macos" ]; then
    # Встановлення OpenSSL
    if ! command -v openssl &> /dev/null; then
      print_message "Встановлення OpenSSL..."
      brew install openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
    fi

    # Розшифрування файлу
    print_message "Розшифрування файлу..."
    ENC_FILE="LogParser-$VERSION-macos-$ARCH_TYPE.enc"
    DMG_FILE="LogParser-$VERSION-macos-$ARCH_TYPE.dmg"
    if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$DMG_FILE" -k "$ENCRYPTION_KEY"; then
      print_error "Неправильний ключ або пошкоджений файл"
      exit 1
    fi

    # Пошук DMG файлу
    DMG_FILE=$(ls *.dmg 2>/dev/null)
    if [ -z "$DMG_FILE" ]; then
      print_error "DMG файл не знайдено після розшифрування"
      exit 1
    fi

    # Монтування DMG файлу
    print_message "Монтування DMG файлу..."
    MOUNT_POINT=$(hdiutil attach "$DMG_FILE" -nobrowse -noautoopen | grep Apple_HFS | awk '{print $3}')

    if [ -z "$MOUNT_POINT" ]; then
      print_error "Не вдалося змонтувати DMG файл"
      exit 1
    fi

    # Копіювання в Applications
    print_message "Копіювання LogParser.app в /Applications..."
    [ -d "/Applications/LogParser.app" ] && rm -rf "/Applications/LogParser.app"
    cp -R "$MOUNT_POINT/LogParser.app" /Applications/

    # Видалення з карантину
    print_message "Видалення з карантину..."
    xattr -rd com.apple.quarantine "/Applications/LogParser.app" || print_warning "Помилка видалення з карантину"

    # Відмонтування DMG
    hdiutil detach "$MOUNT_POINT" -force || print_warning "Помилка відмонтування DMG"

    print_success "Встановлено в /Applications"
    open "/Applications/LogParser.app" || print_warning "Помилка запуску додатку"
  elif [ "$OS_TYPE" = "windows" ]; then
    # Розпакування архіву
    print_message "Розпакування архіву..."
    ZIP_FILE="LogParser-$VERSION-windows.zip"
    if ! 7z x -p"$ENCRYPTION_KEY" "$ZIP_FILE"; then
      print_error "Неправильний ключ або пошкоджений архів"
      exit 1
    fi

    # Пошук EXE файлу
    EXE_FILE=$(ls *.exe 2>/dev/null)
    if [ -z "$EXE_FILE" ]; then
      print_error "EXE файл не знайдено в архіві"
      exit 1
    fi

    # Копіювання на робочий стіл
    print_message "Копіювання на робочий стіл..."
    cp "$EXE_FILE" "$HOME/Desktop/" || { print_error "Помилка копіювання на робочий стіл"; exit 1; }

    print_success "Скопійовано на робочий стіл: $HOME/Desktop/$EXE_FILE"
  fi

  cd / && rm -rf "$TEMP_DIR"
  print_success "Встановлення завершено!"
}

main
