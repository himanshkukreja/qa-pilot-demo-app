import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { fetchUsers } from '../api/client'

interface User {
  id: number
  name: string
  email: string
  role: string
  status: string
}

export default function UserList() {
  const [users, setUsers] = useState<User[]>([])
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [searchParams] = useSearchParams()

  useEffect(() => {
    const roleFilter = searchParams.get('role') || ''
    loadUsers(roleFilter ? `role:${roleFilter}` : '')
  }, [searchParams])

  const loadUsers = async (query: string = '') => {
    setLoading(true)
    try {
      // Simulates: fetch('/api/users', { params: { search: query } })
      const data = await fetchUsers(query)
      setUsers(data)
    } catch (err) {
      console.error('Failed to load users:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    fetch(`/api/users?search=${encodeURIComponent(search)}`)
      .catch(() => {})
    loadUsers(search)
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <h1 data-testid="users-title">Users</h1>
      </div>

      <div className="card">
        <form onSubmit={handleSearch} className="search-bar" data-testid="search-form">
          <input
            name="search"
            type="text"
            placeholder="Search users by name or email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            data-testid="search-input"
          />
          <button type="submit" className="btn btn-primary" data-testid="search-btn">
            Search
          </button>
        </form>

        {loading ? (
          <p data-testid="loading-indicator">Loading users...</p>
        ) : (
          <table data-testid="users-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id} data-testid={`user-row-${user.id}`}>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td>
                    <span
                      style={{
                        padding: '2px 8px',
                        borderRadius: 4,
                        background: user.role === 'admin' ? '#e8f4fd' : '#f0f0f0',
                        fontSize: 12,
                      }}
                    >
                      {user.role}
                    </span>
                  </td>
                  <td>
                    <span
                      style={{
                        color: user.status === 'active' ? '#28a745' : '#dc3545',
                        fontWeight: 600,
                        fontSize: 13,
                      }}
                    >
                      {user.status}
                    </span>
                  </td>
                  <td>
                    <Link
                      to={`/users/${user.id}`}
                      className="btn btn-secondary"
                      style={{ padding: '4px 12px', fontSize: 12 }}
                      data-testid={`edit-user-${user.id}`}
                    >
                      Edit
                    </Link>
                  </td>
                </tr>
              ))}
              {users.length === 0 && (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', color: '#888', padding: 24 }}>
                    No matching members
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}

        <p
          style={{ marginTop: 12, fontSize: 13, color: '#888' }}
          data-testid="user-count"
        >
          {users.length} user(s) found
        </p>
      </div>
    </div>
  )
}
