<script setup>
import { defineProps } from 'vue';

defineProps({
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: false,
        default: 'No description provided.'
    }
});
</script>
<template>
     <div class="bg-white rounded-2xl shadow p-6 text-center">
        <h3 class="text-xl font-bold text-indigo-700 mb-2">{{title}}</h3>
        <p class="text-gray-600">{{ description }}</p>
      </div>
</template>