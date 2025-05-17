#!/bin/bash
# Скрипт для автоматичного видалення LogParser з карантину на macOS
# Автор: Augment Agent
# Версія: 1.0
# Дата: 2024-10-15

# Встановлюємо кольори для виводу
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Шлях до програми
APP_PATH="/Applications/LogParser.app"
CUSTOM_APP_PATH=""

# Функція для виводу повідомлень
print_message() {
    echo -e "${BLUE}$1${NC}"
}

# Функція для виводу успішних повідомлень
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Функція для виводу попереджень
print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Функція для виводу помилок
print_error() {
    echo -e "${RED}$1${NC}"
}

# Перевірка наявності програми
check_app_exists() {
    if [ ! -d "$APP_PATH" ]; then
        print_warning "LogParser не знайдено в стандартній директорії (/Applications)"
        print_message "Шукаємо LogParser в інших місцях..."

        # Пошук програми в інших місцях
        FOUND_PATHS=$(find ~ -name 'LogParser.app' -type d 2>/dev/null)

        if [ -z "$FOUND_PATHS" ]; then
            print_error "LogParser не знайдено на вашому комп'ютері."
            print_message "Будь ласка, переконайтеся, що програма встановлена, або вкажіть шлях вручну:"
            print_message "Приклад: $0 /шлях/до/LogParser.app"
            exit 1
        else
            # Вибір першого знайденого шляху
            CUSTOM_APP_PATH=$(echo "$FOUND_PATHS" | head -n 1)
            print_success "Знайдено LogParser: $CUSTOM_APP_PATH"
            APP_PATH="$CUSTOM_APP_PATH"
        fi
    else
        print_success "LogParser знайдено в /Applications"
    fi
}

# Перевірка наявності атрибутів карантину
check_quarantine() {
    QUARANTINE_ATTR=$(xattr -l "$APP_PATH" | grep -i quarantine)

    if [ -z "$QUARANTINE_ATTR" ]; then
        print_success "LogParser не знаходиться в карантині. Додаткові дії не потрібні."
        return 1
    else
        print_warning "LogParser знаходиться в карантині:"
        echo "$QUARANTINE_ATTR"
        return 0
    fi
}

# Видалення атрибутів карантину
remove_quarantine() {
    print_message "Видаляємо атрибути карантину..."

    if [ "$EUID" -ne 0 ]; then
        print_warning "Для видалення атрибутів карантину потрібні права адміністратора."
        print_message "Запускаємо з sudo..."

        # Запуск з sudo - виконуємо всі три команди послідовно
        print_message "1. Видалення атрибутів карантину..."
        sudo xattr -rd com.apple.quarantine "$APP_PATH"
        RESULT1=$?

        print_message "2. Встановлення прав доступу для користувача..."
        sudo chmod -R u+rwX "$APP_PATH"
        RESULT2=$?

        print_message "3. Встановлення прав на виконання для бінарних файлів..."
        sudo chmod -R +x "$APP_PATH/Contents/MacOS/"*
        RESULT3=$?

        if [ $RESULT1 -eq 0 ] && [ $RESULT2 -eq 0 ] && [ $RESULT3 -eq 0 ]; then
            print_success "Всі команди успішно виконано!"
        else
            print_error "Виникли помилки при виконанні команд. Коди помилок: $RESULT1, $RESULT2, $RESULT3"
            print_message "Спробуйте виконати команди вручну з правами адміністратора:"
            print_message "sudo xattr -rd com.apple.quarantine \"$APP_PATH\""
            print_message "sudo chmod -R u+rwX \"$APP_PATH\""
            print_message "sudo chmod -R +x \"$APP_PATH/Contents/MacOS/\"*"
            exit 1
        fi
    else
        # Вже запущено з правами адміністратора
        print_message "1. Видалення атрибутів карантину..."
        xattr -rd com.apple.quarantine "$APP_PATH"
        RESULT1=$?

        print_message "2. Встановлення прав доступу для користувача..."
        chmod -R u+rwX "$APP_PATH"
        RESULT2=$?

        print_message "3. Встановлення прав на виконання для бінарних файлів..."
        chmod -R +x "$APP_PATH/Contents/MacOS/"*
        RESULT3=$?

        if [ $RESULT1 -eq 0 ] && [ $RESULT2 -eq 0 ] && [ $RESULT3 -eq 0 ]; then
            print_success "Всі команди успішно виконано!"
        else
            print_error "Виникли помилки при виконанні команд. Коди помилок: $RESULT1, $RESULT2, $RESULT3"
            exit 1
        fi
    fi
}

# Функція fix_permissions була об'єднана з remove_quarantine для послідовного виконання всіх команд

# Перевірка можливості запуску програми
check_launch() {
    print_message "Перевіряємо можливість запуску LogParser..."

    # Спроба запуску програми
    open "$APP_PATH" &
    PID=$!

    # Чекаємо 3 секунди
    sleep 3

    # Перевіряємо, чи процес все ще працює
    if ps -p $PID > /dev/null; then
        print_success "LogParser успішно запущено!"
        print_message "Закриваємо програму..."
        kill $PID
    else
        print_warning "Не вдалося автоматично перевірити запуск LogParser."
        print_message "Спробуйте запустити програму вручну."
    fi
}

# Головна функція
main() {
    # Перевірка аргументів командного рядка
    if [ $# -eq 1 ]; then
        if [ -d "$1" ]; then
            APP_PATH="$1"
            print_message "Використовуємо вказаний шлях: $APP_PATH"
        else
            print_error "Вказаний шлях не існує: $1"
            exit 1
        fi
    fi

    print_message "=== Утиліта для видалення LogParser з карантину на macOS ==="
    print_message "Версія: 1.0"
    print_message "Дата: 2024-10-15"
    print_message "========================================================"

    # Перевірка наявності програми
    check_app_exists

    # Перевірка наявності атрибутів карантину
    check_quarantine
    QUARANTINE_STATUS=$?

    if [ $QUARANTINE_STATUS -eq 0 ]; then
        # Видалення атрибутів карантину та виправлення прав доступу
        remove_quarantine

        # Перевірка можливості запуску програми
        check_launch

        print_success "Всі операції завершено успішно!"
        print_message "Тепер ви можете запустити LogParser без обмежень."
    fi

    exit 0
}

# Запуск головної функції
main "$@"
