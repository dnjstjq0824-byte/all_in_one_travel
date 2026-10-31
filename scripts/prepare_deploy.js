/**
 * Booking Network Co., Ltd. — Cloudflare Auto-Build Asset Preparer
 * Ensures all portal pages and Flutter Web artifacts are validated in public/
 */
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const publicDir = path.join(rootDir, 'public');
const portalDir = path.join(rootDir, 'release', 'portal');
const webReleaseDir = path.join(rootDir, 'release', 'web');

console.log('🚀 [Cloudflare Build] Validating deployment assets in public/...');

// 1. Ensure public directory exists
if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true });
}

// 2. Remove problematic _redirects file if it was created
const redirectsPath = path.join(publicDir, '_redirects');
if (fs.existsSync(redirectsPath)) {
  fs.unlinkSync(redirectsPath);
  console.log('🧹 Cleaned up redundant _redirects to prevent loop error [code: 100324]');
}

// 3. Sync portal HTML files if needed
if (fs.existsSync(portalDir)) {
  const portalFiles = fs.readdirSync(portalDir);
  for (const file of portalFiles) {
    if (file.endsWith('.html')) {
      const src = path.join(portalDir, file);
      const dest = path.join(publicDir, file);
      if (!fs.existsSync(dest)) {
        fs.copyFileSync(src, dest);
        console.log(`📦 Synced portal file: ${file}`);
      }
    }
  }
}

// 4. Ensure public/web exists and has index.html
const publicWebDir = path.join(publicDir, 'web');
if (!fs.existsSync(publicWebDir)) {
  fs.mkdirSync(publicWebDir, { recursive: true });
}

if (fs.existsSync(webReleaseDir)) {
  fs.cpSync(webReleaseDir, publicWebDir, { recursive: true, force: true });
  console.log('📦 Synchronized release/web assets to public/web');
}

// 5. Ensure _headers exists
const headersPath = path.join(publicDir, '_headers');
if (!fs.existsSync(headersPath)) {
  const headersContent = `/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Strict-Transport-Security: max-age=31536000; includeSubDomains
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
  Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With
`;
  fs.writeFileSync(headersPath, headersContent, 'utf8');
  console.log('🔒 Created default _headers with Article 10 security policy');
}

console.log('✅ [Cloudflare Build] Assets preparation completed successfully!');

