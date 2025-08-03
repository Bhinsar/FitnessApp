const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const userSchema = new Schema({
    email: {
        type: String,
        required: [true, 'Email is required.'],
        unique: true,
        trim: true,
        lowercase: true,
        match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please fill a valid email address']
    },
    // We will store the hashed password, not the plain text password.
    password: {
        type: String,
        required: [true, 'Password is required.'],
    },
    name: {
        type: String,
        required: [true, 'Name is required.'],
        trim: true
    },
    joinDate: {
        type: Date,
        default: Date.now
    },
    // Nested object for detailed user profile stats.
    profile: {
        // Storing date of birth allows for dynamic age calculation.
        dateOfBirth: {
            type: Date,
        },
        //user gender is important for personalized recommendations.
        gender: {
            type: String,
            enum: ['male', 'female']
        },
        // The user's preferred meal type for dietary recommendations.
        mealType: {
            type: String,
            enum: ['vegetarian', 'non-vegetarian', 'vegan'],
            default: 'vegetarian'
        },
        // We can store a history of weight entries to track progress.
        weight: {
            valueKg: { type: Number },
            date: { type: Date, default: Date.now }
        },
        heightCm: {
            type: Number,
        },
        // Goals will be used to tailor AI recommendations.
        goals: {
            type: [String],
            enum: ['lose_weight', 'build_muscle', 'improve_stamina', 'maintain_fitness', 'learn_exercises'],
            default: []
        },
        // Helps the AI determine the intensity of generated workouts.
        activityLevel: {
            type: String,
            enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
            default: 'sedentary'
        },
        // The AI will use this to create plans based on available equipment.
        availableEquipment: {
            type: [String],
            default: []
        }
    }
}, {
    // Automatically adds `createdAt` and `updatedAt` fields.
    strict: false,
    timestamps: true
});

module.exports = mongoose.model("User", userSchema);