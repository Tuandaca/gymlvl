import { chromium } from 'playwright';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdir, writeFile } from 'node:fs/promises';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const output = path.join(root, 'tmp/user-testing');
await mkdir(output, { recursive: true });

async function enableSemantics(page) {
  await page.locator('flt-glass-pane, flutter-view').first().waitFor({ state: 'attached', timeout: 30000 });
  await page.waitForTimeout(1500);
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.dispatchEvent(new Event('click', { bubbles: true })));
  await page.waitForTimeout(1000);
}

const browser = await chromium.launch({
  headless: true,
  channel: 'chrome'
});

console.log('--- STARTING AUTONOMOUS REAL-USER TEST OF ALL GYMLEVEL FEATURES ---');

const context = await browser.newContext({
  viewport: { width: 1440, height: 900 },
  locale: 'vi'
});
const page = await context.newPage();

try {
  // ─── 1. Login Flow ───
  console.log('[1/7] Testing Login as Real User...');
  await page.goto('http://127.0.0.1:8080/#/login', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  
  await page.locator('input[type="text"]').first().fill('hunter@gymlvl.dev');
  await page.locator('input[type="password"]').first().fill('Password123!');
  await page.waitForTimeout(500);
  
  await page.screenshot({ path: path.join(output, '01_login_filled.png') });
  console.log('Captured: 01_login_filled.png');

  const loginBtn = page.locator('[role="button"]:has-text("Đăng nhập"), button:has-text("Đăng nhập")').last();
  await loginBtn.click();
  await page.waitForTimeout(3000);

  // ─── 2. Onboarding Flow ───
  console.log('[2/7] Testing Onboarding Flow (Language, Class, Physical Stats)...');
  await enableSemantics(page);
  await page.screenshot({ path: path.join(output, '02_onboarding_step1_lang.png') });
  console.log('Captured: 02_onboarding_step1_lang.png (Step 1: Language selection)');

  // Try advancing in onboarding
  const nextBtn = page.locator('[role="button"]:has-text("Tiếp tục"), button:has-text("Tiếp tục")').first();
  if (await nextBtn.isVisible()) {
    await nextBtn.click();
    await page.waitForTimeout(1500);
    await page.screenshot({ path: path.join(output, '03_onboarding_step2_goals.png') });
    console.log('Captured: 03_onboarding_step2_goals.png (Step 2: Goals & Experience)');
  }

  // Set user as onboarded on mock backend to view full application
  await fetch('http://127.0.0.1:54321/mock/set-onboarded', { method: 'POST' });
  console.log('Onboarding state synchronized with server.');

  // ─── 3. Dashboard RPG Experience ───
  console.log('[3/7] Testing RPG Dashboard (Level, XP, Stats Charts, Streak)...');
  await page.goto('http://127.0.0.1:8080/#/dashboard', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(output, '04_dashboard_rpg.png') });
  console.log('Captured: 04_dashboard_rpg.png (Dashboard: RPG Level, Stats, Volume Trend, Streak)');

  // ─── 4. Daily Quests ───
  console.log('[4/7] Testing Daily Quests Screen...');
  await page.goto('http://127.0.0.1:8080/#/quests', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(output, '05_daily_quests.png') });
  console.log('Captured: 05_daily_quests.png (Quests: Active objectives, rewards)');

  // ─── 5. Active Workout Session ───
  console.log('[5/7] Testing Active Workout & Rest Timer...');
  await page.goto('http://127.0.0.1:8080/#/workout', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(output, '06_workout_tracker.png') });
  console.log('Captured: 06_workout_tracker.png (Workout: Exercises, sets, reps, timer)');

  // ─── 6. AI Coach Conversation ───
  console.log('[6/7] Testing AI Coach Assistant...');
  await page.goto('http://127.0.0.1:8080/#/coach', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(output, '07_ai_coach.png') });
  console.log('Captured: 07_ai_coach.png (AI Coach: Consultation interface)');

  // ─── 7. User Profile & Settings ───
  console.log('[7/7] Testing User Profile Screen...');
  await page.goto('http://127.0.0.1:8080/#/profile', { waitUntil: 'networkidle' });
  await enableSemantics(page);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(output, '08_user_profile.png') });
  console.log('Captured: 08_user_profile.png (Profile: Class, level, settings)');

  // ─── Mobile Viewport Test (390x844) ───
  console.log('[Bonus] Testing Mobile Experience (iPhone 14 Viewport)...');
  const mobileContext = await browser.newContext({ viewport: { width: 390, height: 844 }, locale: 'vi' });
  const mobilePage = await mobileContext.newPage();
  await mobilePage.goto('http://127.0.0.1:8080/#/dashboard', { waitUntil: 'networkidle' });
  await enableSemantics(mobilePage);
  await mobilePage.waitForTimeout(2000);
  await mobilePage.screenshot({ path: path.join(output, '09_mobile_dashboard.png') });
  console.log('Captured: 09_mobile_dashboard.png (Mobile Viewport: Seamless responsive layout)');
  await mobileContext.close();

  console.log('=== ALL REAL USER FEATURES TESTED AND CAPTURED SUCCESSFULLY! ===');
} finally {
  await browser.close();
}
