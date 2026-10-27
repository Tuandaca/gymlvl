import { chromium } from 'playwright';

const browser = await chromium.launch({ headless: true, channel: 'chrome' });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

// 1. Set onboarded on server right away
await fetch('http://127.0.0.1:54321/mock/set-onboarded', { method: 'POST' });

// 2. Go to login
await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
await page.waitForTimeout(1500);
await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
await page.waitForTimeout(500);

await page.locator('input[type="text"]').first().fill('hunter@gymlvl.dev');
await page.locator('input[type="password"]').first().fill('Password123!');
await page.locator('[role="button"]:has-text("Đăng nhập"), button:has-text("Đăng nhập")').last().click();

await page.waitForTimeout(3000);
console.log('After login URL:', page.url());

await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
await page.waitForTimeout(1000);

const text = await page.locator('body').innerText();
console.log('Semantics:\n', text.substring(0, 600));

await page.screenshot({ path: '../tmp/user-testing/04_real_dashboard.png', fullPage: true });

await browser.close();
