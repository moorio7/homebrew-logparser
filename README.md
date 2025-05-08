<meta name="robots" content="noindex, nofollow">
<meta name="googlebot" content="noindex, nofollow">
<meta name="bingbot" content="noindex, nofollow">
<meta name="slurp" content="noindex, nofollow">
<meta name="duckduckbot" content="noindex, nofollow">
<meta name="baiduspider" content="noindex, nofollow">
<meta name="yandexbot" content="noindex, nofollow">
<meta name="sogou" content="noindex, nofollow">
<meta name="ia_archiver" content="noindex, nofollow">

# Homebrew Tap for LogParser

Цей репозиторій містить Homebrew формулу для встановлення [LogParser](https://github.com/moorio7/LogParser) - програми для аналізу та перегляду лог-файлів з підтримкою різних форматів та зручним інтерфейсом.

> **Примітка**: Homebrew підтримує лише macOS. Для Windows використовуйте захищений ZIP-архів (див. Варіант 2).

## Встановлення

<details open>
<summary><b>🍎 Варіант 1: Встановлення через Homebrew (рекомендовано для macOS)</b></summary>

<table>
<tr>
<td>1️⃣</td>
<td>Встановіть Homebrew, якщо він ще не встановлений:
<pre><code>/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"</code></pre>
</td>
</tr>
<tr>
<td>2️⃣</td>
<td>Додайте tap для LogParser:
<pre><code>brew tap moorio7/logparser</code></pre>
</td>
</tr>
<tr>
<td>3️⃣</td>
<td>Встановіть LogParser:
<pre><code>brew install logparser</code></pre>
</td>
</tr>
<tr>
<td>4️⃣</td>
<td>Запустіть скрипт встановлення:
<pre><code>install-logparser</code></pre>
</td>
</tr>
<tr>
<td>5️⃣</td>
<td>
<b>⚠️ ВАЖЛИВО</b>: Для розпакування архіву вам знадобиться пароль. Зверніться до розробника для отримання пароля.
</td>
</tr>
</table>

<details>
<summary><b>🔄 Оновлення LogParser</b></summary>

<table>
<tr>
<td>1️⃣</td>
<td>Оновіть Homebrew:
<pre><code>brew update</code></pre>
</td>
</tr>
<tr>
<td>2️⃣</td>
<td>Оновіть LogParser:
<pre><code>brew upgrade logparser</code></pre>
</td>
</tr>
<tr>
<td>3️⃣</td>
<td>Запустіть скрипт встановлення:
<pre><code>install-logparser</code></pre>
</td>
</tr>
</table>
</details>

<details>
<summary><b>🔧 Перевстановлення LogParser</b></summary>

<table>
<tr>
<td>1️⃣</td>
<td>Перевстановіть LogParser:
<pre><code>brew reinstall logparser</code></pre>
</td>
</tr>
<tr>
<td>2️⃣</td>
<td>Запустіть скрипт встановлення:
<pre><code>install-logparser</code></pre>
</td>
</tr>
</table>
</details>

<details>
<summary><b>🛠️ Вирішення проблем з встановленням</b></summary>

<details>
<summary><b>🗑️ Проблеми з кешем Homebrew</b></summary>

Очистити кеш Homebrew:

```bash
brew cleanup
```

```bash
brew cleanup --prune=all
```

Оновити Homebrew та формули:

```bash
brew update
```

```bash
brew update-reset
```
</details>

<details>
<summary><b>🔑 Проблеми з хешами</b></summary>

Якщо виникає помилка "SHA256 mismatch":

Очистити кеш завантажень:

```bash
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
```

Оновити формулу:

```bash
brew update
```

Перевстановити:

```bash
brew reinstall logparser
```
</details>

<details>
<summary><b>🔒 Проблеми з правами доступу</b></summary>

Якщо виникають проблеми з правами доступу:

Виправити права доступу для Homebrew:

```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```

Перевстановити формулу:

```bash
brew reinstall logparser
```
</details>

<details>
<summary><b>🧹 Повне скидання Homebrew</b></summary>

Для повного скидання та перевстановлення:

1. Видалити всі кешовані файли LogParser:
```bash
rm -rf "$(brew --cache)/downloads/moorio7-logparser-*"
```

2. Очистити кеш Homebrew:
```bash
brew cleanup --prune=all
```

3. Оновити Homebrew:
```bash
brew update
```

4. Видалити формулу LogParser:
```bash
brew uninstall logparser
```

5. Видалити теп репозиторію:
```bash
brew untap moorio7/logparser
```

6. Додати теп знову:
```bash
brew tap moorio7/logparser
```

7. Встановити LogParser заново:
```bash
brew install moorio7/logparser/logparser
```

8. Запустити скрипт встановлення:
```bash
install-logparser
```
</details>
</details>

<details>
<summary><b>🗑️ Видалення LogParser</b></summary>

Для видалення LogParser:

```bash
brew uninstall logparser
```

Для видалення tap:

```bash
brew untap moorio7/logparser
```
</details>
</details>

<details>
<summary><b>🪟 Варіант 2: Встановлення через захищений ZIP-архів (Windows)</b></summary>

<table>
<tr>
<td>1️⃣</td>
<td>Завантажте захищений ZIP-архів з останнього релізу:
<pre><code>https://github.com/moorio7/homebrew-logparser/releases/download/vX.Y.Z/LogParser-X.Y.Z-windows.zip</code></pre>
<i>(Замініть X.Y.Z на актуальну версію, наприклад 0.4.23)</i>
</td>
</tr>
<tr>
<td>2️⃣</td>
<td>Розпакуйте архів за допомогою 7-Zip або іншого архіватора, який підтримує захищені паролем архіви.</td>
</tr>
<tr>
<td>3️⃣</td>
<td>При запиті пароля введіть ENCRYPTION_KEY (зверніться до розробника для отримання ключа).</td>
</tr>
<tr>
<td>4️⃣</td>
<td>Після розпакування ви отримаєте виконуваний EXE-файл, який можна скопіювати на робочий стіл або запустити безпосередньо.</td>
</tr>
</table>

<details>
<summary><b>📋 Вимоги для Windows</b></summary>

- Для розпакування архіву потрібен 7-Zip або інший архіватор, який підтримує захищені паролем ZIP-архіви.
- Windows 7/8/10/11 (32 або 64-біт)
</details>
</details>

<details open>
<summary><b>💻 Підтримувані платформи</b></summary>

<table>
<tr>
<td>🍎</td>
<td>macOS (Intel та Apple Silicon)</td>
</tr>
<tr>
<td>🪟</td>
<td>Windows</td>
</tr>
</table>
</details>

<details open>
<summary><b>✨ Особливості</b></summary>

<table>
<tr>
<td>📊</td>
<td>Аналіз та перегляд лог-файлів різних форматів</td>
</tr>
<tr>
<td>🖥️</td>
<td>Зручний інтерфейс користувача</td>
</tr>
<tr>
<td>🔍</td>
<td>Фільтрація та пошук у логах</td>
</tr>
<tr>
<td>🎨</td>
<td>Підсвічування синтаксису</td>
</tr>
<tr>
<td>📱</td>
<td>Покращена робота з DPI</td>
</tr>
</table>
</details>

<details open>
<summary><b>🔐 Безпека</b></summary>

<table>
<tr>
<td>🛡️</td>
<td>Програма розповсюджується у вигляді захищених файлів для захисту інтелектуальної власності.</td>
</tr>
<tr>
<td>🔑</td>
<td>Для отримання ключа для розшифрування файлів або розпакування архівів зверніться до розробника програми.</td>
</tr>
<tr>
<td>🔒</td>
<td>Для macOS використовується шифрування AES-256, а для Windows - захищені паролем ZIP-архіви.</td>
</tr>
<tr>
<td>✅</td>
<td>Для перевірки цілісності файлів використовуються SHA-256 хеші.</td>
</tr>
</table>
</details>

<details open>
<summary><b>📜 Ліцензія</b></summary>

<table>
<tr>
<td>©️</td>
<td>Всі права захищені. Несанкціоноване копіювання, розповсюдження або модифікація програми заборонені.</td>
</tr>
</table>
</details>
