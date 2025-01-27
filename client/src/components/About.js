import React from "react";
import { Link } from "react-router-dom";
import DadosHenrylle from "./DadosHenrylle";
const About = () => {
  return (
    <div>
      <h4>Versão 3.2.0</h4>
      <h5>BIA 27/01 a 02/02/2025</h5>
      <Link to="/">Voltar</Link>
      <DadosHenrylle />
    </div>
  );
};

export default About;
