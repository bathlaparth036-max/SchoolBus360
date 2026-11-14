import React from 'react';
import { useNavigate } from 'react-router-dom';

export default function UnauthorizedPage({ onLogout }) {
  const navigate = useNavigate();

  return (
    <div style={{ maxWidth: '480px', margin: '4rem auto', padding: '0 1rem', textAlign: 'center' }}>
      <div className="card">
        <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>⛔</div>
        <h2 style={{ fontSize: '1.4rem', color: '#dc2626', marginBottom: '0.75rem' }}>
          Access Denied
        </h2>
        <p style={{ color: '#64748b', fontSize: '0.95rem', marginBottom: '1.5rem', lineHeight: 1.5 }}>
          Your account is not registered as an active School Administrator. Normal parent and driver
          accounts must use the SchoolBus360 mobile application.
        </p>
        <button
          onClick={async () => {
            if (onLogout) await onLogout();
            navigate('/login');
          }}
          className="btn btn-primary"
          style={{ width: '100%' }}
        >
          Return to Login
        </button>
      </div>
    </div>
  );
}
