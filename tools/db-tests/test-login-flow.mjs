import { chromium } from 'playwright';

const browser = await chromium.launch({ headless: true, channel: 'chrome' });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
await page.waitForTimeout(2000);
await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
await page.waitForTimeout(1000);

console.log('Filling email...');
const emailInput = page.locator('input[type="text"]').first();
await emailInput.fill('hunter@gymlvl.dev');

console.log('Filling password...');
const passwordInput = page.locator('input[type="password"]').first();
await passwordInput.fill('Password123!');

await page.waitForTimeout(500);

console.log('Clicking login button...');
const loginBtn = page.locator('[role="button"]:has-text("Đăng nhập"), button:has-text("Đăng nhập")').last();
await loginBtn.click();

console.log('Waiting for response...');
await page.waitForTimeout(3000);

console.log('Current URL:', page.url());
const bodyText = await page.locator('body').innerText();
console.log('Body Text:\n', bodyText.substring(0, 500));

await page.screenshot({ path: '../../tmp/user-testing/after_login.png', fullPage: true });

await browser.close();
