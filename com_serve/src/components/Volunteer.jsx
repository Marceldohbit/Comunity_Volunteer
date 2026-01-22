import { useState } from 'react'
import './Volunteer.css'

function Volunteer({ communities, onVolunteerSignup }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    community: '',
    availability: '',
    interests: []
  });
  const [message, setMessage] = useState(null);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleCheckboxChange = (e) => {
    const { value, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      interests: checked 
        ? [...prev.interests, value]
        : prev.interests.filter(i => i !== value)
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Find a work from the selected community to register for
    const communityWork = communities.find(c => c.name === formData.community);
    
    if (!communityWork) {
      showMessage('Please select a valid community.', 'warning');
      return;
    }

    const volunteerData = {
      work_id: communityWork.id,
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      interests: formData.interests.join(', '),
      message: `General volunteer application. Interested in: ${formData.interests.join(', ')}. Available: ${formData.availability}`,
      motivation: `I want to volunteer with ${formData.community}`,
      emergency_name: formData.name,
      emergency_phone: formData.phone,
      transportation: true
    };

    const result = await onVolunteerSignup(volunteerData);
    
    if (result.success) {
      showMessage(result.message, 'success');
      // Reset form
      setFormData({
        name: '',
        email: '',
        phone: '',
        community: '',
        availability: '',
        interests: []
      });
    } else {
      showMessage(result.error, 'error');
    }
  };

  const showMessage = (text, type) => {
    setMessage({ text, type });
    setTimeout(() => setMessage(null), 5000);
  };

  return (
    <section id="volunteer" className="section volunteer-section">
      <div className="container">
        <h2>Become a Volunteer</h2>
        {message && (
          <div className={`message ${message.type}`}>
            <i className={`fas ${message.type === 'success' ? 'fa-check-circle' : message.type === 'warning' ? 'fa-exclamation-triangle' : 'fa-times-circle'}`}></i>
            {message.text}
          </div>
        )}
        <div className="volunteer-content">
          <div className="volunteer-info">
            <h3>Why Volunteer?</h3>
            <ul>
              <li><i className="fas fa-heart"></i> Make a meaningful impact in your community</li>
              <li><i className="fas fa-users"></i> Connect with like-minded people</li>
              <li><i className="fas fa-star"></i> Develop new skills and experiences</li>
              <li><i className="fas fa-smile"></i> Feel the joy of helping others</li>
            </ul>
          </div>
          <div className="volunteer-form">
            <form onSubmit={handleSubmit}>
              <h3>Sign Up to Volunteer</h3>
              <div className="form-group">
                <label htmlFor="volunteer-name">Full Name</label>
                <input 
                  type="text" 
                  id="volunteer-name" 
                  name="name"
                  value={formData.name}
                  onChange={handleInputChange}
                  required 
                />
              </div>
              <div className="form-group">
                <label htmlFor="volunteer-email">Email</label>
                <input 
                  type="email" 
                  id="volunteer-email" 
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  required 
                />
              </div>
              <div className="form-group">
                <label htmlFor="volunteer-phone">Phone</label>
                <input 
                  type="tel" 
                  id="volunteer-phone" 
                  name="phone"
                  value={formData.phone}
                  onChange={handleInputChange}
                />
              </div>
              <div className="form-group">
                <label htmlFor="volunteer-community">Preferred Community</label>
                <select 
                  id="volunteer-community" 
                  name="community"
                  value={formData.community}
                  onChange={handleInputChange}
                  required
                >
                  <option value="">Select a community</option>
                  {communities.map((community) => (
                    <option key={community.id} value={community.name}>
                      {community.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label htmlFor="volunteer-interests">Areas of Interest</label>
                <div className="checkbox-group">
                  <label>
                    <input 
                      type="checkbox" 
                      value="education"
                      checked={formData.interests.includes('education')}
                      onChange={handleCheckboxChange}
                    /> Education
                  </label>
                  <label>
                    <input 
                      type="checkbox" 
                      value="environment"
                      checked={formData.interests.includes('environment')}
                      onChange={handleCheckboxChange}
                    /> Environment
                  </label>
                  <label>
                    <input 
                      type="checkbox" 
                      value="health"
                      checked={formData.interests.includes('health')}
                      onChange={handleCheckboxChange}
                    /> Health
                  </label>
                  <label>
                    <input 
                      type="checkbox" 
                      value="social"
                      checked={formData.interests.includes('social')}
                      onChange={handleCheckboxChange}
                    /> Social Services
                  </label>
                  <label>
                    <input 
                      type="checkbox" 
                      value="youth"
                      checked={formData.interests.includes('youth')}
                      onChange={handleCheckboxChange}
                    /> Youth
                  </label>
                  <label>
                    <input 
                      type="checkbox" 
                      value="elderly"
                      checked={formData.interests.includes('elderly')}
                      onChange={handleCheckboxChange}
                    /> Elderly Care
                  </label>
                </div>
              </div>
              <div className="form-group">
                <label htmlFor="volunteer-availability">Availability</label>
                <textarea 
                  id="volunteer-availability" 
                  name="availability"
                  value={formData.availability}
                  onChange={handleInputChange}
                  placeholder="When are you available? (weekdays, weekends, specific times)"
                ></textarea>
              </div>
              <button type="submit" className="btn btn-primary">Sign Up to Volunteer</button>
            </form>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Volunteer
