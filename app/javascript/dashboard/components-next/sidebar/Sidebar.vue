<script setup>
import { h, computed, onMounted } from 'vue';
import { provideSidebarContext } from './provider';
import { useAccount } from 'dashboard/composables/useAccount';
import { useKbd } from 'dashboard/composables/utils/useKbd';
import { useMapGetter } from 'dashboard/composables/store';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useStorage } from '@vueuse/core';
import { useSidebarKeyboardShortcuts } from './useSidebarKeyboardShortcuts';

import Button from 'dashboard/components-next/button/Button.vue';
import SidebarGroup from './SidebarGroup.vue';
import SidebarProfileMenu from './SidebarProfileMenu.vue';
import ChannelLeaf from './ChannelLeaf.vue';
import SidebarAccountSwitcher from './SidebarAccountSwitcher.vue';
import ComposeConversation from 'dashboard/components-next/NewConversation/ComposeConversation.vue';

const emit = defineEmits([
  'closeKeyShortcutModal',
  'openKeyShortcutModal',
  'showCreateAccountModal',
]);

const { accountScopedRoute } = useAccount();
const store = useStore();
const searchShortcut = useKbd([`$mod`, 'k']);
const { t } = useI18n();

const toggleShortcutModalFn = show => {
  if (show) {
    emit('openKeyShortcutModal');
  } else {
    emit('closeKeyShortcutModal');
  }
};

useSidebarKeyboardShortcuts(toggleShortcutModalFn);

// We're using localStorage to store the expanded item in the sidebar
// This helps preserve context when navigating between portal and dashboard layouts
// and also when the user refreshes the page
const expandedItem = useStorage(
  'next-sidebar-expanded-item',
  null,
  sessionStorage
);

const setExpandedItem = name => {
  expandedItem.value = expandedItem.value === name ? null : name;
};
provideSidebarContext({
  expandedItem,
  setExpandedItem,
});

const inboxes = useMapGetter('inboxes/getInboxes');
const labels = useMapGetter('labels/getLabelsOnSidebar');
const teams = useMapGetter('teams/getMyTeams');
const contactCustomViews = useMapGetter('customViews/getContactCustomViews');
const conversationCustomViews = useMapGetter(
  'customViews/getConversationCustomViews'
);

onMounted(() => {
  store.dispatch('labels/get');
  store.dispatch('inboxes/get');
  store.dispatch('notifications/unReadCount');
  store.dispatch('teams/get');
  store.dispatch('attributes/get');
  store.dispatch('customViews/get', 'conversation');
  store.dispatch('customViews/get', 'contact');
});

const sortedInboxes = computed(() =>
  inboxes.value.slice().sort((a, b) => a.name.localeCompare(b.name))
);

const newReportRoutes = () => [
  {
    name: 'Reports Agent',
    label: t('SIDEBAR.REPORTS_AGENT'),
    to: accountScopedRoute('agent_reports_index'),
    activeOn: ['agent_reports_show'],
  },
  {
    name: 'Reports Label',
    label: t('SIDEBAR.REPORTS_LABEL'),
    to: accountScopedRoute('label_reports_index'),
  },
  {
    name: 'Reports Inbox',
    label: t('SIDEBAR.REPORTS_INBOX'),
    to: accountScopedRoute('inbox_reports_index'),
    activeOn: ['inbox_reports_show'],
  },
  {
    name: 'Reports Team',
    label: t('SIDEBAR.REPORTS_TEAM'),
    to: accountScopedRoute('team_reports_index'),
    activeOn: ['team_reports_show'],
  },
];

const reportRoutes = computed(() => newReportRoutes());

const menuItems = computed(() => {
  return [
    {
      name: 'Inbox',
      label: t('SIDEBAR.INBOX'),
      icon: 'i-lucide-inbox',
      to: accountScopedRoute('inbox_view'),
      activeOn: ['inbox_view', 'inbox_view_conversation'],
      getterKeys: {
        badge: 'notifications/getHasUnreadNotifications',
      },
    },
    {
      name: 'Conversation',
      label: t('SIDEBAR.CONVERSATIONS'),
      icon: 'i-lucide-message-circle',
      children: [
        {
          name: 'All',
          label: t('SIDEBAR.ALL_CONVERSATIONS'),
          activeOn: ['inbox_conversation'],
          to: accountScopedRoute('home'),
        },
        {
          name: 'Mentions',
          label: t('SIDEBAR.MENTIONED_CONVERSATIONS'),
          activeOn: ['conversation_through_mentions'],
          to: accountScopedRoute('conversation_mentions'),
        },
        {
          name: 'Unattended',
          activeOn: ['conversation_through_unattended'],
          label: t('SIDEBAR.UNATTENDED_CONVERSATIONS'),
          to: accountScopedRoute('conversation_unattended'),
        },
        {
          name: 'Folders',
          label: t('SIDEBAR.CUSTOM_VIEWS_FOLDER'),
          icon: 'i-lucide-folder',
          activeOn: ['conversations_through_folders'],
          children: conversationCustomViews.value.map(view => ({
            name: `${view.name}-${view.id}`,
            label: view.name,
            to: accountScopedRoute('folder_conversations', { id: view.id }),
          })),
        },
        {
          name: 'Teams',
          label: t('SIDEBAR.TEAMS'),
          icon: 'i-lucide-users',
          activeOn: ['conversations_through_team'],
          children: teams.value.map(team => ({
            name: `${team.name}-${team.id}`,
            label: team.name,
            to: accountScopedRoute('team_conversations', { teamId: team.id }),
          })),
        },
        {
          name: 'Channels',
          label: t('SIDEBAR.CHANNELS'),
          icon: 'i-lucide-mailbox',
          activeOn: ['conversation_through_inbox'],
          children: sortedInboxes.value.map(inbox => ({
            name: `${inbox.name}-${inbox.id}`,
            label: inbox.name,
            to: accountScopedRoute('inbox_dashboard', { inbox_id: inbox.id }),
            component: leafProps =>
              h(ChannelLeaf, {
                label: leafProps.label,
                active: leafProps.active,
                inbox,
              }),
          })),
        },
        {
          name: 'Labels',
          label: t('SIDEBAR.LABELS'),
          icon: 'i-lucide-tag',
          activeOn: ['conversations_through_label'],
          children: labels.value.map(label => ({
            name: `${label.title}-${label.id}`,
            label: label.title,
            icon: h('span', {
              class: `size-[12px] ring-1 ring-n-alpha-1 dark:ring-white/20 ring-inset rounded-sm`,
              style: { backgroundColor: label.color },
            }),
            to: accountScopedRoute('label_conversations', {
              label: label.title,
            }),
          })),
        },
      ],
    },
    {
      name: 'Reports',
      label: t('SIDEBAR.REPORTS'),
      icon: 'i-lucide-chart-spline',
      children: [
        {
          name: 'Report Overview',
          label: t('SIDEBAR.REPORTS_OVERVIEW'),
          to: accountScopedRoute('account_overview_reports'),
        },
        {
          name: 'Report Conversation',
          label: t('SIDEBAR.REPORTS_CONVERSATION'),
          to: accountScopedRoute('conversation_reports'),
        },
      ],
    },

    {
      name: 'Settings',
      label: t('SIDEBAR.SETTINGS'),
      icon: 'i-lucide-bolt',
      children: [
        {
          name: 'Settings Account Settings',
          label: t('SIDEBAR.ACCOUNT_SETTINGS'),
          icon: 'i-lucide-briefcase',
          to: accountScopedRoute('general_settings_index'),
        },
        {
          name: 'Settings Agents',
          label: t('SIDEBAR.AGENTS'),
          icon: 'i-lucide-square-user',
          to: accountScopedRoute('agent_list'),
        },
        {
          name: 'Settings Inboxes',
          label: t('SIDEBAR.INBOXES'),
          icon: 'i-lucide-inbox',
          to: accountScopedRoute('settings_inbox_list'),
        },
        {
          name: 'Settings Labels',
          label: t('SIDEBAR.LABELS'),
          icon: 'i-lucide-tags',
          to: accountScopedRoute('labels_list'),
        },
         {
          name: 'Settings Automation',
          label: t('SIDEBAR.AUTOMATION'),
          icon: 'i-lucide-workflow',
          to: accountScopedRoute('automation_list'),
        },
      ],
    },
  ];
});
</script>

<template>
  <aside
    class="w-[200px] bg-n-solid-2 rtl:border-l ltr:border-r border-n-weak h-screen flex flex-col text-sm pb-1"
  >
    <section class="grid gap-2 mt-2 mb-4">
      <div class="flex items-center min-w-0 gap-2 px-2">
        <div class="grid flex-shrink-0 place-content-center">
          <svg width="20" height="20" viewBox="0 0 696 696" fill="none" xmlns="http://www.w3.org/2000/svg">
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
        </div>
        <div class="flex-shrink-0 w-px h-3 bg-n-strong" />
        <SidebarAccountSwitcher
          class="flex-grow min-w-0 -mx-1"
          @show-create-account-modal="emit('showCreateAccountModal')"
        />
      </div>
      <div class="flex gap-2 px-2">
        <RouterLink
          :to="{ name: 'search' }"
          class="flex items-center w-full gap-2 px-2 py-1 rounded-lg h-7 outline outline-1 outline-n-weak bg-n-solid-3 dark:bg-n-black/30"
        >
          <span class="flex-shrink-0 i-lucide-search size-4 text-n-slate-11" />
          <span class="flex-grow text-left">
            {{ t('COMBOBOX.SEARCH_PLACEHOLDER') }}
          </span>
          <span
            class="hidden tracking-wide pointer-events-none select-none text-n-slate-10"
          >
            {{ searchShortcut }}
          </span>
        </RouterLink>
        <ComposeConversation align-position="right">
          <template #trigger="{ toggle }">
            <Button
              icon="i-lucide-pen-line"
              color="slate"
              size="sm"
              class="!h-7 !bg-n-solid-3 dark:!bg-n-black/30 !outline-n-weak !text-n-slate-11"
              @click="toggle"
            />
          </template>
        </ComposeConversation>
      </div>
    </section>
    <nav class="grid flex-grow gap-2 px-2 pb-5 overflow-y-scroll no-scrollbar">
      <ul class="flex flex-col gap-1.5 m-0 list-none">
        <SidebarGroup
          v-for="item in menuItems"
          :key="item.name"
          v-bind="item"
        />
      </ul>
    </nav>
    <section
      class="p-1 border-t border-n-weak shadow-[0px_-2px_4px_0px_rgba(27,28,29,0.02)] flex-shrink-0 flex justify-between gap-2 items-center"
    >
      <SidebarProfileMenu
        @open-key-shortcut-modal="emit('openKeyShortcutModal')"
      />
    </section>
  </aside>
</template>
