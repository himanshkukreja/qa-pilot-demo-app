import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { loginUser } from '../api/client'

export default function LoginPage() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      // For demo: use local simulation instead of real fetch
      const data = await loginUser(email, password)
      localStorage.setItem('token', data.token)
      navigate('/dashboard')
    } catch (err: any) {
      setError(err.message || 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <h1 data-testid="login-title">Sign In</h1>

        {error && (
          <div className="alert alert-error" data-testid="login-error">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} data-testid="login-form">
          <div className="form-group">
            <label htmlFor="email">Email Id</label>
            <input
              id="email"
              name="email"
              type="email"
              placeholder="Enter your work email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              data-testid="login-email"
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input
              id="password"
              name="password"
              type="password"
              placeholder="Min 8 characters"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              data-testid="login-password"
            />
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            disabled={loading}
            data-testid="login-submit"
            style={{ width: '100%' }}
          >
            {loading ? 'Please wait...' : 'Log In'}
          </button>
        </form>

        <p style={{ textAlign: 'center', marginTop: 16, color: '#888', fontSize: 13 }}>
          Use any email and password to sign in.
        </p>
      </div>
    </div>
  )
}
