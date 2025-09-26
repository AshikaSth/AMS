<script setup>
import { ref, onMounted } from "vue"
import { useToast } from "vue-toastification"
import { api } from "@/api/base_api"
// import EditProfileDialog from "@/components/EditProfileDialog.vue"

const toast = useToast()
const user = ref({})
const showDialog = ref(false)

const fetchProfile = async () => {
  try {
    const { data } = await api.get("profile")
    user.value = data
  } catch (err) {
    toast.error("Failed to fetch profile")
  }
}

onMounted(fetchProfile)

const openEditDialog = () => {
  showDialog.value = true
}
</script>

<template>
  <div class="max-w-3xl mx-auto mt-10 p-6 bg-white rounded-xl shadow-md">
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-2xl font-bold text-gray-800">Profile</h2>
      <Button @click="openEditDialog">Edit Profile</Button>
    </div>

    <div class="flex flex-col md:flex-row gap-6">
      <div class="w-32 h-32 rounded-full overflow-hidden">
        <img v-if="user.artist?.photo_url" :src="`http://localhost:3000${user.artist.photo_url}`" />
        <div v-else class="w-full h-full flex items-center justify-center bg-gray-400 text-white font-bold text-3xl">
          {{ user.first_name?.charAt(0) }}
        </div>
      </div>

      <div class="flex-1 space-y-2">
        <p><span class="font-semibold">Name:</span> {{ user.first_name }} {{ user.last_name }}</p>
        <p><span class="font-semibold">Email:</span> {{ user.email }}</p>
        <p><span class="font-semibold">Role:</span> {{ user.role }}</p>
        <p><span class="font-semibold">Gender:</span> {{ user.gender }}</p>
        <p><span class="font-semibold">Address:</span> {{ user.address }}</p>
        <p><span class="font-semibold">Phone:</span> {{ user.phone_number }}</p>
        <p><span class="font-semibold">DOB:</span> {{ user.dob }}</p>
        <p><span class="font-semibold">Bio:</span> {{ user.artist?.bio }}</p>
      </div>
    </div>

    <!-- <EditProfileDialog v-if="showDialog" :user="user" @close="showDialog=false" /> -->
  </div>
</template>
