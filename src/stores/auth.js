import {defineStore} from 'pinia';
import {ref} from 'vue'

export const useAuthStore = defineStore('auth', () => {
    const isLoggedIn = ref(false)
    const user = ref(null)

    function login(userData){
        isLoggedIn.value= true
        user.value = userData
        console.log(isLoggedIn.value, user.value)
    }

    function logout() {
        isLoggedIn.value= false
        user.value = null
        console.log(isLoggedIn.value, user.value)
    }
    return { isLoggedIn, user, login, logout }

})