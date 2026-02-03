import { z } from 'zod';

export const artistFormSchema = z.object({
  bio: z.string().optional(),
  website: z.string().url("Please enter a valid URL.").optional(),
  social_media_links: z.array(
    z.object({
      platform: z.string().min(1, "Platform is required."),
      link: z.string().url("Please enter a valid URL for the social link."),
    })
  ),
  genres: z.array(z.string().min(1, "Genre name cannot be empty.")),
  user_id: z.coerce.number().optional(),
  manager_id: z.coerce.number().optional(),

});
