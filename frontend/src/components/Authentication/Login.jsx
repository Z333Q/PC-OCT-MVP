import React, { useState } from 'react';
import { loginWithEmail, loginWithSocial } from '../../services/magicAuthService';

const Login = () => {
    const [email, setEmail] = useState('');

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    };

    const handleEmailLogin = async () => {
        const result = await loginWithEmail(email);
        if (result.success) {
            // Navigate to dashboard or show a success message
        } else {
            // Show an error message
            console.error('Login failed:', result.error);
        }
    };

    const handleSocialLogin = async () => {
        const result = await loginWithSocial();
        if (result.success) {
            // Navigate to dashboard or show a success message
        } else {
            // Show an error message
            console.error('Social login failed:', result.error);
        }
    };

    return (
        <div>
            <input
                type="email"
                value={email}
                onChange={handleEmailChange}
                placeholder="Enter your email"
            />
            <button onClick={handleEmailLogin}>Login with Email</button>
            <button onClick={handleSocialLogin}>Login with Google</button>
        </div>
    );
};

export default Login;
