import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import './Admin.css';

function Admin() {
    const apiUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';
    const [token, setToken] = useState(localStorage.getItem('token'));
    const [userRole, setUserRole] = useState(null);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [fullname, setFullname] = useState('');
    const [selectedRole, setSelectedRole] = useState('admin');
    const [isSignup, setIsSignup] = useState(false);
    const [communityName, setCommunityName] = useState('');
    const [communityDescription, setCommunityDescription] = useState('');
    const [applicants, setApplicants] = useState([]);
    const [communities, setCommunities] = useState([]);
    const [volunteerParticipation, setVolunteerParticipation] = useState([]);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (token) {
            fetchCommunities();
            fetchVolunteerParticipation();
        }
    }, [token]);

    // Fetch applicants after communities are loaded
    useEffect(() => {
        if (communities.length > 0) {
            fetchApplicants();
        }
    }, [communities]);

    const clearMessages = () => {
        setError('');
        setSuccess('');
    };

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        clearMessages();
        try {
            const response = await fetch(`${apiUrl}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password }),
            });
            const data = await response.json();
            if (data.success) {
                if (data.user.role === 'volunteer') {
                    setError('Volunteers should use the regular volunteer signup form. Redirecting...');
                    setTimeout(() => {
                        window.location.href = '/';
                    }, 2000);
                    return;
                }
                localStorage.setItem('token', data.accessToken);
                setToken(data.accessToken);
                setUserRole(data.user.role);
                setEmail('');
                setPassword('');
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to login');
        } finally {
            setLoading(false);
        }
    };

    const handleSignup = async (e) => {
        e.preventDefault();
        setLoading(true);
        clearMessages();
        try {
            const response = await fetch(`${apiUrl}/auth/signup`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password, fullname, role: selectedRole }),
            });
            const data = await response.json();
            if (data.success) {
                setSuccess(data.message);
                setEmail('');
                setPassword('');
                setFullname('');
                // Switch back to login form after successful signup
                setTimeout(() => {
                    setIsSignup(false);
                    clearMessages();
                }, 2000);
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to create account');
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('token');
        setToken(null);
        setUserRole(null);
        clearMessages();
    };

    const handleCreateCommunity = async (e) => {
        e.preventDefault();
        setLoading(true);
        clearMessages();
        try {
            const response = await fetch(`${apiUrl}/communities`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({
                    name: communityName,
                    description: communityDescription,
                    location: 'Default Location',
                    city: 'Default City',
                    contact_email: 'default@email.com',
                }),
            });
            const data = await response.json();
            if (data.success) {
                setSuccess('Community created successfully and is pending approval');
                setCommunityName('');
                setCommunityDescription('');
                // Refresh communities list
                fetchCommunities();
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to create community');
        } finally {
            setLoading(false);
        }
    };

    const fetchApplicants = async () => {
        try {
            // For now, fetch applicants from the first community the user has access to
            // In a more complex setup, you might want to aggregate from all communities
            const communityId = communities.length > 0 ? communities[0].id : 1;
            
            const response = await fetch(`${apiUrl}/communities/${communityId}/applicants`, {
                headers: { 'Authorization': `Bearer ${token}` },
            });
            const data = await response.json();
            if (data.success) {
                setApplicants(data.data);
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to fetch applicants');
        }
    };

    const fetchCommunities = async () => {
        try {
            const response = await fetch(`${apiUrl}/communities/all`, {
                headers: { 'Authorization': `Bearer ${token}` },
            });
            const data = await response.json();
            if (data.success) {
                setCommunities(data.communities);
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to fetch communities');
        }
    };

    const fetchVolunteerParticipation = async () => {
        try {
            const response = await fetch(`${apiUrl}/volunteer-participation`, {
                headers: { 'Authorization': `Bearer ${token}` },
            });
            const data = await response.json();
            if (data.success) {
                setVolunteerParticipation(data.data);
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to fetch volunteer participation');
        }
    };

    const handleAcceptApplicant = async (applicantId) => {
        setLoading(true);
        clearMessages();
        try {
            const response = await fetch(`${apiUrl}/applicants/${applicantId}/accept`, {
                method: 'PUT',
                headers: { 'Authorization': `Bearer ${token}` },
            });
            const data = await response.json();
            if (data.success) {
                setSuccess('Applicant accepted successfully');
                fetchApplicants();
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to accept applicant');
        } finally {
            setLoading(false);
        }
    };

    const handleApproveCommunity = async (communityId) => {
        setLoading(true);
        clearMessages();
        try {
            const response = await fetch(`${apiUrl}/communities/${communityId}/approve`, {
                method: 'PUT',
                headers: { 'Authorization': `Bearer ${token}` },
            });
            const data = await response.json();
            if (data.success) {
                setSuccess('Community approved successfully');
                fetchCommunities(); // Refresh the communities list
            } else {
                setError(data.error);
            }
        } catch (err) {
            setError('Failed to approve community');
        } finally {
            setLoading(false);
        }
    };

    if (!token) {
        return (
            <div className="admin-container">
                <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                    <Link to="/" style={{ textDecoration: 'none', color: '#007bff' }}>← Back to Home</Link>
                </div>
                <h2>{isSignup ? 'Create Account' : 'Login to Dashboard'}</h2>
                <form onSubmit={isSignup ? handleSignup : handleLogin}>
                    {error && <div className="error">{error}</div>}
                    {success && <div className="success">{success}</div>}
                    {isSignup && (
                        <input
                            type="text"
                            placeholder="Full Name"
                            value={fullname}
                            onChange={(e) => setFullname(e.target.value)}
                            required
                            disabled={loading}
                        />
                    )}
                    {isSignup && (
                        <div className="form-group">
                            <label htmlFor="role-select">Role</label>
                            <select
                                id="role-select"
                                value={selectedRole}
                                onChange={(e) => setSelectedRole(e.target.value)}
                                required
                                disabled={loading}
                            >
                                <option value="admin">System Administrator</option>
                                <option value="community_manager">Community Manager</option>
                                <option value="volunteer">Volunteer</option>
                            </select>
                            <small className="role-description">
                                {selectedRole === 'admin' && 'Full system access - manage all communities and users'}
                                {selectedRole === 'community_manager' && 'Manage your own communities and volunteers'}
                                {selectedRole === 'volunteer' && 'Note: Regular volunteers should use the volunteer signup form on the main page'}
                            </small>
                        </div>
                    )}
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        disabled={loading}
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                        disabled={loading}
                    />
                    <button type="submit" disabled={loading}>
                        {loading ? (isSignup ? 'Creating Account...' : 'Logging in...') : (isSignup ? 'Create Account' : 'Login')}
                    </button>
                </form>
                <div style={{ textAlign: 'center', marginTop: '1rem' }}>
                    <p>
                        {isSignup ? 'Already have an account?' : 'Don\'t have an account?'}{' '}
                        <button 
                            onClick={() => {
                                setIsSignup(!isSignup);
                                clearMessages();
                                setEmail('');
                                setPassword('');
                                setFullname('');
                                setSelectedRole('admin');
                            }}
                            style={{
                                background: 'none',
                                border: 'none',
                                color: '#007bff',
                                cursor: 'pointer',
                                textDecoration: 'underline',
                                padding: 0,
                                font: 'inherit'
                            }}
                            disabled={loading}
                        >
                            {isSignup ? 'Login here' : 'Signup here'}
                        </button>
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="admin-container">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
                <Link to="/" style={{ textDecoration: 'none', color: '#007bff' }}>← Back to Home</Link>
                <h2 style={{ margin: 0 }}>
                    {userRole === 'admin' ? 'Admin Dashboard' : 'Community Manager Dashboard'}
                </h2>
                <button onClick={handleLogout} className="logout-btn">Logout</button>
            </div>

            {success && <div className="success">{success}</div>}
            {error && <div className="error">{error}</div>}

            <div className="admin-section">
                <h3>Create Community</h3>
                <form onSubmit={handleCreateCommunity}>
                    <input
                        type="text"
                        placeholder="Community Name"
                        value={communityName}
                        onChange={(e) => setCommunityName(e.target.value)}
                        required
                        disabled={loading}
                    />
                    <textarea
                        placeholder="Community Description"
                        value={communityDescription}
                        onChange={(e) => setCommunityDescription(e.target.value)}
                        required
                        disabled={loading}
                        rows="4"
                    ></textarea>
                    <button type="submit" disabled={loading}>
                        {loading ? 'Creating...' : 'Create Community'}
                    </button>
                </form>
            </div>

            <div className="admin-section">
                <h3>{userRole === 'admin' ? 'All Communities & Volunteers' : 'My Communities & Volunteers'}</h3>
                {communities.length > 0 ? (
                    <div className="communities-overview">
                        {communities.map((community) => (
                            <div key={community.id} className="community-card">
                                <div className="community-header">
                                    <h4>{community.slug}</h4>
                                    <div className="community-stats">
                                        <span className="stat">
                                            <strong>{community.total_volunteers || 0}</strong> Total Volunteers
                                        </span>
                                        <span className="stat">
                                            <strong>{community.pending_volunteers || 0}</strong> Pending
                                        </span>
                                        <span className="stat">
                                            <strong>{community.approved_volunteers || 0}</strong> Approved
                                        </span>
                                        <span className="stat">
                                            <strong>{community.works?.length || 0}</strong> Works
                                        </span>
                                    </div>
                                </div>
                                <div className="community-details">
                                    <p><strong>Location:</strong> {community.city}, {community.region_name}</p>
                                    <p><strong>Status:</strong> {community.status} {community.is_verified ? '(Verified)' : '(Unverified)'}</p>
                                    <p><strong>Contact:</strong> {community.contact_email}</p>
                                    {community.status === 'pending_approval' && userRole === 'admin' && (
                                        <div className="community-actions">
                                            <button 
                                                onClick={() => handleApproveCommunity(community.id)}
                                                disabled={loading}
                                                className="approve-btn"
                                            >
                                                {loading ? 'Approving...' : 'Approve Community'}
                                            </button>
                                        </div>
                                    )}
                                </div>
                                
                                {community.works && community.works.length > 0 && (
                                    <div className="community-works">
                                        <h5>Volunteer Works:</h5>
                                        <ul>
                                            {community.works.map((work) => (
                                                <li key={work.id} className="work-item">
                                                    <strong>{work.title}</strong> - 
                                                    {work.volunteers_registered}/{work.volunteers_needed} volunteers 
                                                    ({work.status})
                                                </li>
                                            ))}
                                        </ul>
                                    </div>
                                )}
                                
                                {community.volunteers && community.volunteers.length > 0 && (
                                    <div className="community-volunteers">
                                        <h5>Recent Volunteers:</h5>
                                        <ul>
                                            {community.volunteers.slice(0, 5).map((volunteer) => (
                                                <li key={volunteer.id} className="volunteer-item">
                                                    <span className={`status-${volunteer.status}`}>
                                                        {volunteer.status.toUpperCase()}
                                                    </span>
                                                    <strong>{volunteer.work_title}</strong>
                                                    {volunteer.emergency_contact_name && (
                                                        <span> - Contact: {volunteer.emergency_contact_name}</span>
                                                    )}
                                                    <small> (Applied: {new Date(volunteer.created_at).toLocaleDateString()})</small>
                                                </li>
                                            ))}
                                            {community.volunteers.length > 5 && (
                                                <li className="more-volunteers">
                                                    ... and {community.volunteers.length - 5} more volunteers
                                                </li>
                                            )}
                                        </ul>
                                    </div>
                                )}
                                
                                {(!community.volunteers || community.volunteers.length === 0) && (
                                    <p className="no-volunteers">No volunteers registered yet.</p>
                                )}
                            </div>
                        ))}
                    </div>
                ) : (
                    <p>{userRole === 'admin' ? 'No communities found.' : 'You have no assigned communities yet.'}</p>
                )}
            </div>

            <div className="admin-section">
                <h3>Pending Applicants</h3>
                {applicants.length > 0 ? (
                    <ul className="applicants-list">
                        {applicants.map((applicant) => (
                            <li key={applicant.id} className="applicant-item">
                                <div className="applicant-info">
                                    <strong>Registration #{applicant.id}</strong>
                                    <br />
                                    <small>Work: {applicant.work_title || `Work ID: ${applicant.volunteer_work_id}`}</small>
                                    {applicant.application_message && (
                                        <>
                                            <br />
                                            <small>Message: {applicant.application_message}</small>
                                        </>
                                    )}
                                    {applicant.emergency_contact_name && (
                                        <>
                                            <br />
                                            <small>Contact: {applicant.emergency_contact_name}</small>
                                        </>
                                    )}
                                    {applicant.emergency_contact_phone && (
                                        <>
                                            <br />
                                            <small>Phone: {applicant.emergency_contact_phone}</small>
                                        </>
                                    )}
                                </div>
                                <button 
                                    onClick={() => handleAcceptApplicant(applicant.id)}
                                    disabled={loading}
                                >
                                    {loading ? 'Processing...' : 'Accept'}
                                </button>
                            </li>
                        ))}
                    </ul>
                ) : (
                    <p>No pending applicants.</p>
                )}
            </div>

            <div className="admin-section">
                <h3>Volunteer Participation Tracking</h3>
                {volunteerParticipation.length > 0 ? (
                    <div className="participation-table-container">
                        <table className="participation-table">
                            <thead>
                                <tr>
                                    <th>Volunteer Email</th>
                                    <th>Community</th>
                                    <th>Work Title</th>
                                    <th>Status</th>
                                    <th>Hours Completed</th>
                                    <th>Registration Date</th>
                                    <th>Contact Info</th>
                                </tr>
                            </thead>
                            <tbody>
                                {volunteerParticipation.map((participation) => (
                                    <tr key={participation.registration_id}>
                                        <td className="email-cell">
                                            {participation.volunteer_email || 'Email not found'}
                                        </td>
                                        <td>{participation.community_name}</td>
                                        <td>{participation.work_title}</td>
                                        <td>
                                            <span className={`status-badge status-${participation.status}`}>
                                                {participation.status}
                                            </span>
                                        </td>
                                        <td>{participation.hours_completed || 0} hrs</td>
                                        <td>{new Date(participation.registration_date).toLocaleDateString()}</td>
                                        <td>
                                            {participation.volunteer_contact && (
                                                <div>
                                                    <div>{participation.volunteer_contact}</div>
                                                    {participation.emergency_contact_phone && (
                                                        <small>{participation.emergency_contact_phone}</small>
                                                    )}
                                                </div>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                ) : (
                    <p>No volunteer participation records found.</p>
                )}
            </div>
        </div>
    );
}

export default Admin;
