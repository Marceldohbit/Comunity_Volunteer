import { useState } from 'react'
import './Works.css'

function Works({ works, onQuickVolunteerSignup }) {
  const [message, setMessage] = useState(null);

  const getCategoryDisplayName = (category) => {
    const categoryNames = {
      'education': 'Education',
      'environment': 'Environment',
      'health': 'Health',
      'social': 'Social Services',
      'youth': 'Youth',
      'elderly': 'Elderly Care'
    };
    return categoryNames[category] || category;
  };

  const handleVolunteerClick = async (workId) => {
    const work = works.find(w => w.id === workId);
    if (!work) return;

    if (work.volunteersSignedUp >= work.volunteersNeeded) {
      showMessage('Sorry, this work is already full!', 'warning');
      return;
    }

    const name = prompt(`Sign up to volunteer for "${work.title}"?\n\nPlease enter your name:`);
    if (!name) return;

    const email = prompt('Please enter your email:');
    if (!email) return;

    const phone = prompt('Please enter your phone number:');
    if (!phone) return;

    const result = await onQuickVolunteerSignup(workId, name, email, phone);
    
    if (result.success) {
      showMessage(result.message, 'success');
    } else {
      showMessage(result.error, 'error');
    }
  };

  const handleLearnMore = (workId) => {
    const work = works.find(w => w.id === workId);
    if (!work) return;

    const startDate = new Date(work.startDate).toLocaleDateString();
    const endDate = new Date(work.endDate).toLocaleDateString();

    alert(`${work.title}\n\nCommunity: ${work.community}\nLocation: ${work.location}\nDates: ${startDate} - ${endDate}\n\nDescription: ${work.description}\n\nVolunteers: ${work.volunteersSignedUp}/${work.volunteersNeeded}\n\nClick "Join" to sign up as a volunteer!`);
  };

  const showMessage = (text, type) => {
    setMessage({ text, type });
    setTimeout(() => setMessage(null), 5000);
  };

  return (
    <section id="works" className="section">
      <div className="container">
        <h2>Community Works & Projects</h2>
        {message && (
          <div className={`message ${message.type}`}>
            <i className={`fas ${message.type === 'success' ? 'fa-check-circle' : message.type === 'warning' ? 'fa-exclamation-triangle' : 'fa-times-circle'}`}></i>
            {message.text}
          </div>
        )}
        <div className="works-grid">
          {works.length === 0 ? (
            <div className="no-results">
              <i className="fas fa-search"></i>
              <h3>No works found</h3>
              <p>Try adjusting your search or filter criteria.</p>
            </div>
          ) : (
            works.map((work) => {
              const progressPercentage = (work.volunteersSignedUp / work.volunteersNeeded) * 100;
              const spotsLeft = work.volunteersNeeded - work.volunteersSignedUp;
              
              return (
                <div key={work.id} className="work-card fade-in">
                  <div className="work-image">
                    <i className={`fas ${work.icon}`}></i>
                  </div>
                  <div className="work-content">
                    <h3>{work.title}</h3>
                    <div className="work-meta">
                      <span><i className="fas fa-users"></i> {work.community}</span>
                      <span><i className="fas fa-tag"></i> {getCategoryDisplayName(work.category)}</span>
                      <span><i className="fas fa-map-marker-alt"></i> {work.location}</span>
                    </div>
                    <p>{work.description}</p>
                    <div className="work-progress">
                      <div className="work-progress-label">
                        <span>Volunteer Progress</span>
                        <span>{work.volunteersSignedUp}/{work.volunteersNeeded}</span>
                      </div>
                      <div className="work-progress-bar">
                        <div className="work-progress-fill" style={{ width: `${progressPercentage}%` }}></div>
                      </div>
                    </div>
                    <div className="work-actions">
                      <button 
                        className="btn btn-primary btn-small volunteer-btn" 
                        onClick={() => handleVolunteerClick(work.id)}
                        disabled={spotsLeft <= 0}
                      >
                        {spotsLeft <= 0 ? 'Full' : `Join (${spotsLeft} spots left)`}
                      </button>
                      <button 
                        className="btn btn-outline btn-small learn-more-btn"
                        onClick={() => handleLearnMore(work.id)}
                      >
                        Learn More
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>
    </section>
  )
}

export default Works
