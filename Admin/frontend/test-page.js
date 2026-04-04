import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', err => console.log('PAGE ERROR:', err.toString()));
  page.on('response', response => {
    if(!response.ok()) {
      console.log(`Failed Request: ${response.url()} ${response.status()}`);
    }
  });

  await page.goto('http://localhost:5174/emergency', { waitUntil: 'networkidle0' }).catch(e => console.log('Goto Error:', e));
  
  await browser.close();
})();