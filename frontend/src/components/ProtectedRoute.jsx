// src/components/ProtectedRoute.jsx

import React, { useEffect, useState } from 'react';
import { Redirect } from 'react-router-dom';
import { checkLoginStatus } from '../services/magicAuthService';

const ProtectedRoute = ({ component: Component, ...rest }) => {

return (props) => {
    const [isAuthenticated, setIsAuthenticated] = useState(null);
    
    useEffect(() => {
      const checkAuth = async () => {
        const loggedIn = await checkLoginStatus();
        setIsAuthenticated(loggedIn);
      };
      
      checkAuth();
    }, []);
    
    if (isAuthenticated === null) {
      return null;  // or render a loading spinner
    }
    return isAuthenticated ? <Component {...rest} /> : <Redirect to="/login" />;
};
};

export default ProtectedRoute;
