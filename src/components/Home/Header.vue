<script setup></script>

<template>
  <header class="w-full px-8 py-4 flex justify-between items-center bg-white shadow">
      <h1 class="text-2xl font-bold text-indigo-700">🎶 Artist Management System</h1>
      <div class="space-x-4">
        <RouterLink to="/register" class="px-6 py-3 bg-indigo-800 text-white font-semibold rounded-xl shadow hover:bg-indigo-900">Login</RouterLink>
        <RouterLink to="/login" class="px-6 py-3 bg-white text-indigo-700 font-semibold rounded-xl shadow hover:bg-gray-100">Register</RouterLink>
      </div>
    </header>
</template>
