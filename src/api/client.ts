/**
 * Fake API client — simulates async API calls with realistic delays.
 *
 * Patterns used here are the SAME patterns the Code Analyzer detects:
 *   - fetch() calls with method + body
 *   - Endpoint paths like /api/auth/login, /api/users
 *
 * In production you'd replace this with real axios/fetch calls.
 * The code analyzer will still extract the API patterns from the source.
 */

// Simulated user database
const USERS = [
  { id: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'admin', status: 'active' },
  { id: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'editor', status: 'active' },
  { id: 3, name: 'Carol Davis', email: 'carol@example.com', role: 'viewer', status: 'inactive' },
  { id: 4, name: 'David Lee', email: 'david@example.com', role: 'editor', status: 'active' },
  { id: 5, name: 'Eva Martinez', email: 'eva@example.com', role: 'viewer', status: 'active' },
]

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

// ── Auth API ────────────────────────────────────────────────
export async function loginUser(email: string, password: string) {
  // Simulates: fetch('/api/auth/login', { method: 'POST', body: { email, password } })
  await delay(500)
  if (!email || !password) {
    throw new Error('Email and password are required')
  }
  // Accept any non-empty credentials
  const token = 'fake-jwt-token-' + Date.now()
  return { token, user: { name: email.split('@')[0] || 'User', email } }
}

// ── Users API ───────────────────────────────────────────────
export async function fetchUsers(search?: string) {
  // Simulates: fetch('/api/users?search=' + search)
  await delay(300)
  let results = [...USERS]
  if (search) {
    const q = search.toLowerCase()
    results = results.filter(
      (u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)
    )
  }
  return results
}

export async function fetchUser(id: number) {
  // Simulates: fetch(`/api/users/${id}`)
  await delay(200)
  const user = USERS.find((u) => u.id === id)
  if (!user) throw new Error('User not found')
  return { ...user }
}

export async function updateUser(id: number, data: { name: string; email: string; role: string }) {
  // Simulates: fetch(`/api/users/${id}`, { method: 'PUT', body: data })
  await delay(400)
  const idx = USERS.findIndex((u) => u.id === id)
  if (idx === -1) throw new Error('User not found')
  USERS[idx] = { ...USERS[idx], ...data }
  return USERS[idx]
}

export async function deleteUser(id: number) {
  // Simulates: fetch(`/api/users/${id}`, { method: 'DELETE' })
  await delay(300)
  const idx = USERS.findIndex((u) => u.id === id)
  if (idx === -1) throw new Error('User not found')
  USERS.splice(idx, 1)
  return { success: true }
}

// ── Settings API ────────────────────────────────────────────
export async function fetchSettings() {
  // Simulates: fetch('/api/settings')
  await delay(200)
  return {
    emailNotifications: true,
    darkMode: false,
    autoSave: true,
    language: 'en',
    timezone: 'UTC',
  }
}

export async function saveSettings(settings: Record<string, unknown>) {
  // Simulates: fetch('/api/settings', { method: 'PUT', body: settings })
  await delay(400)
  return { ...settings, updatedAt: new Date().toISOString() }
}

// ── Dashboard API ───────────────────────────────────────────
export async function fetchDashboardStats() {
  // Simulates: fetch('/api/dashboard/stats')
  await delay(250)
  return {
    totalUsers: USERS.length,
    activeUsers: USERS.filter((u) => u.status === 'active').length,
    totalTests: 142,
  }
}
