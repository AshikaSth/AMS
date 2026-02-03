<template>
      <section class="flex flex-col items-center justify-center text-center py-24 px-6 bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 text-white">
      <h2 class="text-4xl md:text-5xl font-extrabold mb-4">Manage Artists, Albums & Songs</h2>
      <p class="text-lg md:text-xl max-w-2xl mb-8">
        A simple and powerful system to keep track of your artists, albums, and music collections. 
        Built with modern technology for seamless management.
      </p>
      <div class="space-x-4">
        <RouterLink to="/login" class="px-6 py-3 bg-white text-indigo-700 font-semibold rounded-xl shadow hover:bg-gray-100">Login</RouterLink>
        <RouterLink to="/register" class="px-6 py-3 bg-indigo-800 font-semibold rounded-xl shadow hover:bg-indigo-900">Register</RouterLink>
      </div>
    </section>
</template>