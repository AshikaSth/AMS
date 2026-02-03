<script setup>
import { ref, onMounted, reactive, watch } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'
import { useUsers } from '@/components/composables/userFetch'
import { z } from 'zod'
import { artistFormSchema } from '@/schema/artistFormSchema'
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
const { users, managers, unassignedArtists, isLoading, error, fetchUsers, fetchUnassignedArtists } = useUsers()

const props = defineProps({
  artistToEdit: {
    type: Object,
    default: null,
  },
})

const form = ref({
  first_release_year: '',
  bio: '',
  website: '',
  social_media_links: [],
  genres: [],
  user_id: null,
  manager_id: null,
  photo: null,
})
const photoFile = ref(null)
const errors = reactive({})

const handleFileChange = (event) => {
  photoFile.value = event.target.files[0]
  form.value.photo = photoFile.value
}

const addSocialLink = () => {
  form.value.social_media_links.push({ platform: '', link: '' })
}

const removeSocialLink = (index) => {
  form.value.social_media_links.splice(index, 1)
}

const addGenre = () => {
  form.value.genres.push('')
}

const removeGenre = (index) => {
  form.value.genres.splice(index, 1)
}

const handleSubmit = async () => {
  if (formIsLoading.value) return;

  Object.keys(errors).forEach(key => delete errors[key])

  const result = artistFormSchema.safeParse(form.value)

  if (!result.success) {
    result.error.issues.forEach((err) => {
      if (err.path.length === 1) errors[err.path[0]] = err.message
      if (err.path.length === 3)
        errors[`social_media_links[${err.path[1]}].${err.path[2]}`] = err.message
    })
    toast.error('Please correct the form errors.')
    return
  }

  formIsLoading.value = true
  try {
    const formData = new FormData()
    formData.append('artist[first_release_year]', form.value.first_release_year)
    formData.append('artist[bio]', form.value.bio)
    formData.append('artist[website]', form.value.website)

    const socialMediaObject = form.value.social_media_links.reduce((acc, curr) => {
      if (curr.platform && curr.link) {
        acc[curr.platform] = curr.link
      }
      return acc
    }, {})

    if (Object.keys(socialMediaObject).length > 0) {
      formData.append('artist[social_media_links]', JSON.stringify(socialMediaObject))
    }

    if (form.value.genres.length > 0) {
      form.value.genres.forEach((genre) => {
        formData.append('artist[genres][]', genre)
      })
    }

    if (authStore.user.role === 'super_admin') {
      if (form.value.user_id) {
        formData.append('artist[user_id]', form.value.user_id)
      }
      if (form.value.manager_id) {
        formData.append('artist[manager_id]', form.value.manager_id)
      }
    } else if (authStore.user.role === 'artist_manager') {
      if (form.value.user_id) {
        formData.append('artist[user_id]', form.value.user_id)
      }
    }

    if (photoFile.value) {
      formData.append('artist[photo]', photoFile.value)
    }

    if (props.artistToEdit) {
      await api.patch(`artists/${props.artistToEdit.id}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
    } else {
      await api.post('artists', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })
    }
    emit('saved')
  } catch (error) {
    if (error.response && error.response.data && error.response.data.errors) {
      error.response.data.errors.forEach(err => {
        errors[err.field] = err.message
      })
      toast.error('Failed to save artist. Please check the form for errors.')
    } else {
      toast.error('An unexpected error occurred.')
      console.error(error)
    }
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.artistToEdit,
  (newVal) => {
    if (newVal) {
      form.value = {
        ...newVal,
        genres: newVal.genres?.map((g) => g.name) || [],
        social_media_links: newVal.social_media_links
          ? Object.entries(newVal.social_media_links).map(([platform, link]) => ({
              platform,
              link,
            }))
          : [],
        user_id: newVal.user.id,
        manager_id: newVal.manager?.id || null,
        photo: null,
      }
    } else {
      form.value = {
        first_release_year: '',
        bio: '',
        website: '',
        social_media_links: [],
        genres: [],
        user_id: null,
        manager_id: null,
        photo: null,
      }
    }
  },
  { immediate: true },
)

watch(() => authStore.user, (newVal) => {
  if (newVal) {
    fetchUnassignedArtists()
    if (newVal.role === 'super_admin') {
      fetchUsers()
    }
  }
}, { immediate: true })

onMounted(() => {
  fetchUnassignedArtists()
  if (authStore.user?.role === 'super_admin') {
    fetchUsers()
  }
})
</script>

<template>
  <Dialog :open="true" @close="emit('close')">
    <DialogContent class="max-w-lg max-h-[80vh] overflow-y-auto p-6">
      <DialogHeader>
        <DialogTitle>{{ props.artistToEdit ? 'Edit Artist' : 'Add New Artist' }}</DialogTitle>
      </DialogHeader>

      <div class="space-y-4">
        <Input v-model="form.first_release_year" placeholder="First Release Year" />
        <span v-if="errors.first_release_year" class="text-red-500 text-sm">{{
          errors.first_release_year
        }}</span>

        <Input v-model="form.bio" placeholder="Bio" />
        <span v-if="errors.bio" class="text-red-500 text-sm">{{ errors.bio }}</span>

        <Input v-model="form.website" placeholder="Website" />
        <span v-if="errors.website" class="text-red-500 text-sm">{{ errors.website }}</span>

        <div class="space-y-2">
          <Label>Social Media Links</Label>
          <div
            v-for="(link, index) in form.social_media_links"
            :key="index"
            class="flex space-x-2 items-center"
          >
            <Input v-model="link.platform" placeholder="Platform (e.g., twitter)" class="flex-1" />
            <span
              v-if="errors[`social_media_links[${index}].platform`]"
              class="text-red-500 text-sm"
              >{{ errors[`social_media_links[${index}].platform`] }}</span
            >

            <Input v-model="link.link" placeholder="Link (e.g., https://...)" class="flex-1" />
            <span v-if="errors[`social_media_links[${index}].link`]" class="text-red-500 text-sm">{{
              errors[`social_media_links[${index}].link`]
            }}</span>
            <Button @click="removeSocialLink(index)" variant="destructive" size="sm">Remove</Button>
          </div>
          <Button @click="addSocialLink" variant="secondary" size="sm" class="mt-2 w-full"
            >Add More</Button
          >
        </div>

        <div class="space-y-2">
          <Label>Genres</Label>
          <div
            v-for="(genre, index) in form.genres"
            :key="index"
            class="flex space-x-2 items-center"
          >
            <Input v-model="form.genres[index]" placeholder="Genre (e.g., rock)" class="flex-1" />
            <span v-if="errors[`genres[${index}]`]" class="text-red-500 text-sm">{{
              errors[`genres[${index}]`]
            }}</span>
            <Button @click="removeGenre(index)" variant="destructive" size="sm">Remove</Button>
          </div>
          <Button @click="addGenre" variant="secondary" size="sm" class="mt-2 w-full"
            >Add More</Button
          >
        </div>

        <div
          class="space-y-2"
          v-if="authStore.user?.role === 'super_admin' || authStore.user?.role === 'artist_manager'"
        >
          <Label>Assign to User</Label>
          <Select v-model="form.user_id">
            <SelectTrigger>
              <SelectValue placeholder="Select a user" />
            </SelectTrigger>
            <SelectContent class="bg-gray-100 ">
              <SelectItem v-for="user in unassignedArtists" :key="user.id" :value="user.id">
                {{ user.first_name }} {{ user.last_name }} ({{ user.role }})
              </SelectItem>
            </SelectContent>
          </Select>
          <span v-if="errors.user_id" class="text-red-500 text-sm">{{ errors.user_id }}</span>
        </div>

        <div class="space-y-2" v-if="authStore.user?.role === 'super_admin'">
          <Label>Assign Manager</Label>
          <Select v-model="form.manager_id">
            <SelectTrigger>
              <SelectValue placeholder="Select a manager" />
            </SelectTrigger>
            <SelectContent class="bg-gray-100 ">
              <SelectItem v-for="manager in managers" :key="manager.id" :value="manager.id">
                {{ manager.first_name }} {{ manager.last_name }}
              </SelectItem>
            </SelectContent>
          </Select>
          <span v-if="errors.manager_id" class="text-red-500 text-sm">{{ errors.manager_id }}</span>
        </div>

        <!-- Photo input -->
        <div class="space-y-2">
          <Label>Photo</Label>
          <div v-if="artistToEdit && artistToEdit.photo_url" class="mb-4">
            <p class="text-sm text-gray-500 mb-2">Current Photo:</p>
            <img
              :src="`http://localhost:3000${artistToEdit.photo_url}`"
              alt="Current Artist Photo"
              class="w-24 h-24 object-cover rounded-md shadow-md"
            />
          </div>
          <Input type="file" @change="handleFileChange" />
        </div>
      </div>

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


//didnt get manager data 