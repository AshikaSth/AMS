<script setup>
import { ref, onMounted, reactive, watch } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'
import { useUsers } from '@/components/composables/userFetch'
import { z } from 'zod'
import { userFormSchema } from '@/schema/userFormSchema'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Label } from '@/components/ui/label'

const emit = defineEmits(['saved', 'close'])
const toast = useToast()
const authStore = useAuthStore()

const props = defineProps({
  userToEdit: {
    type: Object,
    default: null,
  },
})
const form = reactive({
  first_name: '',
  last_name: '',
  email: '',
  password: '',
  password_confirmation: '',
  gender: '',
  address: '',
  phone_number: '',
  dob: '',
  role: '',
})

const isLoading = ref(false)
const errors = reactive({})

const handleSubmit = async () => {
  Object.keys(errors).forEach((key) => (errors[key] = ''))

  const result = userFormSchema.safeParse(form)
  if (!result.success) {
    result.error.issues.forEach((err) => {
      errors[err.path[0]] = err.message
    })
    toast.error('Please fix the validation errors.')
    return
  }

  isLoading.value = true
  try {
    let response
    if (props.userToEdit) {
      response = await api.patch(`users/${props.userToEdit.id}`, { user: form }, {})
    } else {
      response = await api.post('users', { user: form }, {})
    }
    emit('saved')
  } catch (error) {
    
    const { response } = error
    if (response?.data?.errors && Array.isArray(response.data.errors)) {
      response.data.errors.forEach((err) => {
        if (err.field && err.message) {
          errors[err.field] = err.message
        }
        toast.error(err.message)
      })
    } else if (response?.data?.error) {
      toast.error(response.data.error)
    } else {
      toast.error('An unexpected error occurred while saving the user.')
    }
    
    console.error(error)
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.userToEdit,
  (newVal) => {
    if (newVal) {
      Object.assign(form, newVal)
    } else {
      Object.assign(form, {
        first_name: '',
        last_name: '',
        email: '',
        password: '',
        password_confirmation: '',
        gender: '',
        address: '',
        phone_number: '',
        dob: '',
        role: '',
      })
    }
  },
  { immediate: true },
)
</script>

<template>
  <Dialog :open="true" @close="emit('close')">
    <DialogContent class="max-w-lg max-h-[80vh] overflow-y-auto p-6">
      <DialogHeader>
        <DialogTitle>Add New User</DialogTitle>
      </DialogHeader>

      <CardContent class="space-y-4">
        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">First Name</label>
          <div class="relative">
            <Input
              v-model="form.first_name"
              placeholder="First Name"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <User class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.first_name" class="text-sm text-red-500 mt-1">{{ errors.first_name }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Last Name</label>
          <div class="relative">
            <Input
              v-model="form.last_name"
              placeholder="Last Name"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <User class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.last_name" class="text-sm text-red-500 mt-1">{{ errors.last_name }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Email</label>
          <div class="relative">
            <Input
              v-model="form.email"
              type="email"
              placeholder="Email address"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <Mail class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.email" class="text-sm text-red-500 mt-1">{{ errors.email }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Password</label>
          <div class="relative">
            <Input
              v-model="form.password"
              :type="visible ? 'text' : 'password'"
              placeholder="Enter your password"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <button
              type="button"
              @click="visible = !visible"
              class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600"
            >
              <component :is="visible ? EyeOff : Eye" />
            </button>
          </div>
          <p v-if="errors.password" class="text-sm text-red-500 mt-1">{{ errors.password }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Confirm Password</label>
          <div class="relative">
            <Input
              v-model="form.password_confirmation"
              type="password"
              placeholder="Confirm your password"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <Lock class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.password_confirmation" class="text-sm text-red-500 mt-1">
            {{ errors.password_confirmation }}
          </p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Gender</label>
          <select 
            v-model="form.gender"
            class="border rounded-md px-3 py-2 text-sm font-medium text-gray-500"
          >
          <option value="" disabled selected>Select gender</option>
            <option value="female">Female</option>
            <option value="male">Male</option>
            <option value="male">Others</option>
          </select>
          <p v-if="errors.gender" class="text-sm text-red-500 mt-1">{{ errors.gender }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Role</label>
          <select
            v-model="form.role"
            class="border rounded-md px-3 py-2 text-sm font-medium text-gray-500"
          >
          <option value="" disabled selected>Select gender</option>
            <option value="super_admin">Super admin</option>
            <option value="artist_manager">Artist Manager</option>
            <option value="artist">Artist</option>
          </select>
          <p v-if="errors.gender" class="text-sm text-red-500 mt-1">{{ errors.gender }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Address</label>
          <div class="relative">
            <Input
              v-model="form.address"
              placeholder="Address"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <MapPin class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.address" class="text-sm text-red-500 mt-1">{{ errors.address }}</p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Phone Number</label>
          <div class="relative">
            <Input
              v-model="form.phone_number"
              placeholder="Phone Number"
              class="text-sm font-medium text-gray-500 mb-1"
            />
            <Phone class="absolute right-3 top-2.5 text-gray-400" />
          </div>
          <p v-if="errors.phone_number" class="text-sm text-red-500 mt-1">
            {{ errors.phone_number }}
          </p>
        </div>

        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Date of Birth</label>
          <div class="relative">
            <Input v-model="form.dob" type="date" class="text-sm font-medium text-gray-500 mb-1" />
            <Calendar class="absolute right-3 top-2.5 text-gray-400" />
          </div>
        </div>
        <p v-if="errors.dob" class="text-sm text-red-500 mt-1">{{ errors.dob }}</p>
      </CardContent>

      <DialogFooter class="mt-4 flex justify-end space-x-2">
        <Button variant="secondary" @click="emit('close')">Cancel</Button>
        <Button @click="handleSubmit" :disabled="isLoading">
          <span v-if="isLoading">Saving...</span>
          <span v-else>Save</span>
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
