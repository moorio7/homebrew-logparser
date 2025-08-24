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

# Запит так/ні
prompt_yes_no() {
  local prompt="$1"
  while true; do
    read -r -p "$prompt [y/n]: " ans || true
    case "${ans,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
    esac
  done
}

# Визначення пакетного менеджера
detect_pkgmgr() {
  if command -v apt-get >/dev/null 2>&1; then echo apt; return; fi
  if command -v dnf >/dev/null 2>&1; then echo dnf; return; fi
  if command -v pacman >/dev/null 2>&1; then echo pacman; return; fi
  if command -v zypper >/dev/null 2>&1; then echo zypper; return; fi
  echo unknown
}

# Вибір завантажувача: за замовчуванням запитаємо, дефолт — wget, фолбек — curl
DOWNLOADER="ask"  # ask|wget|curl (можна задати прапорцями)

# Стійкі опції для завантаження
CURL_OPTS="-L --http1.1 --retry 10 --retry-all-errors -C -"
WGET_OPTS="-c --tries=20 --waitretry=5 --read-timeout=30"

choose_downloader_if_needed() {
  if [ "$DOWNLOADER" = "ask" ]; then
    local def="wget"
    command -v wget >/dev/null 2>&1 || def="curl"
    printf "Обрати завантажувач [wget/curl] (за замовчуванням: %s): " "$def"
    read -r ans || true
    case "${ans,,}" in
      wget|w) DOWNLOADER="wget" ;;
      curl|c) DOWNLOADER="curl" ;;
      "") DOWNLOADER="$def" ;;
      *) DOWNLOADER="$def" ;;
    esac
  fi

  if [ "$DOWNLOADER" = "wget" ] && ! command -v wget >/dev/null 2>&1; then
    print_warning "wget не знайдено, використовуємо curl"
    DOWNLOADER="curl"
  fi
  if [ "$DOWNLOADER" = "curl" ] && ! command -v curl >/dev/null 2>&1; then
    print_warning "curl не знайдено, спробуємо wget"
    if command -v wget >/dev/null 2>&1; then
      DOWNLOADER="wget"
    else
      print_error "Не знайдено ні curl, ні wget. Встановіть один із них та повторіть."
      exit 1
    fi
  fi
}

download_file() {
  # download_file URL OUT_PATH
  local url="$1" out="$2"
  case "$DOWNLOADER" in
    wget)
      wget $WGET_OPTS -O "$out" "$url" ;;
    curl|*)
      curl $CURL_OPTS -o "$out" "$url" ;;
  esac
}

install_openssl_if_needed() {
  if command -v openssl >/dev/null 2>&1; then return; fi
  print_message "Встановлення OpenSSL..."
  local pmgr
  pmgr=$(detect_pkgmgr)
  case "$pmgr" in
    apt)
      sudo apt-get update && sudo apt-get install -y openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
      ;;
    dnf)
      sudo dnf install -y openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
      ;;
    pacman)
      sudo pacman -Syu --noconfirm && sudo pacman -S --noconfirm openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
      ;;
    zypper)
      sudo zypper -n install openssl || { print_error "Помилка встановлення OpenSSL"; exit 1; }
      ;;
    *)
      print_warning "Невідомий пакетний менеджер. Переконайтесь, що OpenSSL встановлено."
      ;;
  esac
}

install_fuse2_if_needed() {
  # Для AppImage може знадобитись FUSE 2
  if ldconfig -p 2>/dev/null | grep -q 'libfuse\\.so\\.2'; then return; fi
  local pmgr
  pmgr=$(detect_pkgmgr)
  case "$pmgr" in
    apt)
      sudo apt-get update -y
      sudo apt-get install -y libfuse2 || sudo apt-get install -y fuse || true
      ;;
    dnf)
      sudo dnf install -y fuse || sudo dnf install -y fuse-libs || true
      ;;
    pacman)
      sudo pacman -Syu --noconfirm
      sudo pacman -S --noconfirm fuse2 || true
      ;;
    zypper)
      sudo zypper -n install fuse || sudo zypper -n install fuse2 || true
      ;;
    *)
      print_warning "Не вдалося автоматично встановити FUSE2. За потреби використайте APPIMAGE_EXTRACT_AND_RUN=1."
      ;;
  esac
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

# Опції для curl: редіректи, HTTP/1.1, ретраї, докачка
CURL_OPTS="-L --http1.1 --retry 10 --retry-all-errors -C -"

# Визначаємо пакетний менеджер
PMGR=$(detect_pkgmgr)

# Режим встановлення: auto|deb|appimage (можна задати LOGPARSER_MODE або ключами)
MODE="auto"
for arg in "$@"; do
  case "$arg" in
    --deb) MODE="deb" ;;
    --appimage) MODE="appimage" ;;
    --auto) MODE="auto" ;;
    --wget) DOWNLOADER="wget" ;;
    --curl) DOWNLOADER="curl" ;;
    --downloader=*) DOWNLOADER="${arg#*=}" ;;
  esac
done
[ -n "${LOGPARSER_MODE:-}" ] && MODE="$LOGPARSER_MODE"

# Інтерактивний вибір, якщо auto
if [ "$MODE" = "auto" ]; then
  if [ "$PMGR" = "apt" ]; then
    if prompt_yes_no "Встановити у форматі DEB через apt? (інакше AppImage)"; then
      MODE="deb"
    else
      MODE="appimage"
    fi
  else
    # На не-apt дистрибутивах пропонуємо AppImage; за бажанням можна примусити deb
    if prompt_yes_no "Цей дистрибутив не Debian/Ubuntu. Використати AppImage? (інакше спробувати DEB, може не спрацювати)"; then
      MODE="appimage"
    else
      MODE="deb"
    fi
  fi
fi

if [ "$MODE" = "deb" ]; then
  ENC_FILE="LogParser-${VERSION}-linux.enc"
  OUT_FILE="LogParser-${VERSION}-linux.deb"
  SHA_FILE="LogParser-${VERSION}-linux.sha256"
else
  ENC_FILE="LogParser-${VERSION}-appimage.enc"
  OUT_FILE="LogParser-${VERSION}-x86_64.AppImage"
  SHA_FILE="LogParser-${VERSION}-appimage.sha256"
fi

# Вибір завантажувача (інтерактивно, якщо не задано через прапорці/змінні)
choose_downloader_if_needed

# Завантаження зашифрованого файлу
print_message "Завантаження зашифрованого файлу: $ENC_FILE"
if ! download_file "$REPO_URL/$ENC_FILE" "$ENC_FILE"; then
  if [ "$MODE" = "appimage" ]; then
    # Fallback: спробувати DEB, якщо AppImage відсутній
    print_warning "AppImage недоступний для цієї версії, пробуємо DEB..."
    MODE="deb"
    ENC_FILE="LogParser-${VERSION}-linux.enc"
    OUT_FILE="LogParser-${VERSION}-linux.deb"
    SHA_FILE="LogParser-${VERSION}-linux.sha256"
    download_file "$REPO_URL/$ENC_FILE" "$ENC_FILE" || { print_error "Не вдалося завантажити жоден артефакт"; exit 1; }
  else
    print_error "Помилка завантаження зашифрованого файлу"
    exit 1
  fi
fi

# Завантаження хеш-файлу для перевірки цілісності (опційно)
print_message "Завантаження хеш-файлу: $SHA_FILE"
download_file "$REPO_URL/$SHA_FILE" "$SHA_FILE" || print_warning "Не вдалося завантажити хеш-файл"

if [ -f "$SHA_FILE" ]; then
  print_message "Хеш буде перевірено після розшифрування"
  EXPECTED_HASH=$(awk '{print $1}' "$SHA_FILE")
fi

# Встановлення OpenSSL, якщо його немає
install_openssl_if_needed

# Запит ключа для розшифрування
print_message "Введіть ключ для розшифрування (ENCRYPTION_KEY):"
read -s ENCRYPTION_KEY
echo

# Розшифрування файлу
print_message "Розшифрування файлу в $OUT_FILE..."
if ! openssl enc -aes-256-cbc -d -salt -in "$ENC_FILE" -out "$OUT_FILE" -k "$ENCRYPTION_KEY"; then
  print_error "Неправильний ключ або пошкоджений файл"
  exit 1
fi

# Перевірка наявності вихідного файлу
if [ ! -f "$OUT_FILE" ]; then
  print_error "Файл $OUT_FILE не знайдено після розшифрування"
  exit 1
fi

# Перевірка хешу (якщо доступний)
if [ -n "${EXPECTED_HASH:-}" ]; then
  ACTUAL_HASH=$(sha256sum "$OUT_FILE" | awk '{print $1}')
  if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
    print_warning "Хеш не збігається. Очікувано: $EXPECTED_HASH, отримано: $ACTUAL_HASH"
  else
    print_success "Перевірка хешу пройдена"
  fi
fi

# Встановлення
if [ "$MODE" = "deb" ]; then
  if [ "$PMGR" != "apt" ]; then
    print_error "DEB не підтримується цим дистрибутивом без конвертації. Використайте AppImage або дистрибутив Debian/Ubuntu."
    exit 1
  fi
  print_message "Встановлення DEB пакету..."
  if ! sudo apt install -y "./$OUT_FILE"; then
    print_error "Помилка встановлення DEB пакету"
    exit 1
  fi
  print_success "Встановлення завершено!";
  print_message "Запуск додатку..."
  logparser || print_warning "Помилка запуску додатку"
else
  print_message "Встановлення AppImage..."
  install_fuse2_if_needed
  APP_DIR="$HOME/Applications"
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$APP_DIR" "$BIN_DIR"
  cp "$OUT_FILE" "$APP_DIR/LogParser.AppImage"
  chmod +x "$APP_DIR/LogParser.AppImage"
  # Створюємо зручний ярлик у PATH
  ln -sf "$APP_DIR/LogParser.AppImage" "$BIN_DIR/logparser" || cp "$APP_DIR/LogParser.AppImage" "$BIN_DIR/logparser"
  chmod +x "$BIN_DIR/logparser" || true
  print_success "AppImage встановлено: $APP_DIR/LogParser.AppImage"
  print_message "Запуск: $BIN_DIR/logparser"
  "$BIN_DIR/logparser" || print_warning "Не вдалося запустити AppImage"

  # Додати ярлик у меню?
  if prompt_yes_no "Додати ярлик у меню програм?"; then
    APPS_DIR="$HOME/.local/share/applications"
    ICONS_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
    mkdir -p "$APPS_DIR" "$ICONS_DIR"
    # Завантажуємо іконку (невеликий файл)
    ICON_URL="https://raw.githubusercontent.com/moorio7/LogParser/main/icon/icon.png"
    if [ "$DOWNLOADER" = "wget" ]; then
      wget -q -O "$ICONS_DIR/logparser.png" "$ICON_URL" || true
    else
      curl -sS -L -o "$ICONS_DIR/logparser.png" "$ICON_URL" || true
    fi
    DESKTOP_FILE="$APPS_DIR/logparser.desktop"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=LogParser
Comment=Аналізатор лог-файлів
Exec=$APP_DIR/LogParser.AppImage
Icon=logparser
Terminal=false
Type=Application
Categories=Utility;Development;
StartupNotify=true
EOF
    chmod +x "$DESKTOP_FILE" || true
    command -v update-desktop-database >/dev/null && update-desktop-database || true
    command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -f ~/.local/share/icons/hicolor || true
    print_success "Ярлик у меню додано"
  fi

  # Додати ярлик на робочий стіл?
  if prompt_yes_no "Додати ярлик на робочий стіл?"; then
    DESKTOP_DIR="$HOME/Desktop"
    mkdir -p "$DESKTOP_DIR"
    cp "$HOME/.local/share/applications/logparser.desktop" "$DESKTOP_DIR/LogParser.desktop" 2>/dev/null || {
      # Якщо ще не створено у меню, створимо напряму
      cat > "$DESKTOP_DIR/LogParser.desktop" <<EOF
[Desktop Entry]
Name=LogParser
Comment=Аналізатор лог-файлів
Exec=$APP_DIR/LogParser.AppImage
Icon=$HOME/.local/share/icons/hicolor/256x256/apps/logparser.png
Terminal=false
Type=Application
Categories=Utility;Development;
StartupNotify=true
EOF
    }
    chmod +x "$DESKTOP_DIR/LogParser.desktop" || true
    print_success "Ярлик на робочому столі додано"
  fi
fi

# Очищення
cd / && rm -rf "$TEMP_DIR"
