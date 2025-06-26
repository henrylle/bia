import React from "react";
import { Link } from "react-router-dom";
import DadosHenrylle from "./DadosHenrylle.jsx";

const About = () => {
  return (
    <div className="about-page">
      <div className="about-header">
        <div className="about-hero">
          <h2>BIA 2025</h2>
          <p className="about-subtitle">
            Bot Inteligente de Atividades
          </p>
        </div>
      </div>

      <div className="about-content">
        <div className="feature-grid">
          <div className="feature-card">
            <h3>Versão 4.2.0</h3>
            <p>Interface moderna com tema dark</p>
          </div>
          
          <div className="feature-card highlight">
            <h3>AWS & IA</h3>
            <p><strong>28/07 a 03/08/2025</strong><br/>Formação AWS</p>
          </div>
        </div>

        <DadosHenrylle />
      </div>

      <div className="about-footer">
        <Link to="/" className="back-button">
          ← Voltar
        </Link>
      </div>
    </div>
  );
};

export default About;
