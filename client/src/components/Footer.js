import { Link } from "react-router-dom";

const Footer = () => {
  return (
    <footer>
      <p>Copyright Oregon EAD 2023</p>
      <Link to="/about">Sobre o BIA</Link>
    </footer>
  );
};

export default Footer;
