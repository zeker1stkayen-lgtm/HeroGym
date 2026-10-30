// HeroGym Offline Service Worker v7 (Network-First for HTML, Stale-While-Revalidate for Assets)
const CACHE_NAME = 'herogym-offline-v8';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './manifest.json',
  'https://cdn.tailwindcss.com',
  'https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;900&family=Inter:wght@400;500;600;700&display=swap'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW v6] Pre-caching offline assets...');
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  const isHtml = req.mode === 'navigate' || req.headers.get('accept')?.includes('text/html') || req.url.endsWith('index.html') || req.url.endsWith('/');

  if (isHtml) {
    // Network-First for HTML so user always gets the latest deployed version!
    event.respondWith(
      fetch(req)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, responseClone));
          }
          return networkResponse;
        })
        .catch(() => {
          console.log('[SW v6] Network failed, serving cached HTML');
          return caches.match(req).then((cached) => cached || caches.match('./index.html'));
        })
    );
  } else {
    // Cache-First for static assets, fallback to network
    event.respondWith(
      caches.match(req).then((cachedResponse) => {
        return cachedResponse || fetch(req).then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200 && req.method === 'GET') {
            const responseClone = networkResponse.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(req, responseClone));
          }
          return networkResponse;
        });
      })
    );
  }
});
