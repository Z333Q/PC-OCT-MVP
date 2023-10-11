// src/components/Footer/index.jsx

import React from 'react';
import './styles.css';

const Footer = () => {
  return (
    <footer className="footer">
      <a href="https://twitter.com/PuckCity" target="_blank" rel="noopener noreferrer">
        <i className="fab fa-twitter"></i>
      </a>
      <a href="https://facebook.com/PuckCity" target="_blank" rel="noopener noreferrer">
        <i className="fab fa-facebook-f"></i>
      </a>
      <a href="https://instagram.com/PuckCity" target="_blank" rel="noopener noreferrer">
        <i className="fab fa-instagram"></i>
      </a>
      {/* ...other social media links */}
    </footer>
  );
};

export default Footer;
