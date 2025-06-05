function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
import React, { useMemo, useRef } from 'react';
import hoistNonReactStatics from 'hoist-non-react-statics';
import { I18nextProvider } from 'react-i18next';
import { createConfig } from './config/createConfig';
import createClient from './createClient';
import { useIsomorphicLayoutEffect } from './utils';
export { Trans, useTranslation, withTranslation } from 'react-i18next';
export let globalI18n = null;
const addResourcesToI18next = (instance, resources) => {
  if (resources && instance.isInitialized) {
    for (const locale of Object.keys(resources)) {
      for (const ns of Object.keys(resources[locale])) {
        if (!instance?.store?.data || !instance.store.data[locale] || !instance.store.data[locale][ns]) {
          instance.addResourceBundle(locale, ns, resources[locale][ns], true, true);
        }
      }
    }
  }
};
export const appWithTranslation = (WrappedComponent, configOverride = null) => {
  const AppWithTranslation = props => {
    const {
      _nextI18Next
    } = props.pageProps || {}; // pageProps may be undefined on strange setups, i.e. https://github.com/i18next/next-i18next/issues/2109
    let locale = _nextI18Next?.initialLocale ?? props?.router?.locale;
    const ns = _nextI18Next?.ns;
    const instanceRef = useRef(null);

    /**
     * Memoize i18n instance and reuse it rather than creating new instance.
     * When the locale or resources are changed after instance was created,
     * we will update the instance by calling addResourceBundle method on it.
     */
    const i18n = useMemo(() => {
      if (!_nextI18Next && !configOverride) return null;
      const userConfig = configOverride ?? _nextI18Next?.userConfig;
      if (!userConfig) {
        throw new Error('appWithTranslation was called without a next-i18next config');
      }
      if (!userConfig?.i18n) {
        throw new Error('appWithTranslation was called without config.i18n');
      }
      if (!userConfig?.i18n?.defaultLocale) {
        throw new Error('config.i18n does not include a defaultLocale property');
      }
      const {
        initialI18nStore
      } = _nextI18Next || {};
      const resources = configOverride?.resources ? configOverride.resources : initialI18nStore;
      if (!locale) locale = userConfig.i18n.defaultLocale;
      let instance = instanceRef.current;
      if (instance) {
        addResourcesToI18next(instance, resources);
      } else {
        instance = createClient({
          ...createConfig({
            ...userConfig,
            lng: locale
          }),
          lng: locale,
          ...(ns && {
            ns
          }),
          resources
        }).i18n;
        addResourcesToI18next(instance, resources);
        globalI18n = instance;
        instanceRef.current = instance;
      }
      return instance;
    }, [_nextI18Next, locale, ns]);

    /**
     * Since calling changeLanguage method on existing i18n instance cause state update in react,
     * we need to call the method in `useLayoutEffect` to prevent state update in render phase.
     */
    useIsomorphicLayoutEffect(() => {
      if (!i18n || !locale) return;
      i18n.changeLanguage(locale);
    }, [i18n, locale]);
    return i18n !== null ? /*#__PURE__*/React.createElement(I18nextProvider, {
      i18n: i18n
    }, /*#__PURE__*/React.createElement(WrappedComponent, props)) : /*#__PURE__*/React.createElement(WrappedComponent, _extends({
      key: locale
    }, props));
  };
  return hoistNonReactStatics(AppWithTranslation, WrappedComponent);
};