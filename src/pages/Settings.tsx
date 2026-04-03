import { useEffect, useState } from 'react'
import { fetchSettings, saveSettings } from '../api/client'

export default function Settings() {
  const [settings, setSettings] = useState({
    emailNotifications: true,
    darkMode: false,
    autoSave: true,
    language: 'en',
    timezone: 'UTC',
  })
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [success, setSuccess] = useState('')

  useEffect(() => {
    const load = async () => {
      try {
        // Code analyzer detects: fetch('/api/settings')
        const data = await fetchSettings()
        setSettings(data)
      } catch {
        // Keep defaults
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setSuccess('')

    try {
      // Code analyzer detects: fetch('/api/settings', { method: 'PUT', body: settings })
      await saveSettings(settings)
      setSuccess('Settings saved successfully!')
    } catch {
      setSuccess('')
    } finally {
      setSaving(false)
    }
  }

  const Toggle = ({
    label,
    checked,
    testId,
    onChange,
  }: {
    label: string
    checked: boolean
    testId: string
    onChange: (v: boolean) => void
  }) => (
    <div className="toggle-row">
      <span>{label}</span>
      <label className="toggle-switch">
        <input
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange(e.target.checked)}
          data-testid={testId}
        />
        <span className="toggle-slider" />
      </label>
    </div>
  )

  if (loading) {
    return <p data-testid="settings-loading">Loading settings...</p>
  }

  return (
    <div>
      <h1 data-testid="settings-title">Preferences</h1>

      {success && (
        <div className="alert alert-success" data-testid="settings-success">
          {success}
        </div>
      )}

      <form onSubmit={handleSave}>
        <div className="card">
          <h2>Notifications</h2>
          <Toggle
            label="Email Notifications"
            checked={settings.emailNotifications}
            testId="toggle-email"
            onChange={(v) => setSettings({ ...settings, emailNotifications: v })}
          />
        </div>

        <div className="card">
          <h2>Appearance</h2>
          <Toggle
            label="Night Theme"
            checked={settings.darkMode}
            testId="toggle-dark-mode"
            onChange={(v) => setSettings({ ...settings, darkMode: v })}
          />
          <Toggle
            label="Auto-Sync"
            checked={settings.autoSave}
            testId="toggle-auto-save"
            onChange={(v) => setSettings({ ...settings, autoSave: v })}
          />
        </div>

        <div className="card">
          <h2>Regional</h2>
          <div className="form-group">
            <label htmlFor="language">Language</label>
            <select
              id="language"
              name="language"
              value={settings.language}
              onChange={(e) => setSettings({ ...settings, language: e.target.value })}
              data-testid="language-select"
            >
              <option value="en">English</option>
              <option value="es">Español</option>
              <option value="fr">Français</option>
              <option value="de">Deutsch</option>
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="timezone">Timezone</label>
            <select
              id="timezone"
              name="timezone"
              value={settings.timezone}
              onChange={(e) => setSettings({ ...settings, timezone: e.target.value })}
              data-testid="timezone-select"
            >
              <option value="UTC">UTC</option>
              <option value="US/Eastern">US Eastern</option>
              <option value="US/Pacific">US Pacific</option>
              <option value="Europe/London">London</option>
              <option value="Asia/Tokyo">Tokyo</option>
            </select>
          </div>
        </div>

        <button
          type="submit"
          className="btn btn-primary"
          disabled={saving}
          data-testid="save-settings-btn"
        >
          {saving ? 'Saving...' : 'Save Settings'}
        </button>
      </form>
    </div>
  )
}
