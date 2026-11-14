import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import ErrorAlert from '../components/ErrorAlert';

export default function AdminLogin({ onLoginSuccess }) {
  const [phoneNumber, setPhoneNumber] = useState('9876500001');
  const [otpCode, setOtpCode] = useState('');
  const [confirmationResult, setConfirmationResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Initialize reCAPTCHA on mount
    try {
      authService.initRecaptcha('recaptcha-container');
    } catch (err) {
      console.warn('reCAPTCHA init:', err);
    }
  }, []);

  const handleSendOtp = async (e) => {
    if (e) e.preventDefault();
    setError(null);

    const cleanDigits = phoneNumber.replace(/\D/g, '');
    if (cleanDigits.length !== 10) {
      setError('Please enter a valid 10-digit Indian mobile number.');
      return;
    }

    const formattedNumber = `+91${cleanDigits}`;
    setLoading(true);

    try {
      const appVerifier = window.recaptchaVerifier;
      const result = await authService.sendOtp(formattedNumber, appVerifier);
      setConfirmationResult(result);
      setOtpCode('123456'); // Pre-fill test code for convenience
    } catch (err) {
      setError(err.message || 'Failed to send OTP.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e) => {
    if (e) e.preventDefault();
    setError(null);

    if (otpCode.trim().length !== 6) {
      setError('Please enter the 6-digit OTP code.');
      return;
    }

    setLoading(true);

    try {
      const session = await authService.verifyOtpAndAuthorize(confirmationResult, otpCode.trim());
      if (onLoginSuccess) {
        onLoginSuccess(session);
      }
      navigate('/dashboard');
    } catch (err) {
      setError(err.message || 'Verification failed.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '80vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '1rem' }}>
      <div className="card" style={{ maxWidth: '460px', width: '100%' }}>
        <div style={{ textAlign: 'center', marginBottom: '1.75rem' }}>
          <div
            style={{
              width: '56px',
              height: '56px',
              borderRadius: '50%',
              background: '#fef3c7',
              color: '#d97706',
              fontSize: '2rem',
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              marginBottom: '1rem',
            }}
          >
            🏫
          </div>
          <h2 style={{ fontSize: '1.6rem', color: '#0f172a', marginBottom: '0.35rem' }}>
            SchoolBus360 Admin
          </h2>
          <p style={{ color: '#64748b', fontSize: '0.9rem' }}>
            Sign in to access the school transport management portal
          </p>
        </div>

        <ErrorAlert message={error} onClose={() => setError(null)} />

        {/* reCAPTCHA container required by Firebase Phone Auth */}
        <div id="recaptcha-container"></div>

        {!confirmationResult ? (
          <form onSubmit={handleSendOtp}>
            <div style={{ marginBottom: '1.25rem' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '0.85rem',
                  fontWeight: 600,
                  color: '#1e293b',
                  marginBottom: '0.5rem',
                }}
              >
                Administrator Mobile Number
              </label>
              <div style={{ display: 'flex' }}>
                <span
                  style={{
                    background: '#f1f5f9',
                    border: '1.5px solid #e2e8f0',
                    borderRight: 'none',
                    borderRadius: '8px 0 0 8px',
                    padding: '0.75rem 0.85rem',
                    fontWeight: 600,
                    color: '#334155',
                  }}
                >
                  +91
                </span>
                <input
                  type="tel"
                  className="input-field"
                  style={{ borderRadius: '0 8px 8px 0' }}
                  placeholder="98765 43210"
                  maxLength="10"
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  autoFocus
                  required
                />
              </div>

              {/* Development Quick-Fill Chips */}
              <div style={{ marginTop: '0.85rem', display: 'flex', flexDirection: 'column', gap: '0.35rem' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: '#64748b' }}>
                  Quick-fill test accounts:
                </span>
                <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                  <button
                    type="button"
                    onClick={() => setPhoneNumber('9876500001')}
                    style={{
                      background: '#f0fdf4',
                      border: '1px solid #bbf7d0',
                      color: '#16a34a',
                      fontSize: '0.75rem',
                      padding: '0.2rem 0.5rem',
                      borderRadius: '4px',
                      cursor: 'pointer',
                      fontWeight: 600,
                    }}
                  >
                    Admin: 9876500001
                  </button>
                  <button
                    type="button"
                    onClick={() => setPhoneNumber('9876500003')}
                    style={{
                      background: '#fef2f2',
                      border: '1px solid #fecaca',
                      color: '#dc2626',
                      fontSize: '0.75rem',
                      padding: '0.2rem 0.5rem',
                      borderRadius: '4px',
                      cursor: 'pointer',
                      fontWeight: 600,
                    }}
                  >
                    Parent: 9876500003 (Rejection Test)
                  </button>
                </div>
              </div>
            </div>

            <button
              type="submit"
              className="btn btn-primary"
              style={{ width: '100%' }}
              disabled={loading}
            >
              {loading ? 'Sending OTP...' : 'Send Verification Code'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp}>
            <div style={{ marginBottom: '1.25rem' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '0.85rem',
                  fontWeight: 600,
                  color: '#1e293b',
                  marginBottom: '0.5rem',
                }}
              >
                Enter 6-Digit SMS Code
              </label>
              <input
                type="text"
                className="input-field"
                placeholder="123456"
                maxLength="6"
                value={otpCode}
                onChange={(e) => setOtpCode(e.target.value)}
                style={{ textAlign: 'center', letterSpacing: '0.5rem', fontSize: '1.3rem', fontWeight: 'bold' }}
                autoFocus
                required
              />
              <span style={{ fontSize: '0.78rem', color: '#64748b', marginTop: '0.35rem', display: 'block' }}>
                Code sent to +91 {phoneNumber} (Test Code: <strong>123456</strong>)
              </span>
            </div>

            <button
              type="submit"
              className="btn btn-primary"
              style={{ width: '100%', marginBottom: '0.75rem' }}
              disabled={loading}
            >
              {loading ? 'Verifying...' : 'Verify & Sign In'}
            </button>

            <button
              type="button"
              className="btn btn-outline"
              style={{ width: '100%' }}
              onClick={() => {
                setConfirmationResult(null);
                setOtpCode('');
                setError(null);
              }}
            >
              Change Phone Number
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
