import { UserConfig, SSRConfig } from './types';
import { Namespace } from 'i18next';
type ArrayElementOrSelf<T> = T extends ReadonlyArray<infer U> ? U[] : T[];
export declare const serverSideTranslations: (initialLocale: string, namespacesRequired?: ArrayElementOrSelf<Namespace> | string | string[] | undefined, configOverride?: UserConfig | null, extraLocales?: string[] | false) => Promise<SSRConfig>;
export {};
