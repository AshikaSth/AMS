<script setup>
import { ref } from "vue"
import { RouterLink, RouterView } from "vue-router"
import {Button} from "@/components/ui/button"
import {Card} from "@/components/ui/card"
import {Separator} from "@/components/ui/separator"
import {
  ChevronLeft,
  Home,
  Users,
  Mic,
  Disc,
  Music,
  LogOut,
  ChevronRight,
} from "lucide-vue-next"
import Logout from "./Logout.vue"
import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'

const authStore = useAuthStore()
const { user } = storeToRefs(authStore)
const drawerOpen = ref(true)
const toggleDrawer = () => {
  drawerOpen.value = !drawerOpen.value;
};
</script>


<template>
  <div class="flex h-screen bg-gray-50">
    <aside
      :class="[
        'flex flex-col justify-between transition-all duration-300 bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 text-white text-xl shadow-lg',
        drawerOpen ? 'w-64' : 'w-20'
      ]"
    >
      <div class="flex items-center justify-between p-4">
        <h1 v-if="drawerOpen" class="text-xl font-bold">Artist Management System</h1>
        <Button variant="ghost" size="icon" @click="toggleDrawer">
          <ChevronLeft 
            :class="[
              'h-5 w-5 transition-transform duration-300',
              drawerOpen ? '' : 'rotate-180'
            ]" 
          />
        </Button>
      </div>

      <nav class="flex-1 px-2 space-y-2">
        <RouterLink to="dashboardmain" class="flex items-center gap-3 p-2 rounded-lg hover:bg-indigo-600 transition-colors">
          <Home class="h-6 w-6" />
          <span v-if="drawerOpen" class="truncate">Dashboard</span>
        </RouterLink>

        <template v-if="user?.role == 'super_admin'"> 
        <RouterLink to="users" class="flex items-center gap-3 p-2 rounded-lg hover:bg-indigo-600 transition-colors">
          <Users class="h-6 w-6" />
          <span v-if="drawerOpen" class="truncate">Users</span>
        </RouterLink>
        </template>

        <template v-if="user?.role == 'artist_manager'">
         <RouterLink to="artists" class="flex items-center gap-3 p-2 rounded-lg hover:bg-indigo-600 transition-colors">
              <Mic class="h-6 w-6" />
              <span v-if="drawerOpen" class="truncate">Artists</span>
          </RouterLink> 
        </template>

       

        <RouterLink to="albums" class="flex items-center gap-3 p-2 rounded-lg hover:bg-indigo-600 transition-colors">
          <Disc class="h-6 w-6" />
          <span v-if="drawerOpen" class="truncate">Albums</span>
        </RouterLink>

        <RouterLink to="musics" class="flex items-center gap-3 p-2 rounded-lg hover:bg-indigo-600 transition-colors">
          <Music class="h-6 w-6" />
          <span v-if="drawerOpen" class="truncate">Musics</span>
        </RouterLink>
      </nav>

      <RouterLink to="profile" class="p-4 border-t border-white flex items-center gap-3">
        <div class="w-10 h-10 rounded-full border border-white flex items-center justify-center bg-green-600 text-white font-bold overflow-hidden">
          <template v-if="user.value && user.value.artist && user.value.artist.photo_url">
            <img
              :src="`http://localhost:3000${user.value.artist.photo_url}`"
              alt="User avatar"
              class="w-full h-full object-cover"
            />
          </template>
          <template v-else-if="user.value">
            {{ user.value.first_name.charAt(0).toUpperCase() }}
          </template>
        </div>

        <div v-if="drawerOpen" class="flex-1 overflow-hidden">
          <p class="text-sm font-medium truncate">
            {{user.first_name}} {{ user.last_name }}</p>
          <p class="text-xs text-indigo-200 truncate">{{user.role}}</p>
        </div>
          <Logout />
      </RouterLink>
    </aside>
  </div>
</template>
