<script setup>
import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'
import { useAlbums } from '@/components/composables/albumFetch'
import { onMounted, ref } from 'vue'
import { useUsers } from '@/components/composables/userFetch'
import { useArtists } from '@/components/composables/artistsFetch'
import { useMusics } from '@/components/composables/musicFetch'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import Separator from '@/components/ui/separator/Separator.vue'
import Button from '@/components/ui/button/Button.vue'


const authStore = useAuthStore()
const { user } = storeToRefs(authStore)
const { allAlbums, albumcount, allAlbumCount, fetchAlbums, fetchAllAlbums } = useAlbums()
const { usersCount, managersCount, unassignedArtistsCount, users, managers, unassignedArtists, fetchUsers, fetchUnassignedArtists } =
  useUsers()
const {
  artists,
  artistsCount,
  myArtists,
  myArtistCount,
  allArtists,
  allArtistCount,
  fetchArtists,
  fetchAllArtists,
  fetchMyArtists,
} = useArtists()
const { musics,musicCount, allMusics, allMusicCount, fetchMusics, fetchAllMusics } = useMusics()

onMounted(() => {
  fetchUsers(), 
  fetchUnassignedArtists()
  fetchAlbums(), 
  fetchAllAlbums()
  fetchArtists(),
  fetchAllArtists(),
  fetchMyArtists(),
  fetchMusics(), 
  fetchAllMusics()
})

const currentPlaying = ref(null)
const audio = ref(new Audio())

const playMusic = (music) => {
  if (currentPlaying.value?.id === music.id) {
    audio.value.pause()
    currentPlaying.value = null
  } else {
    if (audio.value.src) audio.value.pause()
    audio.value = new Audio(music.audio_file_url)
    audio.value.play()
    currentPlaying.value = music
  }
}
</script>

<template>
  <div class="p-6 max-w-full overflow-hidden">
    <h1 class="text-3xl font-bold">Dashboard</h1>
    <p class="text-lg">Hello, {{ user?.first_name }}</p>


    <Card class="p-6 shadow-md mb-6">
      <h2 class="text-2xl font-semibold text-indigo-700">Welcome to AMS Dashboard</h2>
      <Separator class="my-4" />
      <p class="text-gray-600">Manage users, artists, albums, and musics all in one place.</p>
    </Card>

    <!-- COUNT CARDS -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <Card>
        <CardHeader><CardTitle>Users</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ usersCount }}</p></CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>Managers</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ managersCount }}</p></CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>Unassigned Artists</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ unassignedArtistsCount }}</p></CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>Artists</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ allArtistCount }}</p></CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>Albums</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ allAlbumCount }}</p></CardContent>
      </Card>
      <Card>
        <CardHeader><CardTitle>Musics</CardTitle></CardHeader>
        <CardContent><p class="text-2xl font-bold">{{ allMusicCount }}</p></CardContent>
      </Card>
    </div>

    <Separator/>

    <section>
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold">Users</h2>
        <Button variant="outline">Create Users</Button>
      </div>
      <div class="flex overflow-x-auto gap-4 pb-4">
        <Card
          v-for="user in users"
          :key="user.id"
          class="w-56 flex-shrink-0 relative"
        >
          <CardContent class="flex flex-col items-center text-center space-y-2">
            <Avatar class="w-20 h-20">
              <AvatarImage v-if="user.photo_url" :src="artist.photo_url" />
              <AvatarFallback>{{ user.first_name[0] }}</AvatarFallback>
            </Avatar>
            <p class="font-bold">{{ user.first_name }} {{ user.last_name }}</p>
            
            <div class="flex gap-2 mt-2">
              <Button size="sm">Edit</Button>
              <Button size="sm" variant="destructive">Delete</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>

    <!-- ARTISTS CAROUSEL -->
    <section>
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold">Artists</h2>
        <Button variant="outline">Create Artist</Button>
      </div>
      <div class="flex overflow-x-auto gap-4 pb-4">
        <Card
          v-for="artist in allArtists"
          :key="artist.id"
          class="w-56 flex-shrink-0 relative"
        >
          <CardContent class="flex flex-col items-center text-center space-y-2">
            <Avatar class="w-20 h-20">
              <AvatarImage v-if="artist.photo_url" :src="artist.photo_url" />
              <AvatarFallback>{{ artist.user.first_name[0] }}</AvatarFallback>
            </Avatar>
            <p class="font-bold">{{ artist.user.first_name }} {{ artist.user.last_name }}</p>
            <p class="text-sm text-gray-500 truncate">{{ artist.bio }}</p>
            <div class="flex gap-2 mt-2">
              <Button size="sm">Edit</Button>
              <Button size="sm" variant="destructive">Delete</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>

    <section class="mb-6">
      <div class="flex items-center justify-between mb-2">
        <h2 class="text-xl font-semibold">Albums</h2>
        <Button variant="outline">Create Album</Button>
      </div>
      <div class="flex gap-4 overflow-x-auto py-2 scrollbar-none">
        <Card v-for="album in allAlbums" :key="album.id" class="w-56 flex-shrink-0">
          <CardContent class="flex flex-col items-center text-center space-y-2">
            <Avatar class="w-20 h-20">
              <AvatarImage v-if="album.cover_art_url" :src="album.cover_art_url" />
              <AvatarFallback>{{ album.name[0] }}</AvatarFallback>
            </Avatar>
            <p class="font-bold truncate">{{ album.name }}</p>
            <p class="text-sm text-gray-500 truncate">{{ album.release_date }}</p>
            <div class="flex gap-2 mt-2">
              <Button size="sm">Edit</Button>
              <Button size="sm" variant="destructive">Delete</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>

    <!-- Artists Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-2">
        <h2 class="text-xl font-semibold">Artists</h2>
        <Button variant="outline">Create Artist</Button>
      </div>
      <div class="flex gap-4 overflow-x-auto py-2 scrollbar-none">
        <Card v-for="artist in allArtists" :key="artist.id" class="w-48 flex-shrink-0">
          <CardContent class="flex flex-col items-center text-center space-y-2">
            <Avatar class="w-16 h-16">
              <AvatarImage v-if="artist.photo_url" :src="artist.photo_url" />
              <AvatarFallback>{{ artist.user.first_name[0] }}</AvatarFallback>
            </Avatar>
            <p class="font-bold truncate">{{ artist.user.first_name }} {{ artist.user.last_name }}</p>
            <p class="text-sm text-gray-500 truncate">{{ artist.bio }}</p>
            <div class="flex gap-2 mt-2">
              <Button size="sm">Edit</Button>
              <Button size="sm" variant="destructive">Delete</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>

    <!-- Musics Section -->
    <section class="mb-6">
      <div class="flex items-center justify-between mb-2">
        <h2 class="text-xl font-semibold">Musics</h2>
        <Button variant="outline">Upload Music</Button>
      </div>
      <div class="flex gap-4 overflow-x-auto py-2 scrollbar-none">
        <Card v-for="music in allMusics" :key="music.id" class="w-56 flex-shrink-0">
          <CardContent class="flex flex-col items-center text-center space-y-2">
            <Avatar class="w-20 h-20">
              <AvatarImage v-if="music.cover_art_url" :src="music.cover_art_url" />
              <AvatarFallback>{{ music.title[0] }}</AvatarFallback>
            </Avatar>
            <p class="font-bold truncate">{{ music.title }}</p>
            <p class="text-sm text-gray-500 truncate">Artists: {{ music.artist_names.join(', ') }}</p>
            <div class="flex gap-2 mt-2">
              <Button size="sm" @click="playMusic(music)">
                {{ currentMusic?.id === music.id && isPlaying ? 'Pause' : 'Play' }}
              </Button>
              <Button size="sm" variant="destructive">Delete</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* hide ugly scrollbar for horizontal scroll */
.scrollbar-none::-webkit-scrollbar {
  display: none;
}
.scrollbar-none {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>