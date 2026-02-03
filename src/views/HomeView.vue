<script setup>
import { RouterLink } from 'vue-router';
import Footer from '@/components/Home/Footer.vue';
import Header from '@/components/Home/Header.vue';
import Hero from '@/components/Home/Hero.vue';
import Main from '@/components/Home/Main.vue'
</script>

<template>
    <div class="bg-gray-50 min-h-screen flex flex-col">
    
    <Header />
    <Hero/>
    <Main/>
    <Footer />

  </div>
</template>