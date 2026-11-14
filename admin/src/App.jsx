import React, { useState, useEffect } from 'react';
import { Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import Navbar from './components/Navbar';
import AdminLogin from './pages/AdminLogin';
import AdminDashboard from './pages/AdminDashboard';
import UnauthorizedPage from './pages/UnauthorizedPage';
import ProtectedRoute from './routing/ProtectedRoute';
import LoadingSpinner from './components/LoadingSpinner';
import { authService } from './services/authService';
import { UserRole } from './models/UserRole';

export default function App() {
  const [user, setUser] = useState(null);
  const [profile, setProfile] = useState(null);
  const [school, setSchool] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const unsubscribe = authService.onAuthStateChanged(async (firebaseUser) => {
      if (!firebaseUser) {
        setUser(null);
        setProfile(null);
        setSchool(null);
        setLoading(false);
        return;
      }

      try {
        const userProfile = await authService.getUserProfile(firebaseUser.uid);
        if (userProfile && userProfile.role === UserRole.ADMIN && userProfile.active) {
          setUser(firebaseUser);
          setProfile(userProfile);
          if (userProfile.schoolId) {
            const schoolData = await authService.getSchool(userProfile.schoolId);
            setSchool(schoolData);
          }
        } else {
          // Non-admin or inactive profile
          setUser(firebaseUser);
          setProfile(userProfile);
          setSchool(null);
        }
      } catch (err) {
        console.error('Failed to load admin profile:', err);
      } finally {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  const handleLogout = async () => {
    try {
      await authService.logout();
      setUser(null);
      setProfile(null);
      setSchool(null);
      navigate('/login');
    } catch (err) {
      console.error('Logout error:', err);
    }
  };

  const handleLoginSuccess = ({ user, profile, school }) => {
    setUser(user);
    setProfile(profile);
    setSchool(school);
  };

  if (loading) {
    return (
      <div className="admin-layout">
        <Navbar adminProfile={null} />
        <main className="main-content">
          <LoadingSpinner message="Checking administrative session..." />
        </main>
      </div>
    );
  }

  return (
    <div className="admin-layout">
      <Navbar adminProfile={profile} onLogout={handleLogout} />
      <main className="main-content">
        <Routes>
          <Route
            path="/login"
            element={
              user && profile?.role === UserRole.ADMIN ? (
                <Navigate to="/dashboard" replace />
              ) : (
                <AdminLogin onLoginSuccess={handleLoginSuccess} />
              )
            }
          />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute loading={loading} user={user} profile={profile}>
                <AdminDashboard
                  adminProfile={profile}
                  school={school}
                  onLogout={handleLogout}
                />
              </ProtectedRoute>
            }
          />
          <Route
            path="/unauthorized"
            element={<UnauthorizedPage onLogout={handleLogout} />}
          />
          <Route
            path="*"
            element={<Navigate to={user ? '/dashboard' : '/login'} replace />}
          />
        </Routes>
      </main>
    </div>
  );
}
