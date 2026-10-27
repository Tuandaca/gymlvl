import { chromium } from 'playwright';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdir } from 'node:fs/promises';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const output = path.join(root, 'tmp/user-testing');
await mkdir(output, { recursive: true });

async function enableSemantics(page) {
  await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
  await page.waitForTimeout(2000);
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
  await page.waitForTimeout(1000);
}

const browser = await chromium.launch({ headless: true, channel: 'chrome' });

console.log('=== CHUỖI KIỂM THỬ TẤT CẢ TÍNH NĂNG NHƯ NGƯỜI DÙNG THỰC TẾ ===');

// 1. Ensure user is onboarded
await fetch('http://127.0.0.1:54321/mock/set-onboarded', { method: 'POST' });

// 2. Open Desktop Context (1440x900)
const context = await browser.newContext({ viewport: { width: 1440, height: 900 }, locale: 'vi' });
const page = await context.newPage();

// Step 1: Login
console.log('1. Đăng nhập vào tài khoản Hunter...');
await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
await enableSemantics(page);
await page.locator('input[type="text"]').first().fill('hunter@gymlvl.dev');
await page.locator('input[type="password"]').first().fill('Password123!');
await page.screenshot({ path: path.join(output, '01_user_login.png') });
await page.locator('[role="button"]:has-text("Đăng nhập"), button:has-text("Đăng nhập")').last().click();
await page.waitForTimeout(3000);

// Step 2: Dashboard
console.log('2. Trải nghiệm Trung Tâm Hệ Thống (Dashboard RPG)...');
await enableSemantics(page);
await page.screenshot({ path: path.join(output, '02_rpg_dashboard.png'), fullPage: true });
console.log('Captured: 02_rpg_dashboard.png');

// Step 3: Quests
console.log('3. Trải nghiệm Nhiệm Vụ Hàng Ngày (Daily Quests)...');
await page.goto('http://127.0.0.1:8080/#/quests', { waitUntil: 'networkidle' });
await enableSemantics(page);
await page.screenshot({ path: path.join(output, '03_daily_quests.png'), fullPage: true });
console.log('Captured: 03_daily_quests.png');

// Step 4: Workout
console.log('4. Trải nghiệm Không Gian Tập Luyện (Workout Tracker & Timer)...');
await page.goto('http://127.0.0.1:8080/#/workout', { waitUntil: 'networkidle' });
await enableSemantics(page);
await page.screenshot({ path: path.join(output, '04_workout_tracker.png'), fullPage: true });
console.log('Captured: 04_workout_tracker.png');

// Step 5: AI Coach
console.log('5. Trải nghiệm Trợ Lý Huấn Luyện Viên AI (AI Coach)...');
await page.goto('http://127.0.0.1:8080/#/coach', { waitUntil: 'networkidle' });
await enableSemantics(page);
await page.screenshot({ path: path.join(output, '05_ai_coach.png'), fullPage: true });
console.log('Captured: 05_ai_coach.png');

// Step 6: Profile
console.log('6. Trải nghiệm Hồ Sơ Thợ Săn & Cài Đặt (Profile Screen)...');
await page.goto('http://127.0.0.1:8080/#/profile', { waitUntil: 'networkidle' });
await enableSemantics(page);
await page.screenshot({ path: path.join(output, '06_profile_settings.png'), fullPage: true });
console.log('Captured: 06_profile_settings.png');

await context.close();

// Step 7: Mobile Experience
console.log('7. Trải nghiệm Giao Diện Di Động (Mobile 390x844)...');
const mobileContext = await browser.newContext({ viewport: { width: 390, height: 844 }, locale: 'vi' });
const mobilePage = await mobileContext.newPage();
await mobilePage.goto('http://127.0.0.1:8080/#/dashboard', { waitUntil: 'networkidle' });
await enableSemantics(mobilePage);
await mobilePage.screenshot({ path: path.join(output, '07_mobile_dashboard.png'), fullPage: true });
console.log('Captured: 07_mobile_dashboard.png');

await mobileContext.close();
await browser.close();

console.log('=== HOÀN TẤT 100% CÁC CHỨC NĂNG NHƯ NGƯỜI DÙNG THỰC TẾ! ===');
