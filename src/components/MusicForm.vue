<script setup>
import { ref, reactive, watch, onMounted } from 'vue';
import { api } from '@/api/base_api';
import { useToast } from 'vue-toastification';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from './ui/dialog';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { useArtists } from '@/components/composables/artistsFetch';
import { useAuthStore } from '@/stores/auth';
import { useAlbums } from '@/components/composables/albumFetch';

const props = defineProps({
  musicToEdit: Object
});
const emit = defineEmits(['saved', 'close']);

const toast = useToast();
const authStore = useAuthStore();
const currentUser = authStore.user;
const { albums, fetchAlbums } = useAlbums();
const { allArtists, fetchAllArtists } = useArtists();

const form = ref({
  title: '',
  artist_ids: [],
  album_ids: [],
  genres: [],
  cover_art: null,
  audio: null,
});

const photoFile = ref(null);
const audioFile = ref(null);
const errors = reactive({});
const isLoading = ref(false);

const handleCoverArtChange = (e) => {
  if (!e.target.files.length) return;
  photoFile.value = e.target.files[0];
  form.value.cover_art = photoFile.value;
};

const handleAudioChange = (e) => {
  if (!e.target.files.length) return;
  audioFile.value = e.target.files[0];
  form.value.audio = audioFile.value;
};

const addGenre = () => form.value.genres.push('');
const removeGenre = (index) => form.value.genres.splice(index, 1);

const handleSubmit = async () => {
  if (isLoading.value) return;
  Object.assign(errors, {});

  if (!form.value.title) {
    errors.title = 'Title is required';
    toast.error('Please correct the form errors.');
    return;
  }

  if (currentUser.role !== 'artist') {
    toast.error('Only artists can create songs');
    return;
  }

  isLoading.value = true;

  try {
    const formData = new FormData();
    formData.append('music[title]', form.value.title);
    form.value.artist_ids.forEach(id => formData.append('music[artist_ids][]', id));
    form.value.album_ids.forEach(id => formData.append('music[album_ids][]', id));
    form.value.genres.forEach(genre => formData.append('music[genres][]', genre));

    if (photoFile.value) formData.append('music[cover_art]', photoFile.value);
    if (audioFile.value) formData.append('music[audio]', audioFile.value);

    if (props.musicToEdit) {
      await api.patch(`/musics/${props.musicToEdit.id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
    } else {
      await api.post('/musics', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
    }

    toast.success('Music saved successfully!');
    emit('saved');
  } catch (err) {
    toast.error('Failed to save music');
    console.error(err);
  } finally {
    isLoading.value = false;
  }
};

watch(() => props.musicToEdit, (music) => {
  if (music) {
    form.value.title = music.title || '';
    form.value.artist_ids = music.artists?.map(a => a.id) || [];
    form.value.album_ids = music.album_ids || [];
    form.value.genres = music.genres?.map(g => g.name) || [];
    form.value.cover_art = null;
    form.value.audio = null;
    photoFile.value = null;
    audioFile.value = null;
  } else {
    form.value = { title: '', artist_ids: [], album_ids: [], genres: [], cover_art: null, audio: null };
    photoFile.value = null;
    audioFile.value = null;
  }
}, { immediate: true });

onMounted(() => {
  fetchAllArtists();
  fetchAlbums();
});
</script>

<template>
  <Dialog :open="true" @close="emit('close')">
    <DialogContent class="max-w-lg max-h-[80vh] overflow-y-auto p-6">
      <DialogHeader>
        <DialogTitle>{{ props.musicToEdit ? 'Edit Music' : 'Add New Music' }}</DialogTitle>
      </DialogHeader>

      <div class="space-y-4">
        <Label>Title</Label>
        <Input v-model="form.title" placeholder="Music Title" />
        <span v-if="errors.title" class="text-red-500 text-sm">{{ errors.title }}</span>

        <Label>Artists</Label>
        <Select v-model="form.artist_ids" multiple>
          <SelectTrigger><SelectValue placeholder="Select artists" /></SelectTrigger>
          <SelectContent class="bg-gray-100 ">
            <SelectItem v-for="artist in allArtists" :key="artist.user.id" :value="artist.user.id">
              {{ artist.user.first_name }} {{ artist.user.last_name }}
            </SelectItem>
          </SelectContent>
        </Select>

        <Label>Albums</Label>
          <Select v-model="form.album_ids" multiple>
            <SelectTrigger>
              <SelectValue placeholder="Select albums" />
            </SelectTrigger>
            <SelectContent class="bg-gray-100">
              <SelectItem v-for="album in albums" :key="album.id" :value="album.id">
                {{ album.name }}
              </SelectItem>
            </SelectContent>
          </Select>

        <Label>Genres</Label>
        <div v-for="(genre, index) in form.genres" :key="index" class="flex space-x-2 items-center mb-2">
          <Input v-model="form.genres[index]" placeholder="Genre" class="flex-1" />
          <Button @click="removeGenre(index)" variant="destructive" size="sm">Remove</Button>
        </div>
        <Button @click="addGenre" variant="secondary" size="sm" class="w-full">Add Genre</Button>

        <Label>Cover Art</Label>
        <div v-if="props.musicToEdit?.cover_art_url && !photoFile" class="mb-4">
          <p class="text-sm text-gray-500 mb-2">Current Cover Art:</p>
          <img :src="`http://localhost:3000${props.musicToEdit.cover_art_url}`" class="w-24 h-24 object-cover rounded-md shadow-md" />
        </div>
        <Input type="file" accept="image/*" @change="handleCoverArtChange" />

        <Label>Audio File</Label>
        <Input type="file" accept="audio/*" @change="handleAudioChange" />
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
