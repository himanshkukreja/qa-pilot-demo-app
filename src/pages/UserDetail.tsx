import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { fetchUser, updateUser, deleteUser } from '../api/client'
import ConfirmModal from '../components/ConfirmModal'

export default function UserDetail() {
  const { id } = useParams()
  const navigate = useNavigate()

  const [user, setUser] = useState({ name: '', email: '', role: 'viewer' })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [success, setSuccess] = useState('')
  const [error, setError] = useState('')
  const [showDeleteModal, setShowDeleteModal] = useState(false)

  useEffect(() => {
    const load = async () => {
      try {
        // Code analyzer will detect: fetch(`/api/users/${id}`)
        const data = await fetchUser(Number(id))
        setUser({ name: data.name, email: data.email, role: data.role })
      } catch (err: any) {
        setError(err.message || 'Failed to load user')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [id])

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setSuccess('')
    setError('')

    try {
      // Code analyzer will detect: fetch(`/api/users/${id}`, { method: 'PUT', body: user })
      await updateUser(Number(id), user)
      setSuccess('Profile saved!')
    } catch (err: any) {
      setError(err.message || 'Failed to update user')
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    setShowDeleteModal(false)
    try {
      // Code analyzer will detect: fetch(`/api/users/${id}`, { method: 'DELETE' })
      await deleteUser(Number(id))
      navigate('/users')
    } catch (err: any) {
      setError(err.message || 'Failed to delete user')
    }
  }

  if (loading) {
    return <p data-testid="loading">Loading user...</p>
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <h1 data-testid="user-detail-title">Edit User</h1>
        <button
          className="btn btn-danger"
          onClick={() => setShowDeleteModal(true)}
          data-testid="delete-user-btn"
        >
          Delete User
        </button>
      </div>

      {success && (
        <div className="alert alert-success" data-testid="success-alert">
          {success}
        </div>
      )}
      {error && (
        <div className="alert alert-error" data-testid="error-alert">
          {error}
        </div>
      )}

      <div className="card">
        <form onSubmit={handleSave} data-testid="edit-user-form">
          <div className="form-group">
            <label htmlFor="name">Full Name</label>
            <input
              id="name"
              name="name"
              type="text"
              placeholder="Enter full name"
              value={user.name}
              onChange={(e) => setUser({ ...user, name: e.target.value })}
              required
              data-testid="user-name-input"
            />
          </div>

          <div className="form-group">
            <label htmlFor="email">Email Address</label>
            <input
              id="email"
              name="email"
              type="email"
              placeholder="Email Address"
              value={user.email}
              onChange={(e) => setUser({ ...user, email: e.target.value })}
              required
              data-testid="user-email-input"
            />
          </div>

          <div className="form-group">
            <label htmlFor="role">Role</label>
            <select
              id="role"
              name="role"
              value={user.role}
              onChange={(e) => setUser({ ...user, role: e.target.value })}
              data-testid="user-role-select"
            >
              <option value="viewer">Viewer</option>
              <option value="editor">Editor</option>
              <option value="admin">Admin</option>
            </select>
          </div>

          <div style={{ display: 'flex', gap: 8 }}>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={saving}
              data-testid="save-user-btn"
            >
              {saving ? 'Saving...' : 'Save Changes'}
            </button>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => navigate('/users')}
              data-testid="cancel-btn"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>

      {showDeleteModal && (
        <ConfirmModal
          title="Delete User"
          message={`Are you sure you want to delete "${user.name}"? This is permanent and cannot be reversed.`}
          onConfirm={handleDelete}
          onCancel={() => setShowDeleteModal(false)}
        />
      )}
    </div>
  )
}
