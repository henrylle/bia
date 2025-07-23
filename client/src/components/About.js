import React from "react";
import { Link } from "react-router-dom";
import DadosHenrylle from "./DadosHenrylle";
const About = () => {
  return (
    <div>
      <h4>Versão 3.2.0</h4>
      <h5>BIA 28/07 a 03/08/2025</h5>
      <Link to="/">Voltar</Link>
      <DadosHenrylle />
    </div>
  );
};

export default About;
