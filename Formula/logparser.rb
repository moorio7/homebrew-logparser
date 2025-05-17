class Logparser < Formula
  desc "Аналізатор лог-файлів з підтримкою різних форматів, зручним інтерфейсом та покращеною роботою з DPI"
  homepage "https://github.com/moorio7/LogParser"

  # Використовуємо скрипт встановлення для зашифрованих файлів
  url "https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser.sh"
  sha256 "3400cd694fe92e698d7831a053477121a837feaab4ccae1e51bfcf69516fd47c"

  # Базова версія для сумісності з Homebrew
  # Примітка: Скрипт встановлення автоматично визначає останню версію
  version "0.4.25"

  # Залежності
  depends_on "p7zip"
  depends_on "openssl"
  depends_on "curl"
  depends_on "grep"

  # Формула призначена тільки для macOS
  depends_on :macos

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
    <<~EOS
      Для встановлення LogParser виконайте:
        install-logparser

      Якщо виникає помилка з дозволами, виконайте:
        chmod +x $(which install-logparser)

      Вам буде запропоновано ввести ключ для розшифрування файлу.
      Зверніться до розробника програми для отримання ключа.

      Примітка: Ця формула призначена тільки для macOS.
      Для Linux використовуйте окремий скрипт встановлення:
      https://github.com/moorio7/homebrew-logparser#для-linux-рекомендовано
    EOS
  end

  test do
    # Перевіряємо, чи скрипт встановлення існує
    assert_predicate bin/"install-logparser", :exist?

    # Перевіряємо, чи можемо знайти змонтовані томи
    system "ls", "-la", "/Volumes/"
  end
end




