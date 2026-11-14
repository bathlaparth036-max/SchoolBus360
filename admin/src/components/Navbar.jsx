import React from 'react';

export default function Navbar({ adminProfile, onLogout }) {
  return (
    <header
      style={{
        background: '#1e293b',
        color: '#ffffff',
        padding: '0.85rem 1.5rem',
        borderBottom: '2px solid #f59e0b',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
        <div
          style={{
            width: '32px',
            height: '32px',
            borderRadius: '6px',
            background: '#f59e0b',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#1e293b',
            fontWeight: 'bold',
            fontSize: '1.1rem',
          }}
        >
          🚌
        </div>
        <div>
          <span style={{ fontWeight: 700, fontSize: '1.1rem', letterSpacing: '0.3px' }}>
            SchoolBus360
          </span>
          <span
            style={{
              marginLeft: '0.5rem',
              fontSize: '0.75rem',
              background: '#334155',
              padding: '0.15rem 0.45rem',
              borderRadius: '4px',
              color: '#f59e0b',
              fontWeight: 600,
            }}
          >
            Admin
          </span>
        </div>
      </div>

      {adminProfile && (
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          <span style={{ fontSize: '0.9rem', color: '#94a3b8' }}>
            Logged in as <strong style={{ color: '#ffffff' }}>{adminProfile.name || 'Admin'}</strong>
          </span>
          <button
            onClick={onLogout}
            style={{
              background: '#334155',
              color: '#ffffff',
              border: 'none',
              padding: '0.4rem 0.85rem',
              borderRadius: '6px',
              fontSize: '0.85rem',
              fontWeight: 600,
              cursor: 'pointer',
            }}
          >
            Logout
          </button>
        </div>
      )}
    </header>
  );
}
