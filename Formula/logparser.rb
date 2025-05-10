class Logparser < Formula
  desc "Аналізатор лог-файлів з підтримкою різних форматів, зручним інтерфейсом та покращеною роботою з DPI"
  homepage "https://github.com/moorio7/LogParser"
  version "0.4.24"

  # Використовуємо скрипт встановлення для зашифрованих файлів
  url "https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser.sh"
  sha256 "e4912ec7550c817c5bbdf1732c7f2248404d2d472126677304b068526f93145e"

  # Залежності
  depends_on "p7zip"
  depends_on "openssl"

  def install
    # Встановлюємо скрипт в bin
    bin.install "install-logparser.sh" => "install-logparser"

    # Встановлюємо права доступу на виконання
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
    EOS
  end

  test do
    # Перевіряємо, чи скрипт встановлення існує
    assert_predicate bin/"install-logparser", :exist?

    # Для macOS перевіряємо, чи можемо знайти змонтовані томи
    if OS.mac?
      system "ls", "-la", "/Volumes/"
    end
  end
end








