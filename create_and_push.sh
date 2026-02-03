#!/usr/bin/env bash
set -euo pipefail

# Usage: ./create_and_push.sh
# Requirements: git, gh (GitHub CLI) authenticated, node (optional for npm install)

REPO_OWNER="kevinoon"
REPO_NAME="typing-game"
VISIBILITY="public" # public or private
BRANCH="main"

# Check dependencies
command -v git >/dev/null 2>&1 || { echo "git is required. Install git and retry."; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "gh (GitHub CLI) is required. Install and authenticate (gh auth login) and retry."; exit 1; }

ROOT_DIR="$(pwd)/${REPO_NAME}"
if [ -d "$ROOT_DIR" ]; then
  echo "Directory ${ROOT_DIR} already exists. Please remove or run from a different location."
  exit 1
fi

mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create files
cat > package.json <<'EOF'
{
  "name": "typing-game",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "typescript": "^5.2.0",
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.0.0"
  }
}
EOF

cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "jsx": "react-jsx",
    "moduleResolution": "Node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "baseUrl": ".",
    "resolveJsonModule": true
  },
  "include": ["src"]
}
EOF

cat > vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()]
});
EOF

cat > .gitignore <<'EOF'
node_modules
dist
.env
.vscode
.DS_Store
EOF

cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 kevinoon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

mkdir -p public src/components src/lib
cat > public/index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Typing Game</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > src/main.tsx <<'EOF'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './styles.css';

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat > src/App.tsx <<'EOF'
import React from 'react';
import TypingGame from './components/TypingGame';

export default function App() {
  return (
    <div className="app-container">
      <h1>Typing Game</h1>
      <TypingGame />
    </div>
  );
}
EOF

cat > src/styles.css <<'EOF'
:root {
  --bg: #f7f9fc;
  --card: #ffffff;
  --muted: #6b7280;
}

body {
  margin: 0;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  background: var(--bg);
  color: #111827;
  padding: 24px;
}

.app-container {
  max-width: 900px;
  margin: 0 auto;
}

button {
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid #d1d5db;
  background: white;
  cursor: pointer;
}

button:hover {
  filter: brightness(0.98);
}
EOF

cat > src/components/TypingGame.tsx <<'EOF'
import React, { useEffect, useState, useRef } from 'react';
import { quotes, addQuote, resetToDefaults } from '../lib/quotes';

function getRandomQuote() {
  const idx = Math.floor(Math.random() * quotes.length);
  return quotes[idx] ?? '';
}

export default function TypingGame() {
  const [target, setTarget] = useState<string>(getRandomQuote);
  const [input, setInput] = useState('');
  const [startedAt, setStartedAt] = useState<number | null>(null);
  const [finishedAt, setFinishedAt] = useState<number | null>(null);
  const inputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    inputRef.current?.focus();
  }, [target]);

  useEffect(() => {
    if (input.length === 1 && startedAt === null) {
      setStartedAt(Date.now());
    }
    if (input === target && target.length > 0) {
      setFinishedAt(Date.now());
    } else {
      setFinishedAt(null);
    }
  }, [input, target, startedAt]);

  const reset = () => {
    setTarget(getRandomQuote());
    setInput('');
    setStartedAt(null);
    setFinishedAt(null);
  };

  const elapsedSeconds = () => {
    if (!startedAt) return 0;
    const end = finishedAt ?? Date.now();
    return Math.max(0, (end - startedAt) / 1000);
  };

  const words = target.trim() === '' ? 0 : target.trim().split(/\s+/).length;
  const wpm = () => {
    const minutes = elapsedSeconds() / 60;
    return minutes === 0 ? 0 : Math.round(words / minutes);
  };

  const correctChars = () => {
    let n = 0;
    for (let i = 0; i < input.length; i++) {
      if (input[i] === target[i]) n++;
    }
    return n;
  };

  return (
    <div style={{ maxWidth: 800 }}>
      <div style={{ marginBottom: 12, whiteSpace: 'pre-wrap', padding: 12, border: '1px solid #ddd', borderRadius: 6, background: 'var(--card)' }}>
        {target.split('').map((ch, i) => {
          const typed = input[i];
          let color = undefined;
          if (typed == null) color = undefined;
          else color = typed === ch ? 'green' : 'crimson';
          return (
            <span key={i} style={{ color }}>
              {ch}
            </span>
          );
        })}
      </div>

      <input
        ref={inputRef}
        value={input}
        onChange={(e) => setInput(e.target.value)}
        placeholder="Start typing..."
        style={{ width: '100%', padding: '8px 10px', fontSize: 16 }}
      />

      <div style={{ marginTop: 10, display: 'flex', gap: 12 }}>
        <button onClick={reset}>New Quote</button>
        <button
          onClick={() => {
            const text = prompt('Add a custom quote:');
            if (text) {
              addQuote(text);
              alert('Added to local quote library (saved to localStorage).');
              setTarget(text);
              setInput('');
            }
          }}
        >
          Add Quote
        </button>
        <button
          onClick={() => {
            if (confirm('Reset quote library to defaults?')) {
              resetToDefaults();
              setTarget(getRandomQuote());
              setInput('');
            }
          }}
        >
          Reset Quotes
        </button>
      </div>

      <div style={{ marginTop: 12 }}>
        <strong>Time:</strong> {elapsedSeconds().toFixed(1)}s &nbsp; <strong>WPM:</strong> {wpm()} &nbsp; <strong>Accuracy:</strong>{' '}
        {input.length === 0 ? '0%' : `${Math.round((correctChars() / input.length) * 100)}%`}
      </div>

      {finishedAt && (
        <div style={{ marginTop: 10, padding: 10, background: '#eef', borderRadius: 6 }}>
          Finished! Your WPM: {wpm()}. Click "New Quote" for another.
        </div>
      )}
    </div>
  );
}
EOF

cat > src/lib/quotes.ts <<'EOF'
// A minimal local quote library. It persists to localStorage so you can add quotes client-side.
const STORAGE_KEY = 'typing-game-quotes';

const defaultQuotes = [
  "The quick brown fox jumps over the lazy dog.",
  "Simplicity is the soul of efficiency.",
  "Code is like humor. When you have to explain it, it’s bad.",
  "First, solve the problem. Then, write the code."
];

export let quotes: string[] = (() => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) return JSON.parse(raw);
  } catch {}
  return defaultQuotes.slice();
})();

export function save() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(quotes));
  } catch {}
}

export function addQuote(q: string) {
  quotes.push(q);
  save();
}

export function resetToDefaults() {
  quotes = defaultQuotes.slice();
  save();
}
EOF

cat > README.md <<'EOF'
# Typing Game

A small TypeScript + React typing game scaffolded with Vite.

Features
- Vite + React + TypeScript
- Simple typing UI with WPM & accuracy
- Local quote library persisted to localStorage
- Add your own quotes from the UI

Getting started
1. npm install
2. npm run dev
3. Open http://localhost:5173

Planned improvements
- Score saving and history
- Multiplayer / challenge mode
- Import / export quotes
- Better UI / styling
EOF

mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run typecheck
EOF

# initialize git, commit
git init -b "$BRANCH"
git add .
git commit -m "chore: initial scaffold for typing-game (Vite + React + TypeScript)"

# create repo on GitHub with GH CLI
echo "Creating repository ${REPO_OWNER}/${REPO_NAME} on GitHub (${VISIBILITY})..."
gh repo create "${REPO_OWNER}/${REPO_NAME}" --"${VISIBILITY}" --source=. --remote=origin --push --confirm

echo "Repository created and pushed: https://github.com/${REPO_OWNER}/${REPO_NAME}"
echo ""
echo "Next steps:"
echo "  cd ${REPO_NAME}"
echo "  npm install"
echo "  npm run dev"
echo ""
echo "If you want me to add additional features (prettier/eslint, score history, import/export), tell me what you'd like."
EOF