import { ref, computed } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'

export function useMusics() {
  const pagination = ref({ current_page: 1, total_pages: 1 })

  const toast = useToast()
  const musics = ref([])
  const musicCount = ref(0)
  const allMusics = ref([]);


  const isLoading = ref(false)
  const error = ref(null)

  const fetchMusics = async (page = 1) => {
    isLoading.value = true
    error.value = null
    try {
      const response = await api.get('musics', { params: { page } })
      musics.value = response.data.musics
      pagination.value = response.data.meta
      if (response.data.meta && response.data.meta.total_entries !== undefined) {
          musicCount.value = response.data.meta.total_entries
      } 
    } catch (err) {
      toast.error('Failed to fetch musics.')
      error.value = err
      console.error(err)
    } finally {
      isLoading.value = false
    }
  }

  const fetchAllMusics = async () => {
    try {
      const response = await api.get('/musics/all'); 
      allMusics.value = response.data;
    } catch (err) {
      console.error(err);
    }
  };

  const allMusicCount = computed(() => allMusics.value.length)

  return { musics, musicCount, allMusics, allMusicCount, isLoading, error, fetchMusics, fetchAllMusics}
}
