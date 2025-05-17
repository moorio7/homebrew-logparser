class Logparser < Formula
  desc "Аналізатор лог-файлів з підтримкою різних форматів, зручним інтерфейсом та покращеною роботою з DPI"
  homepage "https://github.com/moorio7/LogParser"

  # Використовуємо скрипт встановлення для зашифрованих файлів
  url "https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser.sh"
  sha256 "c414ed1bef1d8a730211b0f41c29bfc48b530685f8f4c0a7ce95eb4194e385d2"

  # Базова версія для сумісності з Homebrew
  # Примітка: Скрипт встановлення автоматично визначає останню версію
  version "0.4.25"

  # Залежності
  depends_on "p7zip"
  depends_on "openssl"
  depends_on "curl"
  depends_on "grep"

  # Визначення платформи
  on_linux do
    depends_on "apt"
  end

  def install
    # Встановлення зі скрипту
    bin.install "install-logparser.sh" => "install-logparser"
    chmod 0755, bin/"install-logparser"

    # Додаткова перевірка прав доступу
    system "ls", "-la", bin/"install-logparser"

    # Додаткове забезпечення прав доступу через систему
    system "chmod", "+x", bin/"install-logparser"
  end

  def caveats
    if OS.mac?
      <<~EOS
        Для встановлення LogParser виконайте:
          install-logparser

        Якщо виникає помилка з дозволами, виконайте:
          chmod +x $(which install-logparser)

        Вам буде запропоновано ввести ключ для розшифрування файлу.
        Зверніться до розробника програми для отримання ключа.

        Підтримувані платформи:
        - macOS (Intel та Apple Silicon)
        - Linux (Debian/Ubuntu)
        - Windows
      EOS
    else
      <<~EOS
        Для Linux рекомендується використовувати окремий скрипт встановлення:
          curl -L -o install-logparser-linux.sh https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser-linux.sh
          chmod +x install-logparser-linux.sh
          ./install-logparser-linux.sh

        Або ви можете використати стандартний скрипт:
          install-logparser

        Якщо виникає помилка з дозволами, виконайте:
          chmod +x $(which install-logparser)

        Вам буде запропоновано ввести ключ для розшифрування файлу.
        Зверніться до розробника програми для отримання ключа.

        Підтримувані платформи:
        - macOS (Intel та Apple Silicon)
        - Linux (Debian/Ubuntu)
        - Windows
      EOS
    end
  end

  test do
    # Перевіряємо, чи скрипт встановлення існує
    assert_predicate bin/"install-logparser", :exist?

    # Для macOS перевіряємо, чи можемо знайти змонтовані томи
    if OS.mac?
      system "ls", "-la", "/Volumes/"
    end

    # Для Linux перевіряємо наявність apt
    if OS.linux?
      system "which", "apt"
    end
  end
end



