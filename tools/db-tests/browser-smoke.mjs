import assert from 'node:assert/strict';
import http from 'node:http';
import { access, readFile, mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const webRoot = path.resolve(process.env.GYMLVL_WEB_ROOT || path.join(root, 'app/build/web'));
const output = path.resolve(process.env.GYMLVL_SCREENSHOTS || path.join(root, 'tmp/qa-browser'));
await access(path.join(webRoot, 'index.html'));
await mkdir(output, { recursive: true });
const types = { '.html': 'text/html', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.woff2': 'font/woff2', '.ttf': 'font/ttf' };
const server = http.createServer(async (request, response) => {
  const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
  const filename = path.resolve(webRoot, '.' + pathname);
  if (filename !== webRoot && !filename.startsWith(webRoot + path.sep)) {
    response.writeHead(403).end();
    return;
  }
  try {
    const target = filename === webRoot ? path.join(webRoot, 'index.html') : filename;
    response.setHeader('Content-Type', types[path.extname(target)] || 'application/octet-stream');
    response.end(await readFile(target));
  } catch {
    response.writeHead(404).end();
  }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const base = process.env.GYMLVL_WEB_URL || `http://127.0.0.1:${server.address().port}`;
const browser = await chromium.launch({
  headless: true,
  ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : { channel: 'chrome' }),
});
const report = [];
try {
  for (const lang of ['vi', 'en']) {
    for (const viewport of [{ width: 320, height: 720 }, { width: 390, height: 844 }, { width: 768, height: 1024 }, { width: 1440, height: 1000 }]) {
      const context = await browser.newContext({ viewport, locale: lang, reducedMotion: 'reduce' });
      await context.addInitScript(mode => localStorage.setItem('flutter.lang_mode', JSON.stringify(mode)), lang);
      const page = await context.newPage();
      const errors = [];
      page.on('pageerror', error => errors.push(error.message));
      page.on('console', event => { if (event.type() === 'error') errors.push(event.text()); });
      for (const route of ['login', 'register']) {
        await page.goto(`${base}/#/${route}`, { waitUntil: 'networkidle' });
        await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
        await page.waitForTimeout(1200);
        await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
        await page.waitForTimeout(300);
        const name = `${route}-${lang}-${viewport.width}`;
        await page.screenshot({ path: path.join(output, `${name}.png`), fullPage: true });
        const semantics = await page.locator('body').innerText();
        await writeFile(path.join(output, `${name}.txt`), semantics, 'utf8');
        assert(!/RenderFlex overflowed|EXCEPTION CAUGHT|ErrorWidget/.test(semantics + errors.join('\n')), `${name}: Flutter render error`);
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth), false, `${name}: document horizontal overflow`);
        report.push({ name, status: errors.length ? 'FAIL' : 'PASS', errors: [...errors], screenshot: `${name}.png`, semantics: semantics.substring(0, 3000) });
      }
      await context.close();
    }
  }
  await writeFile(path.join(output, 'report.json'), JSON.stringify(report, null, 2));
  for (const entry of report) console.log(`${entry.status} ${entry.name}${entry.errors.length ? ': ' + entry.errors.join('; ') : ''}`);
  if (report.some(entry => entry.status === 'FAIL')) process.exitCode = 1;
  console.log(`Screenshots and semantics: ${output}`);
  console.log('LIMITATION: public authentication UI rendering only; no live user signup, workout or backend mutation.');
} finally {
  await browser.close();
  server.close();
}
