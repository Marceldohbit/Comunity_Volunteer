import { useState, useEffect } from 'react'
import './App.css'
import Header from './components/Header'
import Hero from './components/Hero'
import SearchFilter from './components/SearchFilter'
import Communities from './components/Communities'
import Works from './components/Works'
import Volunteer from './components/Volunteer'
import About from './components/About'
import Footer from './components/Footer'

function App() {
  const apiUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';
  
  const [communities, setCommunities] = useState([]);
  const [works, setWorks] = useState([]);
  const [filteredWorks, setFilteredWorks] = useState([]);
  const [volunteers, setVolunteers] = useState([]);
  const [stats, setStats] = useState({
    totalWorks: 0,
    totalVolunteers: 0,
    totalCommunities: 0
  });
  const [searchTerm, setSearchTerm] = useState('');
  const [communityFilter, setCommunityFilter] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');

  // Load volunteers from localStorage
  useEffect(() => {
    const stored = localStorage.getItem('community-serve-volunteers');
    if (stored) {
      setVolunteers(JSON.parse(stored));
    }
  }, []);

  // Load data from API
  useEffect(() => {
    loadData();
  }, []);

  // Apply filters whenever search/filter values change
  useEffect(() => {
    applyFilters();
  }, [searchTerm, communityFilter, categoryFilter, works]);

  // Update stats whenever data changes
  useEffect(() => {
    updateStats();
  }, [works, volunteers, communities]);

  const loadData = async () => {
    try {
      // Load communities
      const communitiesResponse = await fetchAPI('/communities');
      if (communitiesResponse.success) {
        const mappedCommunities = communitiesResponse.data.map(c => ({
          id: c.id,
          name: c.slug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' '),
          description: c.description,
          location: c.city + (c.region_name ? ', ' + c.region_name : ''),
          members: c.member_count,
          activeWorks: c.active_works_count,
          icon: c.icon || 'fa-home'
        }));
        setCommunities(mappedCommunities);
      }

      // Load works
      const worksResponse = await fetchAPI('/works');
      if (worksResponse.success) {
        const mappedWorks = worksResponse.data.map(w => ({
          id: w.id,
          title: w.title,
          description: w.description,
          communityId: w.community_id,
          community: w.community_slug.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' '),
          category: w.category_name.toLowerCase().replace(/ & /g, '-').replace(/ /g, '-'),
          volunteersNeeded: w.volunteers_needed,
          volunteersSignedUp: w.volunteers_registered,
          startDate: w.start_date,
          endDate: w.end_date,
          location: w.city + (w.region_name ? ', ' + w.region_name : ''),
          icon: w.category_icon || 'fa-hand-heart'
        }));
        setWorks(mappedWorks);
        setFilteredWorks(mappedWorks);
      }

      // Load stats
      const statsResponse = await fetchAPI('/stats');
      if (statsResponse.success) {
        setStats({
          totalWorks: statsResponse.data.total_works,
          totalVolunteers: statsResponse.data.total_volunteers,
          totalCommunities: statsResponse.data.total_communities
        });
      }
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  const fetchAPI = async (endpoint, params = {}) => {
    try {
      const queryString = new URLSearchParams(params).toString();
      const url = queryString ? `${apiUrl}${endpoint}?${queryString}` : `${apiUrl}${endpoint}`;
      const response = await fetch(url);
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || 'API request failed');
      }
      
      return data;
    } catch (error) {
      console.error('API Error:', error);
      return { success: false, error: error.message };
    }
  };

  const updateStats = () => {
    if (!stats.totalWorks) {
      const totalWorks = works.length;
      const totalVolunteers = works.reduce((sum, work) => sum + work.volunteersSignedUp, 0) + volunteers.length;
      const totalCommunities = communities.length;

      setStats({
        totalWorks,
        totalVolunteers,
        totalCommunities
      });
    }
  };

  const applyFilters = () => {
    let filtered = [...works];

    // Apply search term filter
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(work => 
        work.title.toLowerCase().includes(term) ||
        work.description.toLowerCase().includes(term) ||
        work.community.toLowerCase().includes(term) ||
        work.location.toLowerCase().includes(term)
      );
    }

    // Apply community filter
    if (communityFilter) {
      filtered = filtered.filter(work => work.community === communityFilter);
    }

    // Apply category filter
    if (categoryFilter) {
      filtered = filtered.filter(work => work.category === categoryFilter);
    }

    setFilteredWorks(filtered);
  };

  const handleVolunteerSignup = async (volunteerData) => {
    try {
      const response = await fetch(apiUrl + '/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(volunteerData)
      });

      const result = await response.json();

      if (result.success) {
        const newVolunteer = {
          id: result.registration_id,
          name: volunteerData.name,
          email: volunteerData.email,
          phone: volunteerData.phone,
          signupDate: new Date().toISOString()
        };
        
        const updatedVolunteers = [...volunteers, newVolunteer];
        setVolunteers(updatedVolunteers);
        localStorage.setItem('community-serve-volunteers', JSON.stringify(updatedVolunteers));

        // Reload data to reflect updated counts
        await loadData();

        return { success: true, message: result.message || 'Thank you for signing up! We will contact you soon.' };
      } else {
        return { success: false, error: result.error || 'Registration failed. Please try again.' };
      }
    } catch (error) {
      console.error('Registration error:', error);
      return { success: false, error: 'Network error. Please check your connection and try again.' };
    }
  };

  const handleQuickVolunteerSignup = async (workId, name, email, phone) => {
    const work = works.find(w => w.id === workId);
    if (!work) return { success: false, error: 'Work not found' };

    if (work.volunteersSignedUp >= work.volunteersNeeded) {
      return { success: false, error: 'Sorry, this work is already full!' };
    }

    try {
      const volunteerData = {
        work_id: workId,
        name: name,
        email: email,
        phone: phone,
        interests: work.category,
        message: `Quick signup for ${work.title}`,
        motivation: `Interested in ${work.title}`,
        emergency_name: name,
        emergency_phone: phone,
        transportation: true
      };

      const response = await fetch(apiUrl + '/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(volunteerData)
      });

      const result = await response.json();

      if (result.success) {
        const volunteer = {
          id: result.registration_id,
          name: name,
          email: email,
          phone: phone,
          workId: workId,
          signupDate: new Date().toISOString()
        };

        const updatedVolunteers = [...volunteers, volunteer];
        setVolunteers(updatedVolunteers);
        localStorage.setItem('community-serve-volunteers', JSON.stringify(updatedVolunteers));

        // Reload data
        await loadData();

        return { success: true, message: `Thank you, ${name}! You've successfully signed up to volunteer for "${work.title}".` };
      } else {
        return { success: false, error: result.error || 'Registration failed. Please try again.' };
      }
    } catch (error) {
      console.error('Registration error:', error);
      return { success: false, error: 'Network error. Please try again.' };
    }
  };

  return (
    <div className="App">
      <Header />
      <main>
        <Hero stats={stats} />
        <SearchFilter 
          searchTerm={searchTerm}
          setSearchTerm={setSearchTerm}
          communityFilter={communityFilter}
          setCommunityFilter={setCommunityFilter}
          categoryFilter={categoryFilter}
          setCategoryFilter={setCategoryFilter}
          communities={communities}
          works={works}
        />
        <Communities communities={communities} />
        <Works 
          works={filteredWorks} 
          onQuickVolunteerSignup={handleQuickVolunteerSignup}
        />
        <Volunteer 
          communities={communities}
          onVolunteerSignup={handleVolunteerSignup}
        />
        <About />
      </main>
      <Footer />
    </div>
  )
}

export default App
