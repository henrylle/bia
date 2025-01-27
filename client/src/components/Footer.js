import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <p>Copyright Oregon EAD 2025</p>
      <Link to="/about">Sobre o BIA</Link>
    </footer>
  );
};

export default Footer;
