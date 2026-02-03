<script setup> 
import Sidebar from '@/components/Dashboard/Sidebar.vue'
import { RouterView } from 'vue-router';
</script>
<template>

<div class="flex h-screen bg-gray-100">
  <Sidebar />
  <main class="p-6">
    <RouterView />
  </main>
</div>
</template>

