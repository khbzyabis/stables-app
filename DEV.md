# Running My Stables locally (macOS)

A fresh-Mac setup to run the app locally with hot reload, work with Claude
Code, and push changes (Vercel auto-deploys on push).

The app's Supabase URL + public key are baked into the code, so a local run
talks to the **same live database and accounts** — no extra config.

## 1. Xcode command-line tools (git, compilers)

```sh
xcode-select --install
```

Click through the installer if it pops up.

## 2. Homebrew (the macOS package manager)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After it finishes, follow the "Next steps" it prints (it tells you to run two
`echo ... >> ~/.zprofile` lines and `eval "$(/opt/homebrew/bin/brew shellenv)"`).
Then check it works:

```sh
brew --version
```

## 3. Install the tools

```sh
brew install git gh node
brew install --cask flutter google-chrome
```

- `git` / `gh` — version control + GitHub login
- `node` — needed by Claude Code
- `flutter` — the app's framework (includes Dart)
- `google-chrome` — what the app runs in locally

Verify Flutter:

```sh
flutter doctor
```

Green checks for "Flutter" and "Chrome" are all you need for web dev. Ignore
Android/iOS/Xcode warnings unless you later build mobile apps.

## 4. Sign in to GitHub and clone the repo

```sh
gh auth login
```

Choose: GitHub.com → HTTPS → "Login with a web browser", paste the code.

Then clone and switch to the working branch:

```sh
cd ~
gh repo clone khbzyabis/stables-app
cd stables-app
git checkout claude/read-this-h7d4dr
```

## 5. Run the app with hot reload

```sh
flutter pub get
flutter run -d chrome
```

Chrome opens with the app. Now the fast loop:

- Edit any `.dart` file and **save** (or press `r` in the terminal) → the UI
  updates in about a second. No rebuild, no deploy.
- Press `R` for a full restart, `q` to quit.

To preview a specific portal, open the URL Chrome shows plus the path:
`/` (rider), `/sell` (seller), `/admin` (operator).

## 6. Install Claude Code (to work with Claude on your machine)

```sh
npm install -g @anthropic-ai/claude-code
cd ~/stables-app
claude
```

Follow the login prompt the first time.

## The workflow with Claude (remote)

Claude (the cloud session) edits the code and pushes to
`claude/read-this-h7d4dr`. To see those changes locally:

```sh
git pull
```

then press `r` in the running `flutter run` terminal.

## Alternative: run it in Docker (no Flutter on your Mac)

Keeps Flutter/Dart and all build deps inside a container. You only need Docker
Desktop, plus git to get the code.

1. Install **Docker Desktop for Mac**: https://www.docker.com/products/docker-desktop/
   (open it once so the engine is running).
2. Get the code (needs git — from `xcode-select --install`, and gh or a token to
   authenticate the private repo):
   ```sh
   gh repo clone khbzyabis/stables-app
   cd stables-app
   git checkout claude/read-this-h7d4dr
   ```
3. Start it (first build takes a few minutes while it downloads Flutter):
   ```sh
   docker compose up
   ```
4. Open **http://localhost:3000**.

Loop after Claude pushes a change:
```sh
git pull
docker compose restart      # reloads with the new code
```
Only re-run `docker compose up --build` when `pubspec.yaml` changes. Stop with
Ctrl-C (or `docker compose down`).

Note: live hot-reload file-watching across the Docker mount on macOS can be
hit-or-miss; `docker compose restart` after a pull is the reliable way to see
changes.

## Pushing your own changes

```sh
git add -A
git commit -m "what you changed"
git push
```

Vercel auto-deploys the branch on every push — that's "putting it on the net".
Pull before you start editing to avoid conflicts with Claude's pushes.
