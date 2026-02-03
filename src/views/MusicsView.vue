<script setup>
import { ref, onMounted } from 'vue';
import { api } from '@/api/base_api';
import { useToast } from 'vue-toastification';
import MusicForm from '@/components/MusicForm.vue';
import DeleteDialog from '@/components/DeleteDialog.vue';
const pagination = ref({ current_page: 1, total_pages: 1 })

const toast = useToast();
const musics = ref([]);
const showDialog = ref(false);
const musicToEdit = ref(null);

const fetchMusics = async (page=1) => {
  try {
    const response = await api.get('musics', { params: { page } })
    musics.value = response.data.musics
    pagination.value = response.data.meta
    console.log('Musics data fetched Successfully', response.data)
  } catch (err) {
    toast.error('Failed to fetch musics');
    console.error(err);
  }
};

const openEditDialog = (music) => {
  musicToEdit.value = music;
  showDialog.value = true;
};

const handleMusicSaved = () => {
  showDialog.value = false;
  musicToEdit.value = null;
  fetchMusics();
  toast.success('Music saved!');
};

const closeDialog = () => {
  showDialog.value = false;
  musicToEdit.value = null;
};

onMounted(() => {
  fetchMusics();
});
</script>

<template>
  <div class="bg-gray-100 p-6">
    <div class="flex justify-between mb-6">
      <h1 class="text-3xl font-bold">Music</h1>
      <button
        class="bg-indigo-600 text-white px-4 py-2 rounded-lg"
        @click="showDialog = true; musicToEdit = null"
      >
        + Add Music
      </button>

      
    </div>

    <div v-if="!musics.length" class="text-center text-gray-500 py-10">
      There are no albums present.
    </div>

    <table v-else class="w-full bg-white shadow rounded-2xl overflow-hidden">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-4 py-2 text-left">S.N.</th>
          <th class="px-4 py-2 text-left">ID</th>
          <th class="px-4 py-2 text-left">Title</th>
          <th class="px-4 py-2 text-left">Cover Art</th>
          <th class="px-4 py-2 text-left">Audio</th>

          <th class="px-4 py-2 text-left">Artists</th>
          <th class="px-4 py-2 text-left">Albums</th>
          <th class="px-4 py-2 text-left">Genres</th>
          <th class="px-4 py-2 text-left">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(music, index) in musics" :key="music.id" class="border-t">
          <td class="px-4 py-2">{{ index + 1 }}.</td>
          <td class="px-4 py-2">{{ music.id }}</td>
          <td class="px-4 py-2">{{ music.title }}</td>
          <td class="px-4 py-2">
            <img
              v-if="music.cover_art_url"
              :src="`http://localhost:3000${music.cover_art_url}`"
              :alt="music.title"
              class="w-16 h-16 object-cover rounded"
              @error="() => toast.error(`Failed to load cover art for ${music.title}`)"
            />
            <span v-else>N/A</span>
          </td>

          <td class="px-4 py-2">
            <audio
                v-if="music.audio_file_url"
                :src="`http://localhost:3000${music.audio_file_url}`"
                controls
                class="w-48"
              >
                Your browser does not support the audio element.
              </audio>
              <span v-else>N/A</span>
          </td>


          <td class="px-4 py-2">
            <span v-for="(artist, idx) in music.artist_names" :key="idx" class="mr-2">
              {{ artist }}
            </span>
            <span v-if="!music.artist_names?.length">N/A</span>
          </td>
          <td class="px-4 py-2">{{ music.album_ids?.join(', ') || 'N/A' }}</td>
          <td class="px-4 py-2">
            <span v-for="(g, idx) in music.genres" :key="idx" class="mr-2">
              {{ g.name }}
            </span>
            <span v-if="!music.genres?.length">N/A</span>
          </td>
          <td class="px-4 py-2">
            <button class="text-blue-600 mr-2" @click="openEditDialog(music)">Edit</button>
            <DeleteDialog
              resource-name="Music"
              :delete-url="`musics/${music.id}`"
              @deleted="fetchMusics"
            />
          </td>
        </tr>
      </tbody>
    </table>

    <MusicForm
      v-if="showDialog"
      :music-to-edit="musicToEdit"
      @saved="handleMusicSaved"
      @close="closeDialog"
    />
  </div>
</template>
