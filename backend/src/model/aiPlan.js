const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const aiPlanSchema = new Schema({
    // Links this plan to a specific user.
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    planType: {
        type: String,
        enum: ['workout', 'nutrition'],
        required: true
    },
    // The detailed plan content, stored as a flexible object.
    // This allows us to store different structures for different plan types.
    planDetails: {
        type: Object,
        required: true
    },
    // The prompt that was sent to the AI to generate this plan.
    // Storing this is great for debugging and fine-tuning.
    sourcePrompt: {
        type: String
    },
    // Add these two fields: to track the start and end dates of the plan.
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date,
        required: true
    },
}, {
    timestamps: true,
    strict: false
});

module.exports = mongoose.model("AIPlan", aiPlanSchema);