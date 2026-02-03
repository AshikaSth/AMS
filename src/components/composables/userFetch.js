import { computed, ref } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'

export function useUsers() {
  const pagination = ref({ current_page: 1, total_pages: 1 })

  const toast = useToast()
  const users = ref([])
  const managers = ref([])
  const unassignedArtists = ref([])
  const usersCount = ref(0) 

  const isLoading = ref(false)
  const error = ref(null)

  const fetchUsers = async (page=1) => {
    isLoading.value = true
    error.value = null
    try {
      const response = await api.get('users', { params: { page } })
      users.value = response.data.users
      pagination.value = response.data.meta
      if (response.data.meta && response.data.meta.total_entries !== undefined) {
        usersCount.value = response.data.meta.total_entries
      } 
      managers.value = users.value.filter(user => user.role === 'artist_manager')
    } catch (err) {
      toast.error('Failed to fetch users and managers.')
      error.value = err
      console.error(err)
    } finally {
      isLoading.value = false
    }
  }

    const fetchUnassignedArtists = async () => {
        isLoading.value = true
        error.value = null
        try {
        const response = await api.get('users/unassigned_artists')
        unassignedArtists.value = response.data
        } catch (err) {
        toast.error('Failed to fetch unassigned artists.')
        error.value = err
        console.error(err)
        } finally {
        isLoading.value = false
        }
    }

  const managersCount = computed(() => managers.value.length)
  const unassignedArtistsCount = computed(() => unassignedArtists.value.length)

  return { users, usersCount, managersCount, unassignedArtistsCount, managers, unassignedArtists, isLoading, error, fetchUsers, fetchUnassignedArtists}
}
