class Logparser < Formula
  desc "Аналізатор лог-файлів з підтримкою різних форматів та зручним інтерфейсом"
  homepage "https://github.com/moorio7/LogParser"
  version "0.4.22"

  # Використовуємо скрипт встановлення для зашифрованих файлів
  url "https://raw.githubusercontent.com/moorio7/homebrew-logparser/master/install-logparser.sh"
  sha256 "ac47ea372c2848e817b317b60781a745ddc5bda1ae7aac062492276654382600"

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








