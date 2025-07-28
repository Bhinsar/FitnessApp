const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const mealLogSchema = new Schema({
    // Links this log to a specific user.
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    // The image the user uploaded, stored as a URL (e.g., from a cloud storage bucket).
    imageUrl: {
        type: String,
        required: false // May not exist if the user logged manually.
    },
    // Summary of the entire meal's nutritional information.
    mealSummary: {
        totalCalories: { type: Number, default: 0 },
        totalProteinG: { type: Number, default: 0 },
        totalCarbsG: { type: Number, default: 0 },
        totalFatG: { type: Number, default: 0 }
    },
    // An array of individual food items identified in the meal.
    items: [{
        foodName: { type: String, required: true },
        estimatedWeightG: { type: Number },
        calories: { type: Number, required: true },
        proteinG: { type: Number },
        carbsG: { type: Number },
        fatG: { type: Number }
    }],
    // The user can add their own notes or confirm the AI's analysis.
    userNotes: {
        type: String,
        trim: true
    }
}, {
    timestamps: true,
    strick: false
});

module.exports = mongoose.model("MealLog", mealLogSchema);