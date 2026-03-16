type Options = { token?: string };

function headers(options?: Options): Record<string, string> {
  const h: Record<string, string> = { "Content-Type": "application/json" };
  if (options?.token) h["Authorization"] = `Bearer ${options.token}`;
  return h;
}

export async function get<T = unknown>(path: string, options?: Options): Promise<T> {
  const res = await fetch(`/api/v1/${path}`, { method: "GET", headers: headers(options) });
  return res.json();
}

export async function post<T = unknown>(path: string, body: unknown, options?: Options): Promise<T> {
  const res = await fetch(`/api/v1/${path}`, {
    method: "POST",
    headers: headers(options),
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function put<T = unknown>(path: string, body: unknown, options?: Options): Promise<T> {
  const res = await fetch(`/api/v1/${path}`, {
    method: "PUT",
    headers: headers(options),
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function del<T = unknown>(path: string, options?: Options): Promise<T> {
  const res = await fetch(`/api/v1/${path}`, { method: "DELETE", headers: headers(options) });
  return res.json();
}

export { del as delete };
