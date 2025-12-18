// Community Serve - JavaScript Application
class CommunityServe {
    constructor() {
        this.apiUrl = 'http://localhost:3000/api';
        this.communities = [];
        this.works = [];
        this.categories = [];
        this.regions = [];

        this.works = [
            {
                id: 1,
                title: "Community Garden Expansion",
                description: "Expanding our community garden to provide fresh produce for local food banks and teach sustainable gardening practices.",
                communityId: 1,
                community: "Green Valley Neighborhood",
                category: "environment",
                volunteersNeeded: 20,
                volunteersSignedUp: 14,
                startDate: "2025-01-15",
                endDate: "2025-04-30",
                location: "Green Valley Park",
                icon: "fa-seedling"
            },
            {
                id: 2,
                title: "After-School Tutoring Program",
                description: "Providing academic support and mentorship for elementary and middle school students in math, reading, and science.",
                communityId: 3,
                community: "Riverside Youth Network",
                category: "education",
                volunteersNeeded: 15,
                volunteersSignedUp: 12,
                startDate: "2025-01-08",
                endDate: "2025-06-15",
                location: "Riverside Community Center",
                icon: "fa-book"
            },
            {
                id: 3,
                title: "Senior Companion Program",
                description: "Weekly visits and companionship for elderly residents in nursing homes and assisted living facilities.",
                communityId: 4,
                community: "Elderly Care Alliance",
                category: "elderly",
                volunteersNeeded: 25,
                volunteersSignedUp: 18,
                startDate: "2025-01-01",
                endDate: "2025-12-31",
                location: "Multiple Facilities",
                icon: "fa-handshake"
            },
            {
                id: 4,
                title: "Homeless Shelter Meal Prep",
                description: "Preparing and serving meals at the downtown homeless shelter, providing nutrition and dignity to those in need.",
                communityId: 2,
                community: "Downtown Urban Center",
                category: "social",
                volunteersNeeded: 30,
                volunteersSignedUp: 28,
                startDate: "2025-01-01",
                endDate: "2025-12-31",
                location: "Hope Shelter Downtown",
                icon: "fa-utensils"
            },
            {
                id: 5,
                title: "River Cleanup Initiative",
                description: "Monthly river cleanup events to remove trash and restore natural habitat for local wildlife.",
                communityId: 5,
                community: "Environmental Action Group",
                category: "environment",
                volunteersNeeded: 40,
                volunteersSignedUp: 35,
                startDate: "2025-01-12",
                endDate: "2025-12-14",
                location: "Riverside Trail",
                icon: "fa-water"
            },
            {
                id: 6,
                title: "Mobile Health Clinic Support",
                description: "Assisting healthcare professionals in providing free health screenings and basic medical care to underserved communities.",
                communityId: 2,
                community: "Downtown Urban Center",
                category: "health",
                volunteersNeeded: 12,
                volunteersSignedUp: 8,
                startDate: "2025-02-01",
                endDate: "2025-11-30",
                location: "Various Neighborhoods",
                icon: "fa-stethoscope"
            },
            {
                id: 7,
                title: "Youth Mentorship Program",
                description: "One-on-one mentoring for at-risk youth, providing guidance, support, and positive role models.",
                communityId: 3,
                community: "Riverside Youth Network",
                category: "youth",
                volunteersNeeded: 20,
                volunteersSignedUp: 16,
                startDate: "2025-01-20",
                endDate: "2025-12-20",
                location: "Riverside Community Center",
                icon: "fa-users"
            },
            {
                id: 8,
                title: "Food Bank Distribution",
                description: "Sorting, packing, and distributing food donations to families in need throughout the community.",
                communityId: 6,
                community: "Food Security Network",
                category: "social",
                volunteersNeeded: 35,
                volunteersSignedUp: 31,
                startDate: "2025-01-01",
                endDate: "2025-12-31",
                location: "Central Food Bank",
                icon: "fa-box"
            },
            {
                id: 9,
                title: "Digital Literacy Classes",
                description: "Teaching basic computer skills and internet safety to seniors and low-income families.",
                communityId: 4,
                community: "Elderly Care Alliance",
                category: "education",
                volunteersNeeded: 10,
                volunteersSignedUp: 7,
                startDate: "2025-02-15",
                endDate: "2025-08-15",
                location: "Public Library",
                icon: "fa-laptop"
            }
        ];

        this.volunteers = this.loadVolunteers();
        this.init();
    }

    async init() {
        await this.loadData();
        this.updateStats();
        this.renderCommunities();
        this.renderWorks();
        this.setupEventListeners();
        this.populateVolunteerCommunityOptions();
        this.populateCommunityFilter();
    }

    // API methods
    async fetchAPI(endpoint, params = {}) {
        try {
            const queryString = new URLSearchParams(params).toString();
            const url = queryString ? `${this.apiUrl}${endpoint}?${queryString}` : `${this.apiUrl}${endpoint}`;
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
    }

    async loadData() {
        try {
            // Load communities
            const communitiesResponse = await this.fetchAPI('/communities');
            if (communitiesResponse.success) {
                this.communities = communitiesResponse.data.map(c => ({
                    id: c.id,
                    name: c.slug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' '),
                    description: c.description,
                    location: c.city + (c.region_name ? ', ' + c.region_name : ''),
                    members: c.member_count,
                    activeWorks: c.active_works_count,
                    icon: c.icon || 'fa-home'
                }));
            }

            // Load works
            const worksResponse = await this.fetchAPI('/works');
            if (worksResponse.success) {
                this.works = worksResponse.data.map(w => ({
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
            }

            // Load categories
            const categoriesResponse = await this.fetchAPI('/categories');
            if (categoriesResponse.success) {
                this.categories = categoriesResponse.data;
            }

            // Load regions
            const regionsResponse = await this.fetchAPI('/regions');
            if (regionsResponse.success) {
                this.regions = regionsResponse.data;
            }

            // Load stats
            const statsResponse = await this.fetchAPI('/stats');
            if (statsResponse.success) {
                this.stats = statsResponse.data;
            }
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // Statistics Updates
    updateStats() {
        if (this.stats) {
            this.animateCounter('total-works', this.stats.total_works);
            this.animateCounter('total-volunteers', this.stats.total_volunteers);
            this.animateCounter('total-communities', this.stats.total_communities);
        } else {
            const totalWorks = this.works.length;
            const totalVolunteers = this.works.reduce((sum, work) => sum + work.volunteersSignedUp, 0) + this.volunteers.length;
            const totalCommunities = this.communities.length;

            this.animateCounter('total-works', totalWorks);
            this.animateCounter('total-volunteers', totalVolunteers);
            this.animateCounter('total-communities', totalCommunities);
        }
    }

    animateCounter(elementId, targetValue) {
        const element = document.getElementById(elementId);
        if (!element) return;

        let current = 0;
        const increment = Math.ceil(targetValue / 30);
        const timer = setInterval(() => {
            current += increment;
            if (current >= targetValue) {
                current = targetValue;
                clearInterval(timer);
            }
            element.textContent = current;
        }, 50);
    }

    // Community Rendering
    renderCommunities() {
        const container = document.getElementById('communities-grid');
        if (!container) return;

        container.innerHTML = this.communities.map(community => `
            <div class="community-card fade-in">
                <div class="community-icon">
                    <i class="fas ${community.icon}"></i>
                </div>
                <h3>${community.name}</h3>
                <p>${community.description}</p>
                <p><i class="fas fa-map-marker-alt"></i> ${community.location}</p>
                <div class="community-stats">
                    <div class="community-stat">
                        <div class="community-stat-number">${community.members}</div>
                        <div class="community-stat-label">Members</div>
                    </div>
                    <div class="community-stat">
                        <div class="community-stat-number">${community.activeWorks}</div>
                        <div class="community-stat-label">Active Works</div>
                    </div>
                </div>
            </div>
        `).join('');
    }

    // Works Rendering
    renderWorks(filteredWorks = null) {
        const container = document.getElementById('works-grid');
        if (!container) return;

        const worksToRender = filteredWorks || this.works;

        if (worksToRender.length === 0) {
            container.innerHTML = `
                <div class="no-results" style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                    <i class="fas fa-search" style="font-size: 3rem; color: #ccc; margin-bottom: 1rem;"></i>
                    <h3 style="color: #666;">No works found</h3>
                    <p style="color: #999;">Try adjusting your search or filter criteria.</p>
                </div>
            `;
            return;
        }

        container.innerHTML = worksToRender.map(work => {
            const progressPercentage = (work.volunteersSignedUp / work.volunteersNeeded) * 100;
            const spotsLeft = work.volunteersNeeded - work.volunteersSignedUp;
            
            return `
                <div class="work-card fade-in" data-work-id="${work.id}">
                    <div class="work-image">
                        <i class="fas ${work.icon}"></i>
                    </div>
                    <div class="work-content">
                        <h3>${work.title}</h3>
                        <div class="work-meta">
                            <span><i class="fas fa-users"></i> ${work.community}</span>
                            <span><i class="fas fa-tag"></i> ${this.getCategoryDisplayName(work.category)}</span>
                            <span><i class="fas fa-map-marker-alt"></i> ${work.location}</span>
                        </div>
                        <p>${work.description}</p>
                        <div class="work-progress">
                            <div class="work-progress-label">
                                <span>Volunteer Progress</span>
                                <span>${work.volunteersSignedUp}/${work.volunteersNeeded}</span>
                            </div>
                            <div class="work-progress-bar">
                                <div class="work-progress-fill" style="width: ${progressPercentage}%"></div>
                            </div>
                        </div>
                        <div class="work-actions">
                            <button class="btn btn-primary btn-small volunteer-btn" data-work-id="${work.id}" ${spotsLeft <= 0 ? 'disabled' : ''}>
                                ${spotsLeft <= 0 ? 'Full' : `Join (${spotsLeft} spots left)`}
                            </button>
                            <button class="btn btn-outline btn-small learn-more-btn" data-work-id="${work.id}">
                                Learn More
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }

    getCategoryDisplayName(category) {
        const categoryNames = {
            'education': 'Education',
            'environment': 'Environment',
            'health': 'Health',
            'social': 'Social Services',
            'youth': 'Youth',
            'elderly': 'Elderly Care'
        };
        return categoryNames[category] || category;
    }

    // Search and Filter
    setupEventListeners() {
        // Search functionality
        const searchInput = document.getElementById('search-input');
        const searchBtn = document.getElementById('search-btn');

        if (searchInput) {
            searchInput.addEventListener('input', this.debounce(() => this.performSearch(), 300));
        }
        if (searchBtn) {
            searchBtn.addEventListener('click', () => this.performSearch());
        }

        // Filter functionality
        const communityFilter = document.getElementById('community-filter');
        const categoryFilter = document.getElementById('category-filter');

        if (communityFilter) {
            communityFilter.addEventListener('change', () => this.performSearch());
        }
        if (categoryFilter) {
            categoryFilter.addEventListener('change', () => this.performSearch());
        }

        // Volunteer form submission
        const volunteerForm = document.getElementById('volunteer-signup-form');
        if (volunteerForm) {
            volunteerForm.addEventListener('submit', (e) => this.handleVolunteerSignup(e));
        }

        // Work card interactions
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('volunteer-btn')) {
                const workId = parseInt(e.target.getAttribute('data-work-id'));
                this.quickVolunteerSignup(workId);
            } else if (e.target.classList.contains('learn-more-btn')) {
                const workId = parseInt(e.target.getAttribute('data-work-id'));
                this.showWorkDetails(workId);
            }
        });

        // Smooth scrolling for navigation
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Mobile menu toggle
        const navToggle = document.querySelector('.nav-toggle');
        const navMenu = document.querySelector('.nav-menu');
        
        if (navToggle && navMenu) {
            navToggle.addEventListener('click', () => {
                navMenu.classList.toggle('active');
            });
        }
    }

    performSearch() {
        const searchTerm = document.getElementById('search-input')?.value.toLowerCase() || '';
        const communityFilter = document.getElementById('community-filter')?.value || '';
        const categoryFilter = document.getElementById('category-filter')?.value || '';

        let filteredWorks = this.works;

        // Apply search term filter
        if (searchTerm) {
            filteredWorks = filteredWorks.filter(work => 
                work.title.toLowerCase().includes(searchTerm) ||
                work.description.toLowerCase().includes(searchTerm) ||
                work.community.toLowerCase().includes(searchTerm) ||
                work.location.toLowerCase().includes(searchTerm)
            );
        }

        // Apply community filter
        if (communityFilter) {
            filteredWorks = filteredWorks.filter(work => work.community === communityFilter);
        }

        // Apply category filter
        if (categoryFilter) {
            filteredWorks = filteredWorks.filter(work => work.category === categoryFilter);
        }

        this.renderWorks(filteredWorks);
    }

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // Volunteer Management
    loadVolunteers() {
        const stored = localStorage.getItem('community-serve-volunteers');
        return stored ? JSON.parse(stored) : [];
    }

    saveVolunteers() {
        localStorage.setItem('community-serve-volunteers', JSON.stringify(this.volunteers));
    }

    async handleVolunteerSignup(e) {
        e.preventDefault();
        
        const formData = new FormData(e.target);
        const interests = Array.from(document.querySelectorAll('input[type="checkbox"]:checked'))
            .map(cb => cb.value);

        const volunteerData = {
            work_id: 1, // You can modify this to select specific work
            name: document.getElementById('volunteer-name').value,
            email: document.getElementById('volunteer-email').value,
            phone: document.getElementById('volunteer-phone').value,
            interests: interests.join(', '),
            message: `Volunteer application - Interested in: ${interests.join(', ')}`,
            emergency_name: document.getElementById('volunteer-name').value,
            emergency_phone: document.getElementById('volunteer-phone').value,
            transportation: true
        };

        // Check if email already exists locally
        if (this.volunteers.some(v => v.email === volunteerData.email)) {
            this.showMessage('You are already registered as a volunteer!', 'warning');
            return;
        }

        // Send to API
        try {
            const response = await fetch(this.apiUrl + '/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(volunteerData)
            });

            const result = await response.json();

            if (result.success) {
                // Store locally
                const volunteer = {
                    id: result.registration_id,
                    name: volunteerData.name,
                    email: volunteerData.email,
                    phone: volunteerData.phone,
                    community: document.getElementById('volunteer-community').value,
                    interests: interests,
                    availability: document.getElementById('volunteer-availability').value,
                    signupDate: new Date().toISOString()
                };
                
                this.volunteers.push(volunteer);
                this.saveVolunteers();

                // Reset form
                e.target.reset();

                // Show success message
                this.showMessage(result.message || 'Thank you for signing up! We will contact you soon.', 'success');
                this.updateStats();
            } else {
                this.showMessage(result.error || 'Registration failed. Please try again.', 'error');
            }
        } catch (error) {
            console.error('Registration error:', error);
            this.showMessage('Network error. Please check your connection and try again.', 'error');
        }
    }

    quickVolunteerSignup(workId) {
        const work = this.works.find(w => w.id === workId);
        if (!work) return;

        if (work.volunteersSignedUp >= work.volunteersNeeded) {
            this.showMessage('Sorry, this work is already full!', 'warning');
            return;
        }

        // Simple quick signup (in real app, this would require proper form)
        const name = prompt(`Sign up to volunteer for "${work.title}"?\n\nPlease enter your name:`);
        if (!name) return;

        const email = prompt('Please enter your email:');
        if (!email) return;

        // Add to volunteers
        const volunteer = {
            id: Date.now(),
            name: name,
            email: email,
            workId: workId,
            signupDate: new Date().toISOString()
        };

        this.volunteers.push(volunteer);
        this.saveVolunteers();

        // Update work volunteer count
        work.volunteersSignedUp++;

        // Re-render works to show updated counts
        this.renderWorks();
        this.updateStats();

        this.showMessage(`Thank you, ${name}! You've successfully signed up to volunteer for "${work.title}".`, 'success');
    }

    showWorkDetails(workId) {
        const work = this.works.find(w => w.id === workId);
        if (!work) return;

        const startDate = new Date(work.startDate).toLocaleDateString();
        const endDate = new Date(work.endDate).toLocaleDateString();

        alert(`${work.title}\n\nCommunity: ${work.community}\nLocation: ${work.location}\nDates: ${startDate} - ${endDate}\n\nDescription: ${work.description}\n\nVolunteers: ${work.volunteersSignedUp}/${work.volunteersNeeded}\n\nClick "Join" to sign up as a volunteer!`);
    }

    populateVolunteerCommunityOptions() {
        const select = document.getElementById('volunteer-community');
        if (!select) return;

        this.communities.forEach(community => {
            const option = document.createElement('option');
            option.value = community.name;
            option.textContent = community.name;
            select.appendChild(option);
        });
    }

    populateCommunityFilter() {
        const select = document.getElementById('community-filter');
        if (!select) return;

        const uniqueCommunities = [...new Set(this.works.map(work => work.community))];
        uniqueCommunities.forEach(community => {
            const option = document.createElement('option');
            option.value = community;
            option.textContent = community;
            select.appendChild(option);
        });
    }

    showMessage(message, type = 'success') {
        // Remove existing message
        const existing = document.querySelector('.success-message, .warning-message');
        if (existing) existing.remove();

        // Create new message
        const messageDiv = document.createElement('div');
        messageDiv.className = type === 'success' ? 'success-message' : 'warning-message';
        messageDiv.style.cssText = `
            position: fixed;
            top: 100px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1001;
            max-width: 500px;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
            ${type === 'success' ? 
                'background: #d4edda; border: 1px solid #c3e6cb; color: #155724;' : 
                'background: #fff3cd; border: 1px solid #ffeaa7; color: #856404;'
            }
        `;
        
        messageDiv.innerHTML = `
            <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'}"></i>
            ${message}
        `;

        document.body.appendChild(messageDiv);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (messageDiv.parentNode) {
                messageDiv.remove();
            }
        }, 5000);
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    new CommunityServe();
});