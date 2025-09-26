<script setup>
import { api } from '@/api/base_api'
import { ref, onMounted } from 'vue'
import { useToast } from 'vue-toastification'
import UserForm from '@/components/UserForm.vue'
import { Edit2Icon } from 'lucide-vue-next'
import DeleteDialog from '@/components/DeleteDialog.vue'
const pagination = ref({ current_page: 1, total_pages: 1 })
const toast = useToast()
const users = ref([])
const showDialog = ref(false)
const userToEdit = ref(null)

const fetchUsers = async (page=1) => {
  try {
    const response = await api.get('users', { params: { page } })
    users.value = response.data.users
    pagination.value = response.data.meta
    console.log('Users data fetched Successfully', response.data)
  } catch (error) {
    toast.error('Users data fetch failed')
    console.error(error)
  }
}

onMounted(() => {
  fetchUsers()
})

const handleUserSaved = () => {
  showDialog.value = false
  userToEdit.value = null
  toast.success('User saved successfully!')
  fetchUsers()
}

const openEditDialog = (user) => {
  userToEdit.value = user
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  userToEdit.value = null
}
</script>
<template>
  <body class="bg-gray-100 p-6">
    <div class="flex justify-between mb-6">
      <h1 class="text-3xl font-bold">Users</h1>
      <button class="bg-indigo-600 text-white px-4 py-2 rounded-lg" @click="showDialog = true">
        + Add User
      </button>
    </div>

    <div v-if="!users.length" class="text-center text-gray-500 py-10">
      There are no users present.
    </div>

    <div v-else>
      <div class="overflow-x-auto rounded-lg shadow bg-white max-h-[75vh]">
        <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-4 py-2 text-left min-w-[50px]">S.N.</th>
            <th class="px-4 py-2 text-left min-w-[50px]">ID</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Name</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Email</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Role</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Gender</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Dob</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Address</th>
            <th class="px-4 py-2 text-left min-w-[50px]">Contact</th>

            <th class="px-4 py-2 text-left min-w-[50px]">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(user, index) in users" :key="user.id" class="border-t">
            <td class="px-4 py-2">{{ index + 1 }}</td>
            <td class="px-4 py-2">{{ user.id }}</td>
            <td class="px-4 py-2">{{ user.first_name }} {{ user.last_name }}</td>
            <td class="px-4 py-2">{{ user.email }}</td>
            <td class="px-4 py-2">{{ user.role }}</td>
            <td class="px-4 py-2">{{ user.gender }}</td>

            <td class="px-4 py-2">{{ user.dob }}</td>

            <td class="px-4 py-2">{{ user.address }}</td>

            <td class="px-4 py-2">{{ user.phone_number }}</td>

            <td class="px-4 py-2">
              <button class="text-blue-600" @click="openEditDialog(user)"><Edit2Icon /></button>
              <DeleteDialog
                resource-name="User"
                :delete-url="`users/${user.id}`"
                @deleted="fetchUsers"
              />
            </td>
          </tr>
        </tbody>
        </table>
      </div>

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

    <UserForm
      v-if="showDialog"
      :user-to-edit="userToEdit"
      @saved="handleUserSaved"
      @close="showDialog = false"
    />
  </body>
</template>
