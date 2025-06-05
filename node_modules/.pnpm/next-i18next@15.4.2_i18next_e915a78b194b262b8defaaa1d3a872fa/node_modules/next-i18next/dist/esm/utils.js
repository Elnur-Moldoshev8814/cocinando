import _toConsumableArray from "@babel/runtime/helpers/toConsumableArray";
import _typeof from "@babel/runtime/helpers/typeof";
import { useLayoutEffect, useEffect } from 'react';
export var getFallbackForLng = function getFallbackForLng(lng, fallbackLng) {
  if (typeof fallbackLng === 'string') {
    return [fallbackLng];
  }
  if (Array.isArray(fallbackLng)) {
    return fallbackLng;
  }
  if (_typeof(fallbackLng) === 'object') {
    var fallbackList = fallbackLng[lng];
    var fallbackDefault = fallbackLng["default"];
    return [].concat(_toConsumableArray(fallbackList !== null && fallbackList !== void 0 ? fallbackList : []), _toConsumableArray(fallbackDefault !== null && fallbackDefault !== void 0 ? fallbackDefault : []));
  }
  if (typeof fallbackLng === 'function') {
    return getFallbackForLng(lng, fallbackLng(lng));
  }
  return [];
};
export var unique = function unique(list) {
  return Array.from(new Set(list));
};

/**
 * This hook behaves like `useLayoutEffect` on the client,
 * and `useEffect` on the server(no effect).
 *
 * Since using `useLayoutEffect` on the server cause warning messages in nextjs,
 * this hook is workaround for that.
 */
export var useIsomorphicLayoutEffect = typeof window !== 'undefined' ? useLayoutEffect : useEffect;