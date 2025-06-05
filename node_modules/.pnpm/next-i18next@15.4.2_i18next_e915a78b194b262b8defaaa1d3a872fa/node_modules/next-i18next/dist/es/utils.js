import { useLayoutEffect, useEffect } from 'react';
export const getFallbackForLng = (lng, fallbackLng) => {
  if (typeof fallbackLng === 'string') {
    return [fallbackLng];
  }
  if (Array.isArray(fallbackLng)) {
    return fallbackLng;
  }
  if (typeof fallbackLng === 'object') {
    const fallbackList = fallbackLng[lng];
    const fallbackDefault = fallbackLng.default;
    return [...(fallbackList ?? []), ...(fallbackDefault ?? [])];
  }
  if (typeof fallbackLng === 'function') {
    return getFallbackForLng(lng, fallbackLng(lng));
  }
  return [];
};
export const unique = list => Array.from(new Set(list));

/**
 * This hook behaves like `useLayoutEffect` on the client,
 * and `useEffect` on the server(no effect).
 *
 * Since using `useLayoutEffect` on the server cause warning messages in nextjs,
 * this hook is workaround for that.
 */
export const useIsomorphicLayoutEffect = typeof window !== 'undefined' ? useLayoutEffect : useEffect;