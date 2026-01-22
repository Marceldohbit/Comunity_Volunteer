import './Footer.css'

function Footer() {
  const handleNavClick = (e, href) => {
    e.preventDefault();
    const target = document.querySelector(href);
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
  };

  return (
    <footer>
      <div className="container">
        <div className="footer-content">
          <div className="footer-section">
            <h4>Community Serve</h4>
            <p>Connecting volunteers with meaningful opportunities to serve their communities.</p>
          </div>
          <div className="footer-section">
            <h4>Quick Links</h4>
            <ul>
              <li><a href="#home" onClick={(e) => handleNavClick(e, '#home')}>Home</a></li>
              <li><a href="#communities" onClick={(e) => handleNavClick(e, '#communities')}>Communities</a></li>
              <li><a href="#works" onClick={(e) => handleNavClick(e, '#works')}>Works</a></li>
              <li><a href="#volunteer" onClick={(e) => handleNavClick(e, '#volunteer')}>Volunteer</a></li>
            </ul>
          </div>
          <div className="footer-section">
            <h4>Contact</h4>
            <p><i className="fas fa-envelope"></i> info@communityserve.org</p>
            <p><i className="fas fa-phone"></i> (555) 123-4567</p>
          </div>
          <div className="footer-section">
            <h4>Follow Us</h4>
            <div className="social-links">
              <a href="#"><i className="fab fa-facebook"></i></a>
              <a href="#"><i className="fab fa-twitter"></i></a>
              <a href="#"><i className="fab fa-instagram"></i></a>
              <a href="#"><i className="fab fa-linkedin"></i></a>
            </div>
          </div>
        </div>
        <div className="footer-bottom">
          <p>&copy; 2025 Community Serve. Made with ❤️ for stronger communities.</p>
        </div>
      </div>
    </footer>
  )
}

export default Footer
