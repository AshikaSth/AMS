import axios from "axios";
const API_BASE_URL = "http://127.0.0.1:3000/api/v1/";

export  const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true, 
  
});

// api.interceptors.response.use(
//   (response) => response,
//   (error) => {
//     if (error.response && error.response.status === 401) {
//       window.location.href = '/login';
//     }
//     return Promise.reject(error);
//   }
// );

// export { api };
