<script setup>
import { ref, watch } from 'vue';
import WootMessageEditor from 'dashboard/components/widgets/WootWriter/Editor.vue';
import { MESSAGE_SIGNATURE_EDITOR_MENU_OPTIONS } from 'dashboard/constants/editor';
import NextButton from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  messageSignature: {
    type: String,
    default: '',
  },
});

const emit = defineEmits(['updateSignature']);
const customEditorMenuList = MESSAGE_SIGNATURE_EDITOR_MENU_OPTIONS;
const signature = ref(props.messageSignature);
watch(
  () => props.messageSignature ?? '',
  newValue => {
    signature.value = newValue;
  }
);

const updateSignature = () => {
  emit('updateSignature', signature.value);
};
</script>


