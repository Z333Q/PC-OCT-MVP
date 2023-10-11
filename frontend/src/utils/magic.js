import { Magic } from 'magic-sdk';

// Creating a Magic instance for both email-based and social login
const magic = new Magic('pk_live_DAB0FAC332DD436A', {
    extensions: [
        new Magic.Extensions.GoogleOAuth(),
    ],
});

export const loginWithMagic = async (email) => {
    try {
        await magic.auth.loginWithMagicLink({ email });
        return { success: true };
    } catch (error) {
        console.error('Magic Link email failed:', error);
        return { success: false, error };
    }
};

export const loginWithGoogle = async () => {
    try {
        await magic.oauth.loginWithRedirect({
            provider: 'google',
            redirectURI: window.location.origin,
        });
    } catch (error) {
        console.error('Google login failed:', error);
    }
};

export const logout = async () => {
    try {
        await magic.user.logout();
    } catch (error) {
        console.error('Logout failed:', error);
    }
};

export const isLoggedIn = async () => {
    return await magic.user.isLoggedIn();
};

export const getMagicInstance = () => {
    return magic;
};
