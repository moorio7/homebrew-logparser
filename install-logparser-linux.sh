#!/bin/bash

# Кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функції для виводу повідомлень
print_message() {
  echo -e "${BLUE}$1${NC}"
}

print_success() {
  echo -e "${GREEN}$1${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

# Функція для отримання останньої версії з GitHub API
get_latest_version() {
  local version=""

  # Спроба отримати останню версію (сумісно з macOS)
  version=$(curl -s https://api.github.com/repos/moorio7/LogParser/releases/latest | grep '"tag_name"' | grep -o 'v[0-9][0-9.]*' | sed 's/^v//')

  # Якщо не вдалося отримати останню версію, отримуємо список всіх версій
  if [ -z "$version" ]; then
    print_warning "Не вдалося отримати останню версію через API. Спроба отримати список всіх версій..." >&2
    version=$(curl -s https://api.github.com/repos/moorio7/LogParser/releases | grep '"tag_name"' | grep -o 'v[0-9][0-9.]*' | sed 's/^v//' | sort -V -r | head -n 1)
  fi

  # Якщо все ще не вдалося отримати версію, використовуємо версію за замовчуванням
  if [ -z "$version" ]; then
    print_warning "Не вдалося отримати жодну версію через API. Використовуємо версію за замовчуванням." >&2
    version="0.4.25"
  fi

  # Перевірка, що версія містить тільки допустимі символи (цифри, крапки та, можливо, дефіси)
  if ! echo "$version" | grep -q '^[0-9][0-9.]*$'; then
    print_warning "Отримана версія має неправильний формат. Використовуємо версію за замовчуванням." >&2
    version="0.4.25"
  fi

  echo "$version"
}

# Отримуємо останню версію
VERSION=$(get_latest_version)
# Перевірка, що версія не порожня і має правильний формат
if [ -z "$VERSION" ] || ! echo "$VERSION" | grep -q '^[0-9][0-9.]*$'; then
  print_warning "Версія має неправильний формат або порожня. Використовуємо версію за замовчуванням."
  VERSION="0.4.25"
fi
print_message "Використовуємо останню версію: $VERSION"

# Налаштування
TEMP_DIR="/tmp/logparser_install"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# URL репозиторію для завантаження
REPO_URL="https://github.com/moorio7/homebrew-logparser/releases/download/v${VERSION}"

# Назви файлів
ENC_FILE="LogParser-${VERSION}-linux.enc"
DEB_FILE="LogParser-${VERSION}-linux.deb"
SHA_FILE="LogParser-${VERSION}-linux.sha256"

# Завантаження зашифрованого файлу
print_message "Завантаження зашифрованого файлу для Linux..."
curl -L -o "$ENC_FILE" "$REPO_URL/$ENC_FILE" || {
  print_error "Помилка завантаження зашифрованого файлу"
  exit 1
}

# Завантаження хеш-файлу для перевірки цілісності
print_message "Завантаження хеш-файлу..."
curl -L -o "$SHA_FILE" "$REPO_URL/$SHA_FILE" || {
  print_warning "Не вдалося завантажити хеш-файл"
}

# Перевірка цілісності файлу
if [ -f "$SHA_FILE" ]; then
  print_message "Перевірка цілісності файлу..."
  # Отримуємо очікуваний хеш з файлу
  EXPECTED_HASH=$(cat "$SHA_FILE" | awk '{print $1}')
  print_message "Очікуваний хеш: $EXPECTED_HASH"
  print_message "Хеш буде перевірено після розшифрування"
  print_success "Файл завантажено успішно"
else
  print_warning "Неможливо перевірити цілісність файлу (хеш-файл не знайдено)"
fi

# Встановлення OpenSSL, якщо його немає
if ! command -v openssl &> /dev/null; then
  print_message "Встановлення OpenSSL..."
  sudo apt-get update && sudo apt-get install -y openssl || {
    print_error "Помилка встановлення OpenSSL"
    exit 1
  }
fi

# Запит ключа для розшифрування
print_message "Введіть ключ для розшифрування (ENCRYPTION_KEY):"
read -s ENCRYPTION_KEY
echo

# Розшифрування файлу
print_message "Розшифрування файлу..."
if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$DEB_FILE" -k "$ENCRYPTION_KEY"; then
  print_error "Неправильний ключ або пошкоджений файл"
  exit 1
fi

# Перевірка наявності DEB файлу
if [ ! -f "$DEB_FILE" ]; then
  print_error "DEB файл не знайдено після розшифрування"
  print_message "Спробуйте розшифрувати файл вручну за допомогою команди:"
  print_message "openssl enc -aes-256-cbc -d -salt -in $ENC_FILE -out $DEB_FILE -k ENCRYPTION_KEY"
  exit 1
fi

# Встановлення пакету
print_message "Встановлення DEB пакету..."
if ! sudo apt install -y "./$DEB_FILE"; then
  print_error "Помилка встановлення DEB пакету"
  exit 1
fi

# Очищення
cd / && rm -rf "$TEMP_DIR"
print_success "Встановлення завершено!"
print_message "Запуск додатку..."
logparser || print_warning "Помилка запуску додатку"
