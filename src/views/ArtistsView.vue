<script setup>
import { api } from '@/api/base_api'
import { ref, onMounted } from 'vue'
import { useToast } from 'vue-toastification'
import ArtistForm from '@/components/ArtistForm.vue'
import Button from '@/components/ui/button/Button.vue'
import { Edit2Icon, EditIcon, FileDownIcon, FileIcon, FileUpIcon } from 'lucide-vue-next'
import DeleteDialog from '@/components/DeleteDialog.vue'
const toast = useToast()
const artists = ref([])
const showDialog = ref(false)
const artistToEdit = ref(null)
const pagination = ref({ current_page: 1, total_pages: 1 })

const fetchArtists = async (page = 1) => {
  try {
    const response = await api.get('artists', { params: { page } })
    artists.value = response.data.artists
    pagination.value = response.data.meta
    console.log('Artists data fetched Successfully', response.data)
  } catch (error) {
    toast.error('Artists data fetch failed')
    console.error(error)
  }
}

onMounted(() => {
  fetchArtists()
})

const handleArtistSaved = () => {
  showDialog.value = false
  artistToEdit.value = null
  toast.success('Artist saved successfully!')
  fetchArtists()
}

const openEditDialog = (artist) => {
  artistToEdit.value = artist
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  artistToEdit.value = null
}

const handleCSVExport = async () => {
  console.log('.csv file ')

  try {
    const response = await api.get('artists/csv_export', { responseType: 'blob' })
    const blob = new Blob([response.data], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)

    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'artists.csv')
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    toast.success('CSV Export successful!')
  } catch (error) {
    toast.error('CSV Export failed')
    console.error(error)
  }
}

const csvFileInput = ref(null)
const handleCSVImport = async () => {
  const file = event.target.files[0]
  if (!file) return

  const formData = new FormData()
  formData.append('file', file)

  try {
    await api.post('artists/csv_import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    toast.success('CSV Import successful!')
    fetchArtists()
  } catch (error) {
    toast.error('CSV Import failed')
    console.error(error)
  }
}
</script>

<template>
  <body class="bg-gray-100 p-6">
    <div class="flex justify-between mb-6">
      <h1 class="text-3xl font-bold">Artists</h1>
      <div class="flex mb-6 gap-5">
        <Button variant="primary" class="bg-indigo-600 text-white px-4 py-2 rounded-lg" @click="showDialog = true">
          + Add Artist
        </Button>
        <input type="file" accept=".csv" ref="csvFileInput" class="hidden" @change="handleCSVImport" />
        <Button variant="primary" class="border-2 border-indigo-600 text-indigo-600 px-4 py-2 rounded-lg flex items-center space-x-2" @click="$refs.csvFileInput.click()">
          <FileDownIcon class="w-4 h-4" />
          <span>CSV Import</span>
        </Button>
        <Button variant="primary" class="bg-gray-600 text-white px-4 py-2 rounded-lg" @click="handleCSVExport">
          <FileDownIcon /> CSV Export
        </Button>
      </div>
    </div>

    <div v-if="!artists.length" class="text-center text-gray-500 py-10">
      There are no artists present.
    </div>

    <div v-else>
      <div class="overflow-x-auto rounded-lg shadow bg-white max-h-[75vh]">
        <table class="w-full ">
          <thead class="bg-gray-50 sticky top-0"> 
            <tr>
              <th class="px-4 py-2 text-left min-w-[50px]">S.N.</th>
              <th class="px-4 py-2 text-left min-w-[50px]">ID</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Name</th>
              <th class="px-4 py-2 text-left min-w-[50px]">First Release year</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Bio</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Website</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Genres</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Manager</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Social Media Links</th>
              <th class="px-4 py-2 text-left min-w-[50px]">No of Albums Released</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Photo</th>
              <th class="px-4 py-2 text-left min-w-[50px]">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="(artist, index) in artists" :key="artist.id" class="border-t">
              <td class="px-4 py-2">{{ index + 1 }}</td>
              <td class="px-4 py-2">{{ artist.id }}</td>
              <td class="px-4 py-2">{{ artist.user.first_name }} {{ artist.user.last_name }}</td>
              <td class="px-4 py-2">{{ artist.first_release_year }}</td>
              <td class="px-4 py-2">{{ artist.bio }}</td>
              <td class="px-4 py-2">
                <a :href="artist.website" target="_blank" class="text-indigo-600 hover:underline">{{ artist.website }}</a>
              </td>
              <td class="px-4 py-2">
                <span v-for="(genre, i) in artist.genres" :key="genre.id">{{ genre.name }}{{ i < artist.genres.length - 1 ? ',' : '' }}</span>
              </td>
              <td class="px-4 py-2">{{ artist.manager ? `${artist.manager.first_name} ${artist.manager.last_name}` : 'N/A' }}</td>
              <td class="px-4 py-2">
                <a v-if="artist.social_media_links" :href="artist.social_media_links" target="_blank" class="text-indigo-600 hover:underline">{{ artist.social_media_links }}</a>
                <span v-else>N/A</span>
              </td>
              <td class="px-4 py-2">{{ artist.no_of_albums_released }}</td>
              <td class="px-4 py-2">
                <img v-if="artist.photo_url" :src="`http://localhost:3000${artist.photo_url}`" :alt="artist.user.first_name" class="w-16 h-16 object-cover rounded" />
                <span v-else>N/A</span>
              </td>
              <td class="px-4 py-2 flex space-x-2">
                <button class="text-blue-600 hover:bg-blue-100" @click="openEditDialog(artist)">
                  <EditIcon />
                </button>
                <DeleteDialog resource-name="Artist" :delete-url="`artists/${artist.id}`" @deleted="fetchArtists" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="flex justify-center mt-4 space-x-2 flex-wrap" v-if="pagination.total_pages > 1">
        <button
          class="px-3 py-1 bg-gray-200 rounded"
          :disabled="pagination.current_page <= 1"
          @click="fetchArtists(pagination.current_page - 1)"
        >
          Previous
        </button>
        <span class="px-3 py-1">{{ pagination.current_page }} / {{ pagination.total_pages }}</span>
        <button
          class="px-3 py-1 bg-gray-200 rounded"
          :disabled="pagination.current_page >= pagination.total_pages"
          @click="fetchArtists(pagination.current_page + 1)"
        >
          Next
        </button>
      </div>
    </div>

    <ArtistForm
      v-if="showDialog"
      :artist-to-edit="artistToEdit"
      @saved="handleArtistSaved"
      @close="showDialog = false"
    />
  </body>
</template>
