import React from 'react';

export default function ErrorAlert({ message, onClose }) {
  if (!message) return null;

  return (
    <div
      style={{
        background: '#fef2f2',
        border: '1px solid #fecaca',
        borderRadius: '8px',
        padding: '0.85rem 1rem',
        marginBottom: '1.25rem',
        display: 'flex',
        alignItems: 'flex-start',
        justifyContent: 'space-between',
        color: '#dc2626',
        fontSize: '0.9rem',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
        <span style={{ fontWeight: 'bold' }}>⚠</span>
        <span>{message}</span>
      </div>
      {onClose && (
        <button
          onClick={onClose}
          style={{
            background: 'none',
            border: 'none',
            color: '#dc2626',
            fontWeight: 'bold',
            fontSize: '1.1rem',
            lineHeight: 1,
            cursor: 'pointer',
          }}
        >
          ×
        </button>
      )}
    </div>
  );
}
