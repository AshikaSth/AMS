<script setup>
import { ref, onMounted } from 'vue';
import { api } from '@/api/base_api';
import { useToast } from 'vue-toastification';
import DeleteDialog from '@/components/DeleteDialog.vue';
import AlbumForm from '@/components/AlbumForm.vue';
const pagination = ref({ current_page: 1, total_pages: 1 })

const toast = useToast();
const albums = ref([]);
const showDialog = ref(false); 
const albumToEdit = ref(null)

const fetchAlbums = async (page=1) => {
  try {
    const response = await api.get('albums', { params: { page } })
    albums.value = response.data.albums
    pagination.value = response.data.meta
    console.log('Albums data fetched successfully', response.data);
  } catch (error) {
    toast.error('Albums data fetch failed');
    console.error(error);
  }
};

const handleAlbumSaved = () => {
  showDialog.value = false
  albumToEdit.value = null
  toast.success('Album saved successfully!')
  fetchAlbums()
}

onMounted(() => {
  fetchAlbums();
});

const openEditDialog = (album) => {
  albumToEdit.value = album
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  albumToEdit.value = null
}
</script>

<template>
  <div class="bg-gray-100 p-6">
    <div class="flex justify-between mb-6">
      <h1 class="text-3xl font-bold">Albums</h1>
      <button class="bg-indigo-600 text-white px-4 py-2 rounded-lg" @click="showDialog = true; albumToEdit = null">
        + Add Album
      </button>
    </div>

    <div v-if="!albums.length" class="text-center text-gray-500 py-10">
      There are no albums present.
    </div>
    <div v-else>
    <table class="w-full bg-white shadow rounded-2xl overflow-hidden">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-4 py-2 text-left min-w-[50px]">S.N.</th>
          <th class="px-4 py-2 text-left min-w-[50px]">ID</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Name</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Release Date</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Cover Art</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Artists</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Music</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Genres</th>
          <th class="px-4 py-2 text-left min-w-[50px]">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(album , index)  in albums" :key="album.id" class="border-t">
          <td class="px-4 py-2">{{ index +1 }}.</td>
          <td class="px-4 py-2">{{ album.id }}</td>
          <td class="px-4 py-2">{{ album.name }}</td>
          <td class="px-4 py-2">{{ album.release_date }}</td>
          <td class="px-4 py-2">
            <img
              v-if="album.cover_art_url"
              :src="`http://localhost:3000${album.cover_art_url}`"
              :alt="album.name"
              class="w-16 h-16 object-cover rounded"
              @error="() => toast.error(`Failed to load cover art for ${album.name}`)"
            />
            <span v-else>N/A</span>
          </td>
          <td class="px-4 py-2">
            <span v-for="(name, index) in album.artist_names" :key="index" class="mr-2">
              {{ name }}
            </span>
            <span v-if="!album.artist_names?.length">N/A</span>
          </td>
          <td class="px-4 py-2">
            <span v-for="(music, index) in album.musics" :key="music.id" class="mr-2">
            {{ index +1 }}. {{music.title }}
            </span>
            <span v-if="!album.musics?.length">N/A</span>
          </td>
          <td class="px-4 py-2">
            <span v-for="(genre, index) in album.genres" :key="genre.id" class="mr-2">{{ index + 1 }}. {{ genre.name}}</span>
            <span v-if="!album.genres?.length">N/A</span>
          </td>
          <td class="px-4 py-2">
            <button class="text-blue-600 mr-2" @click="openEditDialog(album)">Edit</button>
            <DeleteDialog
              resource-name="Album"
              :delete-url="`albums/${album.id}`"
              @deleted="fetchAlbums"
            />
          </td>
        </tr>
      </tbody>
    </table>
     <div class="flex justify-center mt-4" v-if="pagination.total_pages > 1">
        <button
          class="px-3 py-1 bg-gray-200 rounded mr-2"
          :disabled="pagination.current_page <= 1"
          @click="fetchUsers(pagination.current_page - 1)"
        >
          Previous
        </button>

        <span class="px-3 py-1">{{ pagination.current_page }} / {{ pagination.total_pages }}</span>

        <button
          class="px-3 py-1 bg-gray-200 rounded ml-2"
          :disabled="pagination.current_page >= pagination.total_pages"
          @click="fetchUsers(pagination.current_page + 1)"
        >
          Next
        </button>
      </div>
      </div>

    <AlbumForm
      v-if="showDialog"
      :album-to-edit="albumToEdit"
      @saved="handleAlbumSaved"
      @close="closeDialog"
    />
  </div>
</template>