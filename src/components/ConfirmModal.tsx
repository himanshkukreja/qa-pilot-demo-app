import { useState } from 'react'

interface ConfirmModalProps {
  title: string
  message: string
  onConfirm: () => void
  onCancel: () => void
}

export default function ConfirmModal({
  title,
  message,
  onConfirm,
  onCancel,
}: ConfirmModalProps) {
  return (
    <div className="modal-overlay" data-testid="modal-overlay" onClick={onCancel}>
      <div
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        data-testid="modal-content"
      >
        <h3>{title}</h3>
        <p style={{ margin: '12px 0', color: '#555' }}>{message}</p>
        <div className="modal-actions">
          <button
            className="btn btn-secondary"
            onClick={onCancel}
            data-testid="modal-cancel"
          >
            Go back
          </button>
          <button
            className="btn btn-danger"
            onClick={onConfirm}
            data-testid="modal-confirm"
          >
            Confirm
          </button>
        </div>
      </div>
    </div>
  )
}
