<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select'
import { Label } from '@/components/ui/label'
import { useUsers } from './composables/userFetch'
import { useMusics } from './composables/musicFetch'
import { useArtists } from './composables/artistsFetch'
import { useAuthStore } from '@/stores/auth'
import { albumFormSchema } from '@/schema/albumFormSchema'

const props = defineProps({
  albumToEdit: Object,
})
const emit = defineEmits(['saved', 'close'])

const toast = useToast()
const authStore = useAuthStore()
const currentUser = authStore.user

const { users, fetchUsers } = useUsers()
const { musics, fetchMusics } = useMusics()
const { allArtists, fetchAllArtists } = useArtists()

const form = ref({
  name: '',
  release_date: '',
  artist_ids: [],
  music_ids: [],
  genres: [],
  cover_art: null,
})
const photoFile = ref(null)
const errors = reactive({})
const isLoading = ref(false)

const handleFileChange = (e) => {
  if (!e.target.files.length) return
  photoFile.value = e.target.files[0]
  form.value.cover_art = photoFile.value
}

const addGenre = () => form.value.genres.push('')
const removeGenre = (index) => form.value.genres.splice(index, 1)

const handleSubmit = async () => {
  if (isLoading.value) return
  Object.assign(errors, {})

  const result = albumFormSchema.safeParse(form.value)
  if (!result.success) {
    result.error.issues.forEach((err) => (errors[err.path[0]] = err.message))
    toast.error('Please correct the form errors.')
    return
  }

  if (currentUser.role !== 'artist') {
    toast.error('Only artists can create albums')
    return
  }

  isLoading.value = true

  try {
    const formData = new FormData()
    formData.append('album[name]', form.value.name)
    formData.append('album[release_date]', form.value.release_date)
    form.value.artist_ids.forEach((id) => formData.append('album[artist_ids][]', id))
    form.value.music_ids.forEach((id) => formData.append('album[music_ids][]', id))
    form.value.genres.forEach((genre) => formData.append('album[genres][]', genre))
    if (photoFile.value) formData.append('album[cover_art]', photoFile.value)

    if (props.albumToEdit) {
      await api.patch(`/albums/${props.albumToEdit.id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
    } else {
      await api.post('/albums', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    }

    toast.success('Album saved successfully!')
    emit('saved')
  } catch (err) {
    if (err.response && err.response.data && err.response.data.errors) {
      err.response.data.errors.forEach((serverError) => {
        errors[serverError.field] = serverError.message
      })
      toast.error('Failed to save album. Please check the form for errors.')
    } else {
      console.error(err)
      toast.error('An unexpected error occurred.')
    }
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.albumToEdit,
  (album) => {
    if (album) {
      form.value.name = album.name || ''
      form.value.release_date = album.release_date || ''
      form.value.artist_ids = album.artists?.map((a) => a.user?.id).filter(Boolean) || []
      form.value.music_ids = album.musics?.map((m) => m.id).filter(Boolean) || []
      form.value.genres = album.genres?.map((g) => g.name) || []
      form.value.cover_art = null
      photoFile.value = null
    } else {
      form.value = {
        name: '',
        release_date: '',
        artist_ids: [],
        music_ids: [],
        genres: [],
        cover_art: null,
      }
      photoFile.value = null
    }
  },
  { immediate: true },
)

onMounted(() => {
  fetchUsers()
  fetchMusics()
  fetchAllArtists()
})
</script>

<template>
  <Dialog :open="true" @close="emit('close')">
    <DialogContent class="max-w-lg max-h-[80vh] overflow-y-auto p-6">
      <DialogHeader>
        <DialogTitle>{{ props.albumToEdit ? 'Edit Album' : 'Add New Album' }}</DialogTitle>
      </DialogHeader>

      <div class="space-y-4">
        <Input v-model="form.name" placeholder="Album Name" />
        <span v-if="errors.name" class="text-red-500 text-sm">{{ errors.name }}</span>

        <Input v-model="form.release_date" type="date" />
        <span v-if="errors.release_date" class="text-red-500 text-sm">{{
          errors.release_date
        }}</span>

        <div class="space-y-2">
          <Label>Artists</Label>
          <Select v-model="form.artist_ids" multiple>
            <SelectTrigger><SelectValue placeholder="Select artists" /></SelectTrigger>
            <SelectContent class="bg-gray-100">
              <SelectItem v-for="artist in artists" :key="artist.user.id" :value="artist.user.id">
                {{ artist.user.first_name }} {{ artist.user.last_name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>Musics</Label>
          <Select v-model="form.music_ids" multiple>
            <SelectTrigger><SelectValue placeholder="Select musics" /></SelectTrigger>
            <SelectContent class="bg-gray-100">
              <SelectItem v-for="music in musics" :key="music.id" :value="music.id">
                {{ music.title }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>Genres</Label>
          <div
            v-for="(genre, index) in form.genres"
            :key="index"
            class="flex space-x-2 items-center mb-2"
          >
            <Input v-model="form.genres[index]" placeholder="Genre" class="flex-1" />
            <Button @click="removeGenre(index)" variant="destructive" size="sm">Remove</Button>
          </div>
          <Button @click="addGenre" variant="secondary" size="sm" class="w-full">Add Genre</Button>
        </div>

        <div class="space-y-2">
          <Label>Cover Art</Label>
          <div v-if="props.albumToEdit?.cover_art_url && !photoFile" class="mb-4">
            <p class="text-sm text-gray-500 mb-2">Current Cover Art:</p>
            <img
              :src="`http://localhost:3000${props.albumToEdit.cover_art_url}`"
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
