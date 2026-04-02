import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { fetchDashboardStats } from '../api/client'

export default function Dashboard() {
  const [stats, setStats] = useState({ totalUsers: 0, activeUsers: 0, totalTests: 0 })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const load = async () => {
      try {
        const data = await fetch('/api/dashboard/stats').then((r) => r.json()).catch(() => null)
        // Fallback to local simulation
        const localData = await fetchDashboardStats()
        setStats(data || localData)
      } catch {
        const localData = await fetchDashboardStats()
        setStats(localData)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  return (
    <div>
      <h1 data-testid="dashboard-title">Dashboard</h1>

      <div className="stats-grid" data-testid="stats-grid">
        <div className="stat-card" data-testid="stat-total-users">
          <div className="stat-value">{loading ? '...' : stats.totalUsers}</div>
          <div className="stat-label">Total Users</div>
        </div>
        <div className="stat-card" data-testid="stat-active-users">
          <div className="stat-value">{loading ? '...' : stats.activeUsers}</div>
          <div className="stat-label">Active Users</div>
        </div>
        <div className="stat-card" data-testid="stat-total-tests">
          <div className="stat-value">{loading ? '...' : stats.totalTests}</div>
          <div className="stat-label">Test Executions</div>
        </div>
      </div>

      <div className="card">
        <h2>Quick Links</h2>
        <div className="quick-links">
          <Link to="/users" className="quick-link" data-testid="link-manage-users">
            👥 Manage Users
          </Link>
          <Link to="/settings" className="quick-link" data-testid="link-settings">
            ⚙️ Settings
          </Link>
          <Link to="/users?role=admin" className="quick-link" data-testid="link-view-admins">
            🛡️ View Admins
          </Link>
          <a
            href="https://docs.example.com"
            className="quick-link"
            target="_blank"
            rel="noopener"
            data-testid="link-docs"
          >
            📖 Documentation
          </a>
        </div>
      </div>
    </div>
  )
}
