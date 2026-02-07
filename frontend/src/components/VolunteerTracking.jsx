import { useState, useEffect } from 'react'
import './VolunteerTracking.css'

function VolunteerTracking() {
  const [participations, setParticipations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const apiUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';

  useEffect(() => {
    fetchPublicParticipation();
  }, []);

  const fetchPublicParticipation = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${apiUrl}/public/volunteer-participation`);
      const data = await response.json();
      if (data.success) {
        setParticipations(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Failed to fetch volunteer participation');
    } finally {
      setLoading(false);
    }
  };

  const filteredParticipations = participations.filter(p => 
    p.volunteer_email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.work_title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.community_name?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <section id="volunteer-tracking" className="section">
        <div className="container">
          <h2>Volunteer Participation Tracking</h2>
          <div className="loading">Loading volunteer data...</div>
        </div>
      </section>
    );
  }

  if (error) {
    return (
      <section id="volunteer-tracking" className="section">
        <div className="container">
          <h2>Volunteer Participation Tracking</h2>
          <div className="error">Error: {error}</div>
        </div>
      </section>
    );
  }

  return (
    <section id="volunteer-tracking" className="section">
      <div className="container">
        <h2>Volunteer Participation Tracking</h2>
        <p className="tracking-description">
          Track the impact of our amazing volunteers. Search by email, project, or community.
        </p>

        <div className="tracking-search-bar">
          <input
            type="text"
            placeholder="Search by volunteer email, project, or community..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        
        {filteredParticipations.length > 0 ? (
          <div className="tracking-grid">
            {filteredParticipations.map((participation) => (
              <div key={participation.registration_id} className="participation-card">
                <div className="participation-header">
                  <h3>{participation.work_title}</h3>
                  <span className={`status-badge status-${participation.status}`}>
                    {participation.status}
                  </span>
                </div>
                
                <div className="participation-details">
                  <p><strong>Community:</strong> {participation.community_name}</p>
                  <p><strong>Volunteer:</strong> {participation.volunteer_email || 'Anonymous Volunteer'}</p>
                  <p><strong>Hours Completed:</strong> {participation.hours_completed || 0} hrs</p>
                  <p><strong>Registration Date:</strong> {new Date(participation.registration_date).toLocaleDateString()}</p>
                  {participation.completed_at && (
                    <p><strong>Completed:</strong> {new Date(participation.completed_at).toLocaleDateString()}</p>
                  )}
                </div>
                
                {participation.application_message && (
                  <div className="participation-message">
                    <strong>Message:</strong>
                    <p>{participation.application_message}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        ) : (
          <div className="no-participation">
            <p>No matching participation records found.</p>
            {searchTerm ? (
              <p>Try a different search term.</p>
            ) : (
              <p>Be the first to volunteer and make a difference!</p>
            )}
          </div>
        )}

        <div className="tracking-stats">
          <div className="stat-item">
            <span className="stat-number">{filteredParticipations.length}</span>
            <span className="stat-label">Total Records</span>
          </div>
          <div className="stat-item">
            <span className="stat-number">
              {filteredParticipations.reduce((sum, p) => sum + (p.hours_completed || 0), 0)}
            </span>
            <span className="stat-label">Total Hours</span>
          </div>
          <div className="stat-item">
            <span className="stat-number">
              {filteredParticipations.filter(p => p.status === 'completed').length}
            </span>
            <span className="stat-label">Completed Projects</span>
          </div>
          <div className="stat-item">
            <span className="stat-number">
              {new Set(filteredParticipations.map(p => p.community_name)).size}
            </span>
            <span className="stat-label">Communities Served</span>
          </div>
        </div>
      </div>
    </section>
  )
}

export default VolunteerTracking