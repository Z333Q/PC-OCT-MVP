import {
    loginWithMagic,
    loginWithGoogle,
    logout,
    isLoggedIn,
    getMagicInstance
} from '../utils/magic';

export const loginWithEmail = async (email) => {
    const result = await loginWithMagic(email);
    if (result.success) {
        return { success: true };
    } else {
        return { success: false, error: result.error };
    }
};

export const loginWithSocial = async () => {
    try {
        await loginWithGoogle();
        return { success: true };
    } catch (error) {
        console.error('Social login failed:', error);
        return { success: false, error };
    }
};

export const logoutUser = async () => {
    try {
        await logout();
        return { success: true };
    } catch (error) {
        console.error('Logout failed:', error);
        return { success: false, error };
    }
};

export const checkLoginStatus = async () => {
    return await isLoggedIn();
};

export const getMagic = () => {
    return getMagicInstance();
};
