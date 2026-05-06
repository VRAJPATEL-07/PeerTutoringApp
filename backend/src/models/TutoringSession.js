const mongoose = require('mongoose');

const tutoringSessionSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true, index: true },
    tutorId: { type: String, required: true },
    learnerId: { type: String, required: true },
    subject: { type: String, required: true },
    dateTime: { type: Date, required: true },
    status: {
      type: String,
      enum: ['scheduled', 'completed', 'cancelled'],
      required: true,
    },
    rating: { type: Number, min: 1, max: 5 },
    feedback: { type: String },
    isSynced: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('TutoringSession', tutoringSessionSchema);
