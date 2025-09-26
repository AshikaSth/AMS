<script setup>
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'
import { useRouter } from 'vue-router'
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
import Button from '../ui/button/Button.vue'
import { LogOut } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const toast = useToast()
const auth = useAuthStore()
const handleLogout = async () => {
  console.log('Logout button clicked')
  try {
    const response = await api.delete('logout')
    toast.success('Logout successful!')
    console.log('Logout successful!', response.data)
    auth.logout()
    router.push('/')
  } catch (error) {
    toast.error('Logout failed')
    if (error.response) {
      console.error('Logout failed:', error.response.data)

      console.error('Status code:', error.response.status)
    } else if (error.request) {
      console.error('Logout failed: No response received', error.request)
    } else {
      console.error('Logout failed:', error.message)
    }
  }
}
</script>

<template>
  

  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="ghost" size="icon" class="text-white">
    <LogOut class="h-5 w-5" />
  </Button >
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Are you absolutely sure you want to log out?</AlertDialogTitle>
        <AlertDialogDescription>
          
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>Cancel</AlertDialogCancel>
        <AlertDialogAction  @click.prevent="handleLogout" >Continue</AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
