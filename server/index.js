const express = require('express');
const sqlite3 = require('sqlite3');
const crypto = require('crypto')
const cors = require('cors');
const http = require("http");
const https = require("https");

const MAX_TITLE_PER_PAGE = 18;
const PORT = 5000;

const app = express();

// ✅ Explicit CORS config
app.use(cors({
    origin: '*', // 👈 allow all origins (for development)
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json()); // 👈 parses JSON body
// SQLite init
const db = new sqlite3.Database('videos_db.db', (err) => {
    if (err) {
        console.log('Could not connect to database', err);
    } else {
        console.log('Connected to database');
    }
});



const userDb = new sqlite3.Database('users_db.db', (err) => {
    if (err) console.log('Could not connect to user database', err);
    else {
        console.log('Connected to user database');
        // Ensure table exists
        userDb.run(`CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            token TEXT
        )`);
    }
});

userDb.run(`CREATE TABLE IF NOT EXISTS comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    videoId INTEGER NOT NULL,
    userId INTEGER NOT NULL,
    content TEXT NOT NULL,
    parentId INTEGER,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(userId) REFERENCES users(id)
)`);

// GET paginated videos
app.get("/page/:page_num", (req, res) => {
    const page = parseInt(req.params.page_num, 10);
    const limit = MAX_TITLE_PER_PAGE;

    if (isNaN(page) || page < 1) {
        return res.status(400).json({ error: 'Số trang không hợp lệ.' });
    }

    const offset = (page - 1) * limit;
    const countSql = "SELECT COUNT(*) as total FROM videos";

    db.get(countSql, [], (err, countRow) => {
        if (err) {
            console.error('Lỗi truy vấn cơ sở dữ liệu khi đếm video:', err.message);
            return res.status(500).json({ error: 'Lỗi máy chủ nội bộ.' });
        }

        const totalVideos = countRow.total;
        const totalPages = Math.ceil(totalVideos / limit);
        const sql = `SELECT * FROM videos ORDER BY id LIMIT ? OFFSET ?`;

        db.all(sql, [limit, offset], (err, rows) => {
            if (err) {
                console.error('Lỗi truy vấn cơ sở dữ liệu:', err.message);
                return res.status(500).json({ error: 'Lỗi máy chủ nội bộ.' });
            }

            res.status(200).json({
                message: 'Thành công',
                page: page,
                totalPages: totalPages,
                data: rows
            });
        });
    });
});

// GET video by id
app.get("/video/:id", (req, res) => {
    const id = parseInt(req.params.id, 10);

    if (isNaN(id)) {
        return res.status(400).json({ error: 'ID không hợp lệ.' });
    }

    const sql = "SELECT link FROM videos WHERE id = ?";

    db.get(sql, [id], (err, row) => {
        if (err) {
            console.error('Lỗi truy vấn cơ sở dữ liệu:', err.message);
            return res.status(500).json({ error: 'Lỗi máy chủ nội bộ.' });
        }

        if (row) {
            res.status(200).json({
                message: 'Thành công',
                url: row.link
            });
        } else {
            res.status(404).json({ error: 'Không tìm thấy video.' });
        }
    });
});


app.get("/proxy", (req, res) => {
    const targetUrl = req.query.url;
    if (!targetUrl) {
        return res.status(400).json({ error: "Thiếu URL cần proxy." });
    }

    try {
        const client = targetUrl.startsWith("https") ? https : http;

        const options = new URL(targetUrl);
        options.headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
                          "AppleWebKit/537.36 (KHTML, like Gecko) " +
                          "Chrome/120.0.0.0 Safari/537.36",
            "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
            "Referer": targetUrl, // 👈 some servers require a referer
            "Accept-Language": "en-US,en;q=0.9",
        };

        client.get(options, (response) => {
            if (response.statusCode !== 200) {
                res.status(response.statusCode).end();
                return;
            }

            res.setHeader("Content-Type", response.headers["content-type"] || "application/octet-stream");
            res.setHeader("Access-Control-Allow-Origin", "*");

            response.pipe(res);
        }).on("error", (err) => {
            console.error("Proxy error:", err.message);
            res.status(500).json({ error: "Lỗi proxy." });
        });
    } catch (err) {
        console.error("Unexpected proxy error:", err.message);
        res.status(500).json({ error: "Lỗi proxy." });
    }
});

app.post("/auth/register", (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ error: "Thiếu username hoặc password" });
    }

    userDb.run(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        [username, password],
        function (err) {
            if (err) {
                console.error("Register error:", err.message);
                return res.status(400).json({ error: "Tên tài khoản đã tồn tại" });
            }
            res.json({ message: "Đăng ký thành công", userId: this.lastID });
        }
    );
});

// Login
app.post("/auth/login", (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ error: "Thiếu username hoặc password" });
    }

    userDb.get(
        "SELECT * FROM users WHERE username = ? AND password = ?",
        [username, password],
        (err, row) => {
            if (err) {
                console.error("Login error:", err.message);
                return res.status(500).json({ error: "Lỗi máy chủ" });
            }
            if (!row) {
                return res.status(401).json({ error: "Sai tài khoản hoặc mật khẩu" });
            }

            // Generate token
            const token = crypto.randomBytes(24).toString("hex");
            userDb.run(
                "UPDATE users SET token = ? WHERE id = ?",
                [token, row.id],
                (err2) => {
                    if (err2) {
                        console.error("Token update error:", err2.message);
                        return res.status(500).json({ error: "Không thể lưu token" });
                    }
                    res.json({ message: "Đăng nhập thành công", token });
                }
            );
        }
    );
});

// Get auth key (requires username)
app.get("/auth/key/:username", (req, res) => {
    const username = req.params.username;
    userDb.get(
        "SELECT token FROM users WHERE username = ?",
        [username],
        (err, row) => {
            if (err) {
                console.error("Get key error:", err.message);
                return res.status(500).json({ error: "Lỗi máy chủ" });
            }
            if (!row || !row.token) {
                return res.status(404).json({ error: "Không tìm thấy token" });
            }
            res.json({ token: row.token });
        }
    );
});



function authMiddleware(req, res, next) {
    const token = req.headers['authorization'];
    if (!token) return res.status(401).json({ error: "Missing auth token" });

    userDb.get("SELECT * FROM users WHERE token = ?", [token], (err, user) => {
        if (err) return res.status(500).json({ error: "Server error" });
        if (!user) return res.status(401).json({ error: "Invalid token" });
        req.user = user; // attach user info to request
        next();
    });
}

// POST a comment
app.post("/comments", authMiddleware, (req, res) => {
    const { videoId, content, parentId } = req.body;
    if (!videoId || !content) {
        return res.status(400).json({ error: "Missing videoId or content" });
    }

    userDb.run(
        "INSERT INTO comments (videoId, userId, content, parentId) VALUES (?, ?, ?, ?)",
        [videoId, req.user.id, content, parentId || null],
        function(err) {
            if (err) return res.status(500).json({ error: "Failed to post comment" });
            res.json({ message: "Comment posted", commentId: this.lastID });
        }
    );
});

// GET comments for a video, including username and date, nested replies
app.get("/comments/:videoId", (req, res) => {
    const videoId = parseInt(req.params.videoId, 10);
    if (isNaN(videoId)) return res.status(400).json({ error: "Invalid videoId" });

    // Fetch all comments for the video
    const sql = `
        SELECT c.id, c.content, c.parentId, c.createdAt, u.username
        FROM comments c
        JOIN users u ON c.userId = u.id
        WHERE c.videoId = ?
        ORDER BY c.createdAt ASC
    `;

    userDb.all(sql, [videoId], (err, rows) => {
        if (err) return res.status(500).json({ error: "Failed to get comments" });

        // Convert flat list to nested structure
        const map = {};
        const rootComments = [];

        rows.forEach(r => {
            r.replies = [];
            map[r.id] = r;
            if (r.parentId) {
                if (map[r.parentId]) map[r.parentId].replies.push(r);
            } else {
                rootComments.push(r);
            }
        });

        res.json({ comments: rootComments });
    });
});



// ---------------- Search videos ----------------
app.get("/search", (req, res) => {
    const query = req.query.q;
    const page = parseInt(req.query.page, 10) || 1;
    const limit = MAX_TITLE_PER_PAGE;

    if (!query || query.trim() === "") {
        return res.status(400).json({ error: "Thiếu từ khóa tìm kiếm" });
    }

    const offset = (page - 1) * limit;
    const likeQuery = `%${query.trim()}%`;

    // Count total matching videos
    const countSql = "SELECT COUNT(*) as total FROM videos WHERE title LIKE ?";
    db.get(countSql, [likeQuery], (err, countRow) => {
        if (err) {
            console.error("Search count error:", err.message);
            return res.status(500).json({ error: "Lỗi máy chủ nội bộ." });
        }

        const totalVideos = countRow.total;
        const totalPages = Math.ceil(totalVideos / limit);

        // Fetch paginated search results
        const sql = `
            SELECT * FROM videos
            WHERE title LIKE ?
            ORDER BY id
            LIMIT ? OFFSET ?
        `;

        db.all(sql, [likeQuery, limit, offset], (err, rows) => {
            if (err) {
                console.error("Search query error:", err.message);
                return res.status(500).json({ error: "Lỗi máy chủ nội bộ." });
            }

            res.json({
                message: "Search success",
                query: query,
                page: page,
                totalPages: totalPages,
                data: rows
            });
        });
    });
});


// Start server
app.listen(PORT, function (err) {
    if (err) console.log("Error in server setup");
    console.log("Server listening on Port", PORT);
});
