import React from "react";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <p>Copyright Formação AWS 2025</p>
      <Link to="/about">Sobre a BIA</Link>
    </footer>
  );
};

export default Footer;
