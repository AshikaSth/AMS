import { z } from 'zod';

export const albumFormSchema = z.object({
  name: z.string().min(1, "Album name is required"),
  release_date: z.string().min(1, "Release date is required"),
  artist_ids: z.array(z.number().int()).min(1, "Select at least one artist"),
  music_ids: z.array(z.number().int()).optional(),
  genres: z.array(z.string().min(1, "Genre cannot be empty")).optional(),
  cover_art: z.any().optional(), // file can be null
});
