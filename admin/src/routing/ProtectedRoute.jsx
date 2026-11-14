import React from 'react';
import { Navigate } from 'react-router-dom';
import LoadingSpinner from '../components/LoadingSpinner';
import { UserRole } from '../models/UserRole';

export default function ProtectedRoute({ loading, user, profile, children }) {
  if (loading) {
    return <LoadingSpinner message="Verifying administrator credentials..." />;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!profile || profile.role !== UserRole.ADMIN || !profile.active) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
}
