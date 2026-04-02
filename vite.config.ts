import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  
  server: {
    port: 3000,
    open: false,
    host: true, // allows external access
    allowedHosts: ['demo.himanshukukreja.in'],
  },

  preview: {
    port: 3000,
    host: true,
    open: false,
    allowedHosts: ['demo.himanshukukreja.in'],
  },
})