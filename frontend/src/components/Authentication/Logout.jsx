import React from 'react';
import { logoutUser } from '../../services/magicAuthService';

const Logout = () => {
    const handleLogout = async () => {
        const result = await logoutUser();
        if (result.success) {
            // Navigate to login page or show a success message
        } else {
            // Show an error message
            console.error('Logout failed:', result.error);
        }
    };

    return (
        <button onClick={handleLogout}>Logout</button>
    );
};

export default Logout;
