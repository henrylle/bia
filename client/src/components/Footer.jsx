import React from "react";
import { t } from "../i18n";
import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <div className="footer-content">
        <p>Formação AWS</p>
        <Link to="/about" className="footer-link">
          {t("sobre")}
        </Link>
      </div>
    </footer>
  );
};

export default Footer;
