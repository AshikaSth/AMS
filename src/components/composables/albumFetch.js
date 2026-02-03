import { ref, computed } from 'vue'
import { api } from '@/api/base_api'
import { useToast } from 'vue-toastification'
export function useAlbums() {
  const pagination = ref({ current_page: 1, total_pages: 1 })

  const toast = useToast()
  const albums = ref([])
  const albumcount = ref(0) 
  const isLoading = ref(false)
  const error = ref(null)
  const allAlbums = ref([]);


  const fetchAlbums = async (page=1) => {
    isLoading.value = true
    error.value = null
    try {
      const response = await api.get('albums', { params: { page } })
      albums.value = response.data.albums
      pagination.value = response.data.meta
      if (response.data.meta && response.data.meta.total_entries !== undefined) {
          albumcount.value = response.data.meta.total_entries
      } 
      console.log('Albums data fetched successfully', response.data);
    } catch (err) {
      toast.error('Failed to fetch albums.')
      error.value = err
      console.error(err)
    } finally {
      isLoading.value = false
    }
  }

  const fetchAllAlbums = async () => {
    try {
      const response = await api.get('/albums/all'); 
      allAlbums.value = response.data;
    } catch (err) {
      console.error(err);
    }
  };

  const allAlbumCount = computed(() => allAlbums.value.length)


  return { albums, allAlbums, albumcount, allAlbumCount,  isLoading, error, fetchAlbums, fetchAllAlbums}
}
