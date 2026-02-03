import { computed, ref } from 'vue';
import { api } from '@/api/base_api';
import { useToast } from 'vue-toastification'

export function useArtists() {
  const pagination = ref({ current_page: 1, total_pages: 1 })
  const artists = ref([]);
  const allArtists = ref([]);
  const toast = useToast()
  const artistsCount = ref(0);
  const myArtists = ref([]);

  const fetchAllArtists = async () => {
    try {
      const response = await api.get('/artists/all'); 
      allArtists.value = response.data;
    } catch (err) {
      console.error(err);
    }
  };

  const fetchMyArtists = async () => {
    try {
      const response = await api.get('/artists/my_artists'); 
      myArtists.value = response.data;
    } catch (err) {
      console.error(err);
    }
  };


const fetchArtists = async (page = 1) => {
  try {
    const response = await api.get('artists', { params: { page } })
    artists.value = response.data.artists
    pagination.value = response.data.meta
    if (response.data.meta && response.data.meta.total_entries !== undefined) {
        artistsCount.value = response.data.meta.total_entries
      } 
  } catch (error) {
    toast.error('Artists data fetch failed')
    console.error(error)
  }
}

const allArtistCount = computed(() => allArtists.value.length)
const myArtistCount = computed(() => myArtists.value.length)


  return { artists, myArtists,  artistsCount, allArtistCount, myArtistCount, allArtists, fetchAllArtists, fetchArtists , fetchMyArtists};
}
