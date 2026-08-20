self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open("kolam-kraze-v1").then((cache) =>
      cache.addAll([
        "/",
        "/play/kolam-kraze",
        "/play/kolam-kraze/levels",
        "/play/kolam-kraze/daily",
        "/play/kolam-kraze/irl",
        "/manifest.webmanifest",
        "/icons/icon.svg",
      ]).catch(() => undefined),
    ),
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((key) => key !== "kolam-kraze-v1").map((key) => caches.delete(key))),
    ),
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  event.respondWith(
    caches.match(request).then((cached) => {
      const fetched = fetch(request)
        .then((response) => {
          if (response.ok && (request.url.startsWith(self.location.origin))) {
            const copy = response.clone();
            caches.open("kolam-kraze-v1").then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => cached);
      return cached || fetched;
    }),
  );
});
