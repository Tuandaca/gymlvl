import assert from 'node:assert/strict';
import http from 'node:http';
import { access, readFile, mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const webRoot = path.join(root, 'app/build/web');
const output = path.join(root, 'tmp/user-testing');
await access(path.join(webRoot, 'index.html'));
await mkdir(output, { recursive: true });

const types = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf'
};

const server = http.createServer(async (req, res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  const filename = path.resolve(webRoot, '.' + pathname);
  if (filename !== webRoot && !filename.startsWith(webRoot + path.sep)) {
    res.writeHead(403).end();
    return;
  }
  try {
    const target = filename === webRoot ? path.join(webRoot, 'index.html') : filename;
    res.setHeader('Content-Type', types[path.extname(target)] || 'application/octet-stream');
    res.end(await readFile(target));
  } catch {
    res.writeHead(404).end();
  }
});

await new Promise(resolve => server.listen(8080, '127.0.0.1', resolve));
console.log('Local GymLevel web server listening at http://127.0.0.1:8080');

const browser = await chromium.launch({
  headless: true,
  ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : { channel: 'chrome' }),
});

try {
  // Test 1: Desktop Viewport (1440x900) - Vietnamese
  {
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, locale: 'vi' });
    await context.addInitScript(() => localStorage.setItem('flutter.lang_mode', JSON.stringify('vi')));
    const page = await context.newPage();
    await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
    await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
    await page.waitForTimeout(2000);
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
    await page.waitForTimeout(500);

    await page.screenshot({ path: path.join(output, '01_desktop_login_vi.png'), fullPage: true });
    const text = await page.locator('body').innerText();
    await writeFile(path.join(output, '01_desktop_login_vi.txt'), text, 'utf8');
    console.log('Captured: 01_desktop_login_vi.png');
    console.log('Login Screen Semantics:\n' + text.substring(0, 500));
    await context.close();
  }

  // Test 2: Mobile Viewport (390x844 - iPhone 14) - Vietnamese
  {
    const context = await browser.newContext({ viewport: { width: 390, height: 844 }, locale: 'vi' });
    await context.addInitScript(() => localStorage.setItem('flutter.lang_mode', JSON.stringify('vi')));
    const page = await context.newPage();
    await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
    await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
    await page.waitForTimeout(2000);
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
    await page.waitForTimeout(500);

    await page.screenshot({ path: path.join(output, '02_mobile_login_vi.png'), fullPage: true });
    console.log('Captured: 02_mobile_login_vi.png');
    await context.close();
  }

  // Test 3: Register Screen - Mobile Viewport - Vietnamese
  {
    const context = await browser.newContext({ viewport: { width: 390, height: 844 }, locale: 'vi' });
    await context.addInitScript(() => localStorage.setItem('flutter.lang_mode', JSON.stringify('vi')));
    const page = await context.newPage();
    await page.goto('http://127.0.0.1:8080/#/register', { waitUntil: 'networkidle' });
    await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
    await page.waitForTimeout(2000);
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
    await page.waitForTimeout(500);

    await page.screenshot({ path: path.join(output, '03_mobile_register_vi.png'), fullPage: true });
    const text = await page.locator('body').innerText();
    await writeFile(path.join(output, '03_mobile_register_vi.txt'), text, 'utf8');
    console.log('Captured: 03_mobile_register_vi.png');
    console.log('Register Screen Semantics:\n' + text.substring(0, 500));
    await context.close();
  }

  // Test 4: Desktop Viewport - English
  {
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, locale: 'en' });
    await context.addInitScript(() => localStorage.setItem('flutter.lang_mode', JSON.stringify('en')));
    const page = await context.newPage();
    await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
    await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
    await page.waitForTimeout(2000);
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
    await page.waitForTimeout(500);

    await page.screenshot({ path: path.join(output, '04_desktop_login_en.png'), fullPage: true });
    console.log('Captured: 04_desktop_login_en.png');
    await context.close();
  }

  console.log('ALL USER JOURNEY TESTS COMPLETED SUCCESSFULLY!');
} finally {
  await browser.close();
  server.close();
}
