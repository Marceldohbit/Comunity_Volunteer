const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) {
        console.log('No token provided');
        return res.sendStatus(401);
    }

    const jwtSecret = process.env.JWT_SECRET || 'fallback_secret';
    
    jwt.verify(token, jwtSecret, (err, user) => {
        if (err) {
            console.log('JWT verification error:', err.message);
            return res.sendStatus(403);
        }
        req.user = user;
        console.log('Authenticated user:', user);
        next();
    });
};

module.exports = authenticateToken;
