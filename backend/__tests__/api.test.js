const request = require('supertest');
const { app, pool } = require('../server'); // Adjust this path if your routes are in a different file

// Mock the database connection
jest.mock('mysql2/promise', () => {
    const mPool = {
        getConnection: jest.fn().mockResolvedValue({
            release: jest.fn(),
            query: jest.fn(),
        }),
        query: jest.fn(),
        end: jest.fn().mockResolvedValue(),
    };
    return {
        createPool: jest.fn(() => mPool),
    };
});


describe('API Endpoints', () => {
    afterAll(async () => {
        // Close the database connection pool after all tests
        await pool.end();
    });

    describe('GET /api/health', () => {
        it('should return 200 OK and a success message', async () => {
            const res = await request(app).get('/api/health');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('success', true);
            expect(res.body).toHaveProperty('message', 'Server is running');
        });
    });

    describe('POST /api/auth/login', () => {
        it('should return 400 if email or password are not provided', async () => {
            const res = await request(app)
                .post('/api/auth/login')
                .send({});
            expect(res.statusCode).toEqual(400);
            expect(res.body).toHaveProperty('error', 'Email and password are required');
        });

        it('should return 401 for invalid credentials', async () => {
            // Mock the database query to return no user
            pool.query.mockResolvedValue([[]]);

            const res = await request(app)
                .post('/api/auth/login')
                .send({ email: 'wrong@example.com', password: 'wrongpassword' });

            expect(res.statusCode).toEqual(401);
            expect(res.body).toHaveProperty('error', 'Invalid credentials');
        });

        it('should return a token for valid credentials', async () => {
            // Mock the database query to return a user
            const mockUser = { id: 1, email: 'test@example.com', password: 'password', role: 'admin' };
            pool.query.mockResolvedValue([[mockUser]]);

            const res = await request(app)
                .post('/api/auth/login')
                .send({ email: 'test@example.com', password: 'password' });

            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('success', true);

            expect(res.body).toHaveProperty('accessToken');
        });
    });
});
