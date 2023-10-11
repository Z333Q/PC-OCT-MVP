// src/components/Header/index.jsx

import React from 'react';
import logo from '../../public/images/logo.png';  // Adjust the path to your logo image file
import './styles.css';

const Header = () => {
  return (
    <header className="header">
      <a href="/">
        <img src={logo} alt="Puck.City Logo" className="logo"/>
      </a>
    </header>
  );
};

export default Header;
