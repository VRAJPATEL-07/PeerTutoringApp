const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const syncRoutes = require('./routes/syncRoutes');

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;
const mongoUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/peer_tutoring_app';

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use('/api', syncRoutes);

async function startServer() {
  try {
    await mongoose.connect(mongoUri);
    console.log('MongoDB connected');

    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  }
}

startServer();
