import './SearchFilter.css'

function SearchFilter({ 
  searchTerm, 
  setSearchTerm, 
  communityFilter, 
  setCommunityFilter, 
  categoryFilter, 
  setCategoryFilter,
  regionFilter,
  setRegionFilter,
  cityFilter,
  setCityFilter,
  communities,
  works,
  regions,
  cities
}) {
  const uniqueCommunities = [...new Set(works.map(work => work.community))];

  return (
    <section className="search-section">
      <div className="container">
        <div className="search-bar">
          <input 
            type="text" 
            id="search-input" 
            placeholder="Search for works, communities, or causes..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <button id="search-btn"><i className="fas fa-search"></i></button>
        </div>
        <div className="filters">
          <select 
            id="community-filter"
            value={communityFilter}
            onChange={(e) => setCommunityFilter(e.target.value)}
          >
            <option value="">All Communities</option>
            {uniqueCommunities.map((community, index) => (
              <option key={index} value={community}>{community}</option>
            ))}
          </select>
          <select 
            id="category-filter"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="">All Categories</option>
            <option value="education">Education</option>
            <option value="environment">Environment</option>
            <option value="health">Health</option>
            <option value="social">Social Services</option>
            <option value="youth">Youth</option>
            <option value="elderly">Elderly Care</option>
          </select>
          <select 
            id="region-filter"
            value={regionFilter}
            onChange={(e) => setRegionFilter(e.target.value)}
          >
            <option value="">All Regions</option>
            {regions.map((region) => (
              <option key={region.id} value={region.name}>{region.name}</option>
            ))}
          </select>
          <select 
            id="city-filter"
            value={cityFilter}
            onChange={(e) => setCityFilter(e.target.value)}
          >
            <option value="">All Cities</option>
            {cities.map((city, index) => (
              <option key={index} value={city}>{city}</option>
            ))}
          </select>
        </div>
      </div>
    </section>
  )
}

export default SearchFilter
