import { NavLink, Outlet } from 'react-router-dom'

export default function Layout() {
  const handleLogout = () => {
    localStorage.removeItem('token')
    window.location.href = '/login'
  }

  return (
    <div className="layout">
      <nav className="sidebar" data-testid="sidebar-nav">
        <h2>QA Pilot Demo</h2>
        <NavLink to="/dashboard" data-testid="nav-dashboard">
          📊 Dashboard
        </NavLink>
        <NavLink to="/users" data-testid="nav-users">
          👥 Users
        </NavLink>
        <NavLink to="/settings" data-testid="nav-settings">
          ⚙️ Settings
        </NavLink>
        <button
          className="btn btn-secondary"
          onClick={handleLogout}
          data-testid="logout-btn"
          style={{ marginTop: 'auto' }}
        >
          Logout
        </button>
      </nav>
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  )
}
