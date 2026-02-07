import './About.css'

function About() {
  return (
    <section id="about" className="section about-section">
      <div className="container">
        <h2>About Community Serve</h2>
        <div className="about-content">
          <div className="about-text">
            <p>Community Serve is a platform that connects passionate volunteers with meaningful community works and projects. Our mission is to strengthen communities by making it easier for people to discover volunteer opportunities and see the positive impact happening around them.</p>
            <p>Whether you're looking to give back, develop new skills, or simply make new connections, Community Serve helps you find the perfect volunteer opportunity that matches your interests and schedule.</p>
          </div>
          <div className="about-features">
            <div className="feature">
              <i className="fas fa-search"></i>
              <h4>Discover</h4>
              <p>Find volunteer opportunities in your area</p>
            </div>
            <div className="feature">
              <i className="fas fa-handshake"></i>
              <h4>Connect</h4>
              <p>Join communities working on causes you care about</p>
            </div>
            <div className="feature">
              <i className="fas fa-chart-line"></i>
              <h4>Impact</h4>
              <p>See the real difference your volunteer work makes</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default About
