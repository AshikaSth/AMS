<script setup>
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import Button from "@/components/ui/button/Button.vue"
import { Trash } from "lucide-vue-next"
import { api } from "@/api/base_api"
import { useToast } from "vue-toastification"

const props = defineProps({
  resourceName: {
    type: String,
    required: true,
  },
  deleteUrl: {
    type: String,
    required: true,
  },
})

const emit = defineEmits(["deleted"])
const toast = useToast()

const handleDelete = async () => {
  try {
    await api.delete(props.deleteUrl)
    toast.success(`${props.resourceName} deleted successfully!`)
    emit("deleted")
  } catch (error) {
    toast.error(`Failed to delete ${props.resourceName}`)
    console.error(error)
  }
}
</script>

<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <button size="icon" class="text-red-600 hover:bg-red-100">
        <Trash/>
      </button>
    </AlertDialogTrigger>

    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>
          Delete {{ resourceName }}?
        </AlertDialogTitle>
        <AlertDialogDescription>
          This action cannot be undone. This will permanently delete the
          {{ resourceName.toLowerCase() }} and remove its data from our servers.
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>Cancel</AlertDialogCancel>
        <AlertDialogAction @click="handleDelete">
          Continue
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
