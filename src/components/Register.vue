<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { api } from '@/api/base_api'
import { registerFormSchema } from '@/schema/registerFormSchema'
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Mail, Lock, Eye, EyeOff, Phone, Calendar, MapPin, User, HomeIcon, LucideHome } from 'lucide-vue-next'
const router = useRouter()
const toast = useToast()
const visible = ref(false)
const errors = reactive({})
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
})

const handleSubmit = async () => {
  Object.keys(errors).forEach((key) => (errors[key] = ''))

  const result = registerFormSchema.safeParse(form)
  console.log('Zod result:', result)

  if (!result.success) {
    result.error.issues.forEach((err) => {
      errors[err.path[0]] = err.message
    })
    toast.error('Please fix the validation errors.')
    return
  }

  try {
    const response = await api.post('register', { user: form })
    console.log('Register successful', response.data)
    toast.success('Registration successful!')
    router.push('/login')
  } catch (error) {
    if (error.response?.data?.errors) {
    Object.keys(errors).forEach((key) => (errors[key] = ''))
    error.response.data.errors.forEach(err => {
      const field = err.field.includes('.') ? err.field.split('.')[1] : err.field
      errors[field] = err.message
    })
    toast.error('Please fix the highlighted errors.')} else {
    toast.error('Registration failed. Please try again.')
  }
  }
}
</script>

<template>
  <div class="h-screen flex items-center justify-center bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500">
    <RouterLink to="/"
        class="absolute top-8 left-8 text-white/90 font-medium text-sm transition-colors hover:text-white hover:underline z-10 flex items-center gap-1"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
      </svg>
      <HomeIcon/>
    </RouterLink>
    <Card class="w-full max-w-md shadow-lg  bg-gray-50 " >
      <CardHeader class="text-center">
        <CardTitle class="text-2xl text-indigo-700">Create an account</CardTitle>
      </CardHeader>

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
            <option value="female">Female</option>
            <option value="male">Male</option>
            <option value="male">Others</option>
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

      <CardFooter class="flex flex-col gap-2">
        <Button class="w-full" variant="default" @click.prevent="handleSubmit">Register</Button>
        <div class="text-center text-gray-600 text-sm mt-2">
          Already have an account?
          <router-link to="/login" class="text-indigo-600 font-medium hover:underline ml-1">
            Log in →
          </router-link>
        </div>
      </CardFooter>
    </Card>
  </div>
</template>
