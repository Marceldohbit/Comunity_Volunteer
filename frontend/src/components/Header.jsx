import { useState } from 'react'
import { Link } from 'react-router-dom';
import './Header.css'

function Header() {
  const [menuOpen, setMenuOpen] = useState(false);

  const toggleMenu = () => {
    setMenuOpen(!menuOpen);
  };

  const handleNavClick = (e, href) => {
    if (href.startsWith('#')) {
      e.preventDefault();
      const target = document.querySelector(href);
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    }
    setMenuOpen(false);
  };

  return (
    <header>
      <nav className="navbar">
        <div className="nav-brand">
          <h1><i className="fas fa-hands-helping"></i> Community Serve</h1>
        </div>
        <ul className={`nav-menu ${menuOpen ? 'active' : ''}`}>
          <li><Link to="/" onClick={(e) => handleNavClick(e, '#home')}>Home</Link></li>
          <li><a href="#communities" onClick={(e) => handleNavClick(e, '#communities')}>Communities</a></li>
          <li><a href="#works" onClick={(e) => handleNavClick(e, '#works')}>Works</a></li>
          <li><a href="#volunteer" onClick={(e) => handleNavClick(e, '#volunteer')}>Volunteer</a></li>
          <li><a href="#volunteer-tracking" onClick={(e) => handleNavClick(e, '#volunteer-tracking')}>Tracking</a></li>
          <li><a href="#about" onClick={(e) => handleNavClick(e, '#about')}>About</a></li>
          <li><Link to="/admin">Admin</Link></li>
        </ul>
        <div className={`nav-toggle ${menuOpen ? 'active' : ''}`} onClick={toggleMenu}>
          <span></span>
          <span></span>
          <span></span>
        </div>
      </nav>
    </header>
  )
}

export default Header
