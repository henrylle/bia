import React from "react";
import { Link, useLocation } from "react-router-dom";
import { FaSun, FaMoon } from "react-icons/fa";
import { useTheme } from "../contexts/ThemeContext.jsx";
import VersionInfo from "./VersionInfo";

const Header = ({ title }) => {
  const { isDarkMode, toggleTheme } = useTheme();
  const location = useLocation();
  
  return (
    <header className="header">
      <div className="header-content">
        <h1>{title}</h1>
        <nav className="header-nav">
          <Link 
            to="/" 
            className={`nav-link ${location.pathname === '/' ? 'active' : ''}`}
          >
            📋 Tarefas
          </Link>
          <Link 
            to="/versao" 
            className={`nav-link ${location.pathname === '/versao' ? 'active' : ''}`}
          >
            🔧 Versão
          </Link>
          <Link 
            to="/about" 
            className={`nav-link ${location.pathname === '/about' ? 'active' : ''}`}
          >
            ℹ️ Sobre
          </Link>
        </nav>
      </div>
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
  title: "BIA 2025",
};

export default Header;
