document.addEventListener('DOMContentLoaded', () => {
  const root = document.getElementById('root');
  if (!root) return;

  const hello = document.createElement('div');
  hello.textContent = 'TypeScript boilerplate is working.';
  hello.style.fontFamily = 'system-ui, sans-serif';
  hello.style.padding = '16px';
  root.appendChild(hello);
});
