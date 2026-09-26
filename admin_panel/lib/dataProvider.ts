import type { DataProvider } from "@refinedev/core";

// Minimal Refine data provider backed by our NestJS API (avoids peer conflicts).
export function createDataProvider(apiUrl: string): DataProvider {
  return {
    getApiUrl: () => apiUrl,
    getList: async ({ resource }) => {
      const path = resource === "menu" ? "/api/menu" : `/api/${resource}`;
      const res = await fetch(`${apiUrl}${path}`, { cache: "no-store" });
      if (!res.ok) throw new Error(`GET ${path} failed`);
      const data = await res.json();
      return { data, total: Array.isArray(data) ? data.length : 0 };
    },
    getOne: async ({ resource, id }) => {
      const res = await fetch(`${apiUrl}/api/${resource}/${id}`, { cache: "no-store" });
      if (!res.ok) throw new Error("not found");
      return { data: await res.json() };
    },
    create: async ({ resource, variables }) => {
      const res = await fetch(`${apiUrl}/api/${resource}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(variables),
      });
      if (!res.ok) throw new Error("create failed");
      return { data: await res.json() };
    },
    update: async () => { throw new Error("not implemented"); },
    deleteOne: async () => { throw new Error("not implemented"); },
    getMany: async () => ({ data: [] }),
    custom: async () => ({ data: null as never }),
  } as DataProvider;
}
