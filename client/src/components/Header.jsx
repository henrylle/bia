import React from "react";
import { Link, useLocation } from "react-router-dom";
import { FaSun, FaMoon } from "react-icons/fa";
import { useTheme } from "../contexts/ThemeContext.jsx";
import VersionInfo from "./VersionInfo";

const Header = ({ title }) => {
  const { isDarkMode, toggleTheme } = useTheme();
  const location = useLocation();
  const chatEnabled = import.meta.env.VITE_ENABLE_CHAT === 'true';
  
  return (
    <header className="header">
      <h1>{title}</h1>
      <nav className="header-nav">
        <Link to="/" className={location.pathname === '/' ? 'active' : ''}>
          Tarefas
        </Link>
        <Link to="/about" className={location.pathname === '/about' ? 'active' : ''}>
          Sobre
        </Link>
        {chatEnabled && (
          <Link to="/chat" className={location.pathname === '/chat' ? 'active' : ''}>
            💬 Chat
          </Link>
        )}
      </nav>
      <div className="header-controls">
        <VersionInfo />
        <button 
          className="theme-toggle" 
          onClick={toggleTheme}
          title={isDarkMode ? "Tema claro" : "Tema escuro"}
        >
          {isDarkMode ? <FaSun /> : <FaMoon />}
        </button>
      </div>
    </header>
  );
};

Header.defaultProps = {
  title: "BIA 2026",
};

export default Header;
