import './Communities.css'

function Communities({ communities }) {
  return (
    <section id="communities" className="section">
      <div className="container">
        <h2>Active Communities</h2>
        <div className="communities-grid">
          {communities.map((community) => (
            <div key={community.id} className="community-card fade-in">
              <div className="community-icon">
                <i className={`fas ${community.icon}`}></i>
              </div>
              <h3>{community.name}</h3>
              <p>{community.description}</p>
              <p><i className="fas fa-map-marker-alt"></i> {community.location}</p>
              <div className="community-stats">
                <div className="community-stat">
                  <div className="community-stat-number">{community.members}</div>
                  <div className="community-stat-label">Members</div>
                </div>
                <div className="community-stat">
                  <div className="community-stat-number">{community.activeWorks}</div>
                  <div className="community-stat-label">Active Works</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Communities
