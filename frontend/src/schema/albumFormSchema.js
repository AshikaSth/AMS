import { z } from 'zod';

export const albumFormSchema = z.object({
  name: z.string().min(1, 'Album name is required'),
  release_date: z.string().min(1, 'Release date is required'),
  artist_ids: z.array(z.number()).optional(),
  music_ids: z.array(z.number()).optional(),
  genres: z.array(z.string()).optional(),
  cover_art: z
    .any()
    .optional(), 
});
