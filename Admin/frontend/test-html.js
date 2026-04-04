import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  await page.goto('http://localhost:5174/emergency', { waitUntil: 'networkidle0' });
  const html = await page.evaluate(() => document.getElementById('root')?.innerHTML || 'no root');
  console.log(html);
  await browser.close();
})();