import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <div className="footer-content">
        <p>Formação AWS 2026</p>
        <Link to="/about" className="footer-link">

          Sobre a BIA - 09/02/2026   as 20h50    

        </Link>
      </div>
    </footer>
  );
};

export default Footer;
