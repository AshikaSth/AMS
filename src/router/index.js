import AlbumsView from '@/views/AlbumsView.vue'
import ArtistsView from '@/views/ArtistsView.vue'
import DashboardView from '@/views/DashboardView.vue'
import HomeView from '@/views/HomeView.vue'
import LoginView from '@/views/LoginView.vue'
import RegisterView from '@/views/RegisterView.vue'
import MusicsView from '@/views/MusicsView.vue'
import NotFoundView from '@/views/NotFoundView.vue'
import UsersView from '@/views/UsersView.vue'
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import DashboardMainView from '@/views/DashboardMainView.vue'
import ProfileView from '@/views/ProfileView.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView,
    },
    {
      path: '/register',
      name: 'register',
      component: RegisterView,
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: DashboardView, 
      meta: { requiresAuth: true },
      redirect: { name: 'dashboardmain' },
      children: [
        {
          path: 'dashboardmain', //this page is the page i want to display when user first goes into dashboard
          name: 'dashboardmain',
          component: DashboardMainView,
        },
        {
          path: 'users',
          name: 'users',
          component: UsersView,
        },
        {
          path: 'artists',
          name: 'artists',
          component: ArtistsView,
        },
        {
          path: 'albums',
          name: 'albums',
          component: AlbumsView,
        },
        {
          path: 'musics',
          name: 'musics',
          component: MusicsView,
        },
        {
          path: 'profile',
          name: 'profile',
          component: ProfileView,
        },
      ],
    },
    {
      path: '/:catchAll(.*)',
      name: 'not-found',
      component: NotFoundView,
    },
  ],
})


router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  // Check if the route requires authentication
  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    // If not authenticated and trying to access a protected route, redirect to login
    next({ name: 'login' })
  } else if (to.name === 'login' && authStore.isLoggedIn) {
    // If authenticated and trying to go to login, redirect to dashboard
    next({ name: 'dashboard' })
  } else {
    // Otherwise, allow the navigation to proceed
    next()
  }
})

export default router

