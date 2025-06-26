import React from "react";

const DadosHenrylle = () => {
  return (
    <div className="dados-henrylle">
      <h3>Links Importantes</h3>
      <div className="links-grid">
        <a
          href="https://comunidade.imersaoaws.com.br"
          target="_blank"
          rel="noopener noreferrer"
          className="link-card"
        >
          <h4>🏠 Comunidade AWS</h4>
          <p>Bootcamp Imersão AWS</p>
        </a>
        
        <a
          href="https://inscricao.formacaoaws.com.br/suporte"
          target="_blank"
          rel="noopener noreferrer"
          className="link-card"
        >
          <h4>💬 Suporte</h4>
          <p>Formação AWS</p>
        </a>
        
        <a
          href="https://instagram.com/henryllemaia"
          target="_blank"
          rel="noopener noreferrer"
          className="link-card"
        >
          <h4>📸 Instagram</h4>
          <p>Henrylle Maia</p>
        </a>
        
        <a
          href="https://www.youtube.com/@henryllemaia"
          target="_blank"
          rel="noopener noreferrer"
          className="link-card"
        >
          <h4>🎥 YouTube</h4>
          <p>Canal oficial</p>
        </a>
        
        <a
          href="https://www.linkedin.com/in/henrylle/recent-activity/all/"
          target="_blank"
          rel="noopener noreferrer"
          className="link-card"
        >
          <h4>💼 LinkedIn</h4>
          <p>Desafio Labs AWS</p>
        </a>
      </div>
    </div>
  );
};

export default DadosHenrylle;
