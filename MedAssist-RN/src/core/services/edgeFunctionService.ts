import { supabase } from '../supabase/client';

interface EdgeFunctionOptions {
  functionName: string;
  body: Record<string, unknown>;
  retries?: number;
  timeoutMs?: number;
}

export async function invokeEdgeFunction<T = Record<string, unknown>>({
  functionName,
  body,
  retries = 2,
  timeoutMs = 30000,
}: EdgeFunctionOptions): Promise<T> {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeoutMs);

      const { data, error } = await supabase.functions.invoke(functionName, {
        body,
      });

      clearTimeout(timer);

      if (error) throw new Error(error.message ?? 'Edge function error');
      return data as T;
    } catch (e) {
      lastError = e instanceof Error ? e : new Error(String(e));
      if (attempt < retries) {
        await new Promise((r) => setTimeout(r, 1000 * (attempt + 1)));
      }
    }
  }

  throw lastError ?? new Error('Edge function failed');
}
