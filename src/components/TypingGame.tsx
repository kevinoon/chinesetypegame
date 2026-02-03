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