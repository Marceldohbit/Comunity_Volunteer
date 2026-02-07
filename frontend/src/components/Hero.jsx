import { useState, useEffect } from 'react'
import './Hero.css'

function Hero({ stats }) {
  const [animatedStats, setAnimatedStats] = useState({
    totalWorks: 0,
    totalVolunteers: 0,
    totalCommunities: 0
  });

  useEffect(() => {
    const animateCounter = (key, targetValue) => {
      let current = 0;
      const increment = Math.ceil(targetValue / 30);
      const timer = setInterval(() => {
        current += increment;
        if (current >= targetValue) {
          current = targetValue;
          clearInterval(timer);
        }
        setAnimatedStats(prev => ({ ...prev, [key]: current }));
      }, 50);
    };

    if (stats.totalWorks > 0) {
      animateCounter('totalWorks', stats.totalWorks);
      animateCounter('totalVolunteers', stats.totalVolunteers);
      animateCounter('totalCommunities', stats.totalCommunities);
    }
  }, [stats]);

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
    <section id="home" className="hero">
      <div className="hero-content">
        <h1>Make a Difference in Your Community</h1>
        <p>Discover meaningful volunteer opportunities and see the amazing works happening in communities around you.</p>
        <div className="hero-buttons">
          <a href="#works" className="btn btn-primary" onClick={(e) => handleNavClick(e, '#works')}>Explore Works</a>
          <a href="#volunteer" className="btn btn-secondary" onClick={(e) => handleNavClick(e, '#volunteer')}>Start Volunteering</a>
        </div>
      </div>
      <div className="hero-stats">
        <div className="stat">
          <span className="stat-number">{animatedStats.totalWorks}</span>
          <span className="stat-label">Active Works</span>
        </div>
        <div className="stat">
          <span className="stat-number">{animatedStats.totalVolunteers}</span>
          <span className="stat-label">Volunteers</span>
        </div>
        <div className="stat">
          <span className="stat-number">{animatedStats.totalCommunities}</span>
          <span className="stat-label">Communities</span>
        </div>
      </div>
    </section>
  )
}

export default Hero
