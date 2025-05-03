class Logparser < Formula
  desc "Аналізатор лог-файлів з підтримкою різних форматів та зручним інтерфейсом"
  homepage "https://github.com/moorio7/LogParser"
  version "0.4.20"

  # Використовуємо скрипт встановлення для зашифрованих файлів
  url "https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser.sh"
  sha256 "f26f490ce34e26496467ea14022954979dbdbb74e4e8e73477d45ac58c574e67"

  # Залежності
  depends_on "p7zip"
  depends_on "openssl"

  def install
    # Встановлюємо скрипт в bin
    bin.install "install-logparser.sh" => "install-logparser"
    chmod 0755, bin/"install-logparser"
  end

  def caveats
    <<~EOS
      Для встановлення LogParser виконайте:
        install-logparser

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
