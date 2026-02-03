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