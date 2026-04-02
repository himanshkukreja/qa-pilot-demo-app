import { BrowserRouter, Routes, Route } from 'react-router-dom'
import LoginPage from './pages/LoginPage'
import Dashboard from './pages/Dashboard'
import UserList from './pages/UserList'
import UserDetail from './pages/UserDetail'
import Settings from './pages/Settings'
import Layout from './components/Layout'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<Layout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/users" element={<UserList />} />
          <Route path="/users/:id" element={<UserDetail />} />
          <Route path="/settings" element={<Settings />} />
        </Route>
        <Route path="*" element={<LoginPage />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
