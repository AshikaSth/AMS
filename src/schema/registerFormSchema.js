import { z } from "zod"

export const registerFormSchema = z.object({
  first_name: z.string().min(2, "First name must be at least 2 characters"),
  last_name: z.string().min(2, "Last name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
  password_confirmation: z.string(),
  gender: z.enum(["female", "male", "others"]),
  address: z.string().min(3, "Address is too short"),
  phone_number: z.string().regex(/^\d{3}-\d{3}-\d{3,4}$/, "Invalid phone number"),
  dob: z.string().refine((val) => !isNaN(Date.parse(val)), {
    message: "Invalid date of birth",
  }),
}).refine((data) => data.password === data.password_confirmation, {
  message: "Passwords do not match",
  path: ["password_confirmation"],
})
