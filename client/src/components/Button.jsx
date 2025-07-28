import React from "react";

const Button = ({ color, text, onClick }) => {
  return (
    <button
      onClick={onClick}
      className={`btn ${color ? color : ''}`}
    >
      {text}
    </button>
  );
};

Button.defaultProps = {
  color: "",
};

export default Button;
