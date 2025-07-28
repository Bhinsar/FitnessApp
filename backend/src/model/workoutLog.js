const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const workoutLogSchema = new Schema({
    // Links this log to a specific user.
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    // If this workout was based on a generated plan.
    aiPlan: {
        type: Schema.Types.ObjectId,
        ref: 'AIPlan',
        required: false
    },
    workoutName: {
        type: String,
        default: 'General Workout'
    },
    // Array of exercises performed during the session.
    exercises: [{
        name: { type: String, required: true },
        // Array of sets for this specific exercise.
        sets: [{
            reps: { type: Number, required: true },
            weightKg: { type: Number, default: 0 }, // 0 for bodyweight exercises.
            durationSeconds: { type: Number } // For timed exercises like planks.
        }]
    }],
    // The user's subjective feedback, which is valuable data for the AI.
    userFeedback: {
        difficulty: {
            type: String,
            enum: ['easy', 'moderate', 'challenging', 'very_hard']
        },
        notes: {
            type: String,
            trim: true
        }
    }
}, {
    timestamps: true,
    strict: false
});

module.exports = mongoose.model("WorkoutLog", workoutLogSchema);