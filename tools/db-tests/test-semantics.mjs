import { chromium } from 'playwright';

const browser = await chromium.launch({
  headless: true,
  channel: 'chrome'
});
const page = await browser.newPage();
await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
await page.waitForTimeout(2000);
await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
await page.waitForTimeout(1000);

const inputs = await page.locator('input').all();
console.log('Inputs count:', inputs.length);
for (const input of inputs) {
  const type = await input.getAttribute('type');
  const aria = await input.getAttribute('aria-label');
  const placeholder = await input.getAttribute('placeholder');
  console.log('Input:', { type, aria, placeholder });
}

const buttons = await page.locator('button, [role="button"], [flt-semantics-role="button"]').all();
console.log('Buttons count:', buttons.length);
for (const btn of buttons) {
  const text = await btn.innerText();
  const aria = await btn.getAttribute('aria-label');
  console.log('Button:', { text: text.trim().substring(0, 30), aria });
}

await browser.close();
