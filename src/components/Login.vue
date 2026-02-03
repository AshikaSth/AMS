<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useToast } from 'vue-toastification'
import { api } from '@/api/base_api'

import { Card, CardHeader, CardTitle, CardContent, CardFooter } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

import { Mail, Lock, Eye, EyeOff, Home } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'
import { loginFormSchema } from '@/schema/loginFormSchema'
const router = useRouter()
const toast = useToast()
const authStore = useAuthStore()

const errors = reactive({})
const visible = ref(false)
const form = reactive({
  email: '',
  password: '',
})

const handleSubmit = async () => {
  Object.keys(errors).forEach((key) => (errors[key] = ''))

  const result = loginFormSchema.safeParse(form)
  console.log('Zod result:', result)

  if (!result.success) {
    result.error.issues.forEach((err) => {
      errors[err.path[0]] = err.message
    })
    toast.error('Please fix the validation errors.')
    return
  }

  try {
    const response = await api.post('login', {
      email: form.email,
      password: form.password,
    })
    const userData = response.data.user
    authStore.login(userData)
    console.log('Login successful', response.data)
    console.log(authStore)
    router.push('/dashboard')
    toast.success('Login successful!')
  } catch (error) {
    toast.error('Login failed')
    console.error(error)
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
      <Home/>
    </RouterLink>
    <Card class="w-full max-w-md shadow-lg bg-white border-2 border-white">
      <CardHeader class="text-center">
        <CardTitle class="text-2xl text-indigo-700">Log in to your account</CardTitle>
      </CardHeader>

      <CardContent class="space-y-4">
        <!-- Email -->
        <div class="flex flex-col">
          <label class="text-sm font-medium text-gray-700 mb-1">Email</label>
          <div class="relative">
            <Input
              v-model="form.email"
              placeholder="Email address"
              type="email"
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

        <div class="text-right">
          <a href="#" class="text-sm text-indigo-600 hover:underline">Forgot password?</a>
        </div>
      </CardContent>

      <CardFooter class="flex flex-col gap-2">
        <Button class="w-full" variant="default" @click.prevent="handleSubmit">Log In</Button>
        <div class="text-center text-gray-600 text-sm mt-2">
          Don't have an account?
          <router-link to="/register" class="text-indigo-600 font-medium hover:underline ml-1">
            Sign up now →
          </router-link>
        </div>
      </CardFooter>
    </Card>
  </div>
</template>
