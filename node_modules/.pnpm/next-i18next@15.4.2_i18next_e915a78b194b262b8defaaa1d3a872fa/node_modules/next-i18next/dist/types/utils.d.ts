import { FallbackLng } from 'i18next';
import { useLayoutEffect } from 'react';
export declare const getFallbackForLng: (lng: string, fallbackLng: false | FallbackLng) => string[];
export declare const unique: (list: string[]) => string[];
/**
 * This hook behaves like `useLayoutEffect` on the client,
 * and `useEffect` on the server(no effect).
 *
 * Since using `useLayoutEffect` on the server cause warning messages in nextjs,
 * this hook is workaround for that.
 */
export declare const useIsomorphicLayoutEffect: typeof useLayoutEffect;
