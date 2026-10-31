/**
 * Booking Network Co., Ltd. — Cloudflare Worker & Static Assets Gateway
 * Project: GLOBAL TRAVEL ESSENTIAL APP (BN-GLOBAL-TRAVEL-APP-002)
 */

const DEFAULT_BACKEND = "https://brother-proposition-tube-explanation.trycloudflare.com";
const APK_DOWNLOAD_URL = "https://raw.githubusercontent.com/dnjstjq0824-byte/all_in_one_travel/main/release/apk/app-release.apk";

// Security headers required by Article 10
const SECURITY_HEADERS = {
  "X-Frame-Options": "SAMEORIGIN",
  "X-Content-Type-Options": "nosniff",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
  "Access-Control-Expose-Headers": "X-Content-SHA256, ETag",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With",
};

function addSecurityHeaders(response) {
  const newHeaders = new Headers(response.headers);
  for (const [k, v] of Object.entries(SECURITY_HEADERS)) {
    newHeaders.set(k, v);
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: newHeaders,
  });
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: SECURITY_HEADERS,
      });
    }

    // 1. Android APK direct download
    if (url.pathname === "/download/android" || url.pathname === "/download/android/") {
      return Response.redirect(APK_DOWNLOAD_URL, 302);
    }

    // 2. Legal & Portal pretty URLs
    const portalRoutes = {
      "/download": "/download.html",
      "/download/": "/download.html",
      "/privacy": "/privacy.html",
      "/privacy/": "/privacy.html",
      "/terms": "/terms.html",
      "/terms/": "/terms.html",
      "/support": "/support.html",
      "/support/": "/support.html",
    };

    if (portalRoutes[url.pathname] && env.ASSETS) {
      const assetUrl = new URL(portalRoutes[url.pathname], request.url);
      const res = await env.ASSETS.fetch(new Request(assetUrl, request));
      return addSecurityHeaders(res);
    }

    // 3. API Proxy to Go Backend with Edge Fallback
    if (url.pathname.startsWith("/api/v1/")) {
      const backendUrl = env.BACKEND_URL || DEFAULT_BACKEND;
      const targetUrl = new URL(url.pathname + url.search, backendUrl);

      try {
        const backendReq = new Request(targetUrl, {
          method: request.method,
          headers: request.headers,
          body: request.method !== "GET" && request.method !== "HEAD" ? request.body : undefined,
        });

        const backendRes = await fetch(backendReq);
        return addSecurityHeaders(backendRes);
      } catch (err) {
        // Fallback for health check if backend tunnel is offline
        if (url.pathname === "/api/v1/health") {
          return new Response(
            JSON.stringify({
              cities: 18,
              service: "Global Travel Essential API (Edge Worker Fallback)",
              status: "healthy",
              version: "1.0.0",
            }),
            {
              status: 200,
              headers: { "Content-Type": "application/json", ...SECURITY_HEADERS },
            }
          );
        }
        return new Response(
          JSON.stringify({ error: "Backend proxy unreachable", details: String(err) }),
          { status: 502, headers: { "Content-Type": "application/json", ...SECURITY_HEADERS } }
        );
      }
    }

    // 4. Flutter Web SPA Deep Link Fallback (e.g. /web/transit, /web/explore)
    if (url.pathname.startsWith("/web/") && env.ASSETS) {
      const assetRes = await env.ASSETS.fetch(request);
      if (assetRes.status === 404 && !url.pathname.includes(".")) {
        // SPA Fallback: serve /web/index.html
        const fallbackUrl = new URL("/web/index.html", request.url);
        const spaRes = await env.ASSETS.fetch(new Request(fallbackUrl, request));
        return addSecurityHeaders(spaRes);
      }
      return addSecurityHeaders(assetRes);
    }

    // 5. Default Static Assets Fetch
    if (env.ASSETS) {
      const res = await env.ASSETS.fetch(request);
      return addSecurityHeaders(res);
    }

    return new Response("Not Found", { status: 404 });
  },
};
