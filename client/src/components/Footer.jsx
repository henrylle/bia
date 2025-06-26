import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <div className="footer-content">
        <p>Formação AWS 2025</p>
        <Link to="/about" className="footer-link">
          Sobre a BIA
        </Link>
      </div>
    </footer>
  );
};

export default Footer;
