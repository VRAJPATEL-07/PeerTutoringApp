const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true, index: true },
    name: { type: String, required: true },
    role: { type: String, enum: ['tutor', 'learner', 'both'], required: true },
    subjects: { type: [String], default: [] },
    skillLevel: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      required: true,
    },
    availability: { type: [String], default: [] },
    isCurrentUser: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserProfile', userProfileSchema);
