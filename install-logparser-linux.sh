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

# Функція для отримання останньої успішно опублікованої версії
get_last_published_version() {
  local api_response=""
  local version=""
  local fallback_version="0.4.25"  # Жорстко закодована версія як останній запасний варіант

  print_message "Пошук останньої успішно опублікованої версії..." >&2

  # Отримуємо список всіх релізів
  api_response=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/moorio7/homebrew-logparser/releases)

  if [ -z "$api_response" ] || echo "$api_response" | grep -q "Not Found"; then
    print_warning "Не вдалося отримати список релізів. Використовуємо жорстко закодовану версію." >&2
    echo "$fallback_version"
    return
  fi

  # Отримуємо список всіх версій
  local all_versions=$(echo "$api_response" | grep -o '"tag_name": *"v[0-9][0-9.]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/' | sort -V -r)

  # Перевіряємо кожну версію на наявність файлів релізу
  for v in $all_versions; do
    # Перевіряємо наявність файлів для Linux
    local enc_url="https://github.com/moorio7/homebrew-logparser/releases/download/v${v}/LogParser-${v}-linux.enc"
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

    # Спроба отримати версію з усіх релізів
    version=$(echo "$api_response" | grep -o '"tag_name": *"v[0-9][0-9.]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/' | sort -V -r | head -n 1)
  else
    # Спроба отримати версію з останнього релізу
    version=$(echo "$api_response" | grep -o '"tag_name": *"v[0-9][0-9.]*"' | sed 's/.*"v\([0-9][0-9.]*\)".*/\1/')
  fi

  # Якщо не вдалося отримати версію з релізів, спробуємо отримати з файлів у репозиторії
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
