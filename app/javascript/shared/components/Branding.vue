<script>
import globalConfigMixin from 'shared/mixins/globalConfigMixin';

const {
  LOGO_THUMBNAIL: logoThumbnail,
  BRAND_NAME: brandName,
  WIDGET_BRAND_URL: widgetBrandURL,
} = window.globalConfig || {};

export default {
  mixins: [globalConfigMixin],
  props: {
    disableBranding: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      globalConfig: {
        brandName,
        logoThumbnail,
        widgetBrandURL,
      },
    };
  },
  computed: {
    brandRedirectURL() {
      try {
        const referrerHost = this.$store.getters['appConfig/getReferrerHost'];
        const baseURL = `${this.globalConfig.widgetBrandURL}?utm_source=${
          referrerHost ? 'widget_branding' : 'survey_branding'
        }`;
        if (referrerHost) {
          return `${baseURL}&utm_referrer=${referrerHost}`;
        }
        return baseURL;
      } catch (e) {
        // Suppressing the error as getter is not defined in some cases
      }
      return '';
    },
  },
};
</script>

<template>
  <div
    v-if="globalConfig.brandName && !disableBranding"
    class="px-0 py-3 flex justify-center"
  >
    <a
      :href="brandRedirectURL"
      rel="noreferrer noopener nofollow"
      target="_blank"
      class="branding--link text-n-slate-11 hover:text-n-slate-12 cursor-pointer text-xs inline-flex grayscale-[1] hover:grayscale-0 hover:opacity-100 opacity-90 no-underline justify-center items-center leading-3"
    >

      <svg 
        class="ltr:mr-1 rtl:ml-1 max-w-3 max-h-3"
        :alt="globalConfig.brandName"
        width="696" height="696" viewBox="0 0 696 696" fill="none" xmlns="http://www.w3.org/2000/svg">
        <g clip-path="url(#clip0_1979_644)">
        <path d="M347.56 695.12C539.512 695.12 695.12 539.512 695.12 347.56C695.12 155.608 539.512 0 347.56 0C155.608 0 0 155.608 0 347.56C0 539.512 155.608 695.12 347.56 695.12Z" fill="black"/>
        <path d="M534.21 304.56C523.59 243.83 476.29 193.43 417.87 175.23C386.82 166.47 354.68 162.98 322.79 169.51C276.61 176.23 233.37 203.15 207.31 241.88C165.96 300.6 167.18 386.49 210.41 443.9C231.93 474.03 263.18 494.78 298.04 506.48C334.59 517.39 375.4 517.8 412.21 507.92C452.19 496.34 487.55 471.4 510.26 436.32C535.91 398.55 542.66 348.79 534.21 304.56ZM427.43 398.04C398.58 438.85 332.35 443.13 297.08 408.66C284.9 397.91 277.19 382.31 272.39 366.99C267.47 342.3 268.01 315.57 281.28 293.37C292.57 271.98 312.52 258.61 335.52 252.37C369.93 243 411.25 257.52 430.56 288C453.07 321.2 451.54 366.1 427.43 398.04Z" fill="white"/>
        <path d="M200.17 428.449L174.83 520.459L272.02 495.679L200.17 428.459V428.449Z" fill="white"/>
        </g>
        <defs>
        <clipPath id="clip0_1979_644">
        <rect width="695.12" height="695.12" fill="white"/>
        </clipPath>
        </defs>
      </svg>

      <span>
        {{ useInstallationName($t('POWERED_BY'), globalConfig.brandName) }}
      </span>
    </a>
  </div>
  <div v-else class="p-3" />
</template>
