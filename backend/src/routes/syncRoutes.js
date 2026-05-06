const express = require('express');
const UserProfile = require('../models/UserProfile');
const TutoringSession = require('../models/TutoringSession');

const router = express.Router();

router.post('/sync', async (req, res) => {
  try {
    const { profiles = [], sessions = [] } = req.body;

    if (!Array.isArray(profiles) || !Array.isArray(sessions)) {
      return res.status(400).json({
        ok: false,
        message: 'profiles and sessions must be arrays',
      });
    }

    for (const profile of profiles) {
      await UserProfile.findOneAndUpdate(
        { id: profile.id },
        { ...profile },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
    }

    for (const session of sessions) {
      await TutoringSession.findOneAndUpdate(
        { id: session.id },
        { ...session, isSynced: true },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
    }

    return res.json({
      ok: true,
      message: 'Sync completed',
      totals: {
        profiles: profiles.length,
        sessions: sessions.length,
      },
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      message: 'Sync failed',
      error: error.message,
    });
  }
});

router.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'peer-tutoring-backend' });
});

module.exports = router;
