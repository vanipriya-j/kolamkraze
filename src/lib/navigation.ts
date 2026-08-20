export function withQuery(href: string, params: Record<string, string | undefined | null>): string {
  const [path, existing] = href.split("?");
  const search = new URLSearchParams(existing);
  for (const [key, value] of Object.entries(params)) {
    if (!value) search.delete(key);
    else search.set(key, value);
  }
  const query = search.toString();
  return query ? `${path}?${query}` : path;
}

export function venueHref(href: string, venueId?: string | null) {
  return withQuery(href, { venue: venueId ?? undefined });
}
