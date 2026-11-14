import React from 'react';

/**
 * Phase 1 Admin Dashboard.
 * Proves administrator role verification, school association, and session management.
 */
export default function AdminDashboard({ adminProfile, school, onLogout }) {
  const adminName = adminProfile?.name || 'Administrator';
  const schoolName = school?.name || adminProfile?.schoolId || 'N/A';

  return (
    <div style={{ maxWidth: '720px', margin: '2rem auto', padding: '0 1rem' }}>
      <div className="card">
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 'bold', color: '#0f172a' }}>
              SchoolBus360 Admin
            </h1>
            <p style={{ color: '#64748b', fontSize: '0.95rem', marginTop: '0.25rem' }}>
              Transport Administration Portal
            </p>
          </div>
          <span className="chip chip-warning">Phase 1 Foundation</span>
        </div>

        <hr style={{ border: 'none', borderTop: '1px solid #e2e8f0', margin: '1.5rem 0' }} />

        {/* Welcome Section */}
        <div style={{ marginBottom: '1.5rem' }}>
          <p style={{ fontSize: '0.9rem', color: '#64748b', textTransform: 'uppercase', letterSpacing: '0.5px', fontWeight: 600 }}>
            Welcome,
          </p>
          <h2 style={{ fontSize: '1.4rem', color: '#0f172a', fontWeight: 'bold' }}>
            {adminName}
          </h2>
        </div>

        {/* School Info */}
        <div
          style={{
            background: '#f8fafc',
            border: '1px solid #e2e8f0',
            borderRadius: '8px',
            padding: '1.25rem',
            marginBottom: '1.75rem',
          }}
        >
          <div style={{ marginBottom: '0.75rem' }}>
            <span style={{ fontSize: '0.85rem', color: '#64748b', fontWeight: 600, display: 'block' }}>
              School:
            </span>
            <span style={{ fontSize: '1.15rem', fontWeight: 'bold', color: '#1e293b' }}>
              {schoolName}
            </span>
          </div>

          <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap', marginTop: '0.5rem' }}>
            <span className="chip chip-success">Role: Admin</span>
            <span className="chip">School ID: {adminProfile?.schoolId || 'N/A'}</span>
            <span className="chip">Phone: {adminProfile?.phone || 'N/A'}</span>
          </div>
        </div>

        {/* Phase 1 Status Summary */}
        <div
          style={{
            borderLeft: '4px solid #f59e0b',
            background: '#fffbeb',
            padding: '1rem',
            borderRadius: '4px',
            marginBottom: '2rem',
            fontSize: '0.9rem',
            color: '#92400e',
            lineHeight: 1.5,
          }}
        >
          <strong>Phase 1 Foundation Operational:</strong>
          <br />
          Authentication state verified, administrator privileges confirmed against Cloud Firestore,
          and school-level data isolation enforced. Route creation, bus management, and driver
          assignment interfaces will be activated in subsequent phases.
        </div>

        {/* Logout Action */}
        <div>
          <button
            onClick={onLogout}
            className="btn btn-danger"
            style={{ width: '100%' }}
          >
            Logout
          </button>
        </div>
      </div>
    </div>
  );
}
