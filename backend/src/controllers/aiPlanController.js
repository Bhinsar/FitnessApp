const AIPlan = require("../model/aiPlan");
const WorkoutLog = require("../model/workoutLog");
const User = require("../model/user");
const fetch = require("node-fetch");
const { fetchWithRetry, normalizeString } = require("../helper/aiplanhelper");


// Generate AI Plan
exports.generateAIWorkoutPlan = async (req, res) => {
  try {
    const user = req.user;

    // 1. Define IST boundaries for the current day
    const now = new Date();
    const istDate = new Date(now.toLocaleString("en-US", { timeZone: "Asia/Kolkata" }));
    const startOfDayIST = new Date(istDate);
    startOfDayIST.setHours(0, 0, 0, 0);
    const endOfDayIST = new Date(istDate);
    endOfDayIST.setHours(23, 59, 59, 999);

    // 2. Check if a plan already exists for today
    const todaysPlan = await AIPlan.findOne({
      user: user._id,
      planType: "workout",
      startDate: { $gte: startOfDayIST, $lt: endOfDayIST },
    });

    if (todaysPlan) {
      return res.status(200).json({
        message: "A workout plan for today already exists.",
        plan: todaysPlan,
      });
    }

    // 3. Fetch all available exercises from ExerciseDB via RapidAPI
    const EXERCISEDB_API_KEY = process.env.EXERCISEDB_API_KEY;
    const exerciseDbUrl = 'https://exercisedb.p.rapidapi.com/exercises';
    const exerciseOptions = {
      method: 'GET',
      headers: {
        'X-RapidAPI-Key': EXERCISEDB_API_KEY,
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com'
      }
    };
    const exerciseResponse = await fetchWithRetry(exerciseDbUrl, exerciseOptions);
    if (!exerciseResponse.ok) {
      throw new Error('Failed to fetch exercises from ExerciseDB.');
    }
    const allExercises = await exerciseResponse.json();
    const availableExerciseNames = allExercises.map(ex => ex.name).join(', ');

    // 4. Fetch user data and workout

    const workoutHistory = await WorkoutLog.find({ user: user._id }).sort({ createdAt: -1 }).limit(5);
    let historySummary = "This is a new user.";
    if (workoutHistory.length > 0) {
      historySummary = "Here is the user's recent workout history:\n";
      workoutHistory.forEach((log) => {
        historySummary += `On ${new Date(log.createdAt).toLocaleDateString("en-IN", { timeZone: "Asia/Kolkata" })}, they did: `;
        log.exercises.forEach((ex) => {
          const setsSummary = ex.sets.map((s) => `${s.reps} reps at ${s.weightKg}kg`).join(', ');
          historySummary += `${ex.name} - [${setsSummary}]. `;
        });
        if (log.userFeedback && log.userFeedback.difficulty) {
          historySummary += `User found it: ${log.userFeedback.difficulty}.\n`;
        }
      });
    }

    // 5. Construct the prompt for the Gemini model
    const prompt = `
        You are an expert fitness coach AI. Your task is to create a "Workout of the Day" using ONLY the exercises from the provided list.
        The response MUST be ONLY a valid, minified JSON object and nothing else. Do not add any text before or after the JSON.

        USER PROFILE:
        - Goals: ${user.profile.goals.join(", ")}
        - Gender: ${user.profile.gender || 'Not specified'}
        - Activity Level: ${user.profile.activityLevel}

        USER'S RECENT WORKOUT HISTORY:
        ${historySummary}

        LIST OF AVAILABLE EXERCISES:
        ${availableExerciseNames}

        Based on all this information, generate a single, detailed workout plan for today. Select 4-6 exercises STRICTLY from the list.
        The JSON object must have a root key "planDetails" containing an object with keys: "dayName" (string), "focus" (string), and an array of "exercises".
        Each object in the "exercises" array MUST have "name" (string, from the list), "sets" (number), and "reps" (number or time string like "45s").
       `;

    // 6. Connect to the Google Gemini API
    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
    const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_API_KEY}`;

    const aiResponse = await fetchWithRetry(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
    }, retries = 10);

    if (!aiResponse.ok) {
      const errorBody = await aiResponse.text();
      throw new Error(`Gemini API request failed with status ${aiResponse.status}: ${errorBody}`);
    }

    const aiData = await aiResponse.json();

    // 7. Extract and parse the AI's response for Gemini
    if (!aiData.candidates || !aiData.candidates[0].content || !aiData.candidates[0].content.parts[0].text) {
      throw new Error("Invalid response structure from Gemini API.");
    }
    const rawJsonText = aiData.candidates[0].content.parts[0].text;
    const planJson = JSON.parse(rawJsonText.replace(/```json/g, "").replace(/```/g, "").trim());

    // 8. Enrich the plan with details and a PROXY URL for the GIF
    const enrichedExercises = planJson.planDetails.exercises.map(aiExercise => {
      const normalizedAiName = normalizeString(aiExercise.name);
      const fullExerciseData = allExercises.find(dbEx => normalizeString(dbEx.name) === normalizedAiName);

      let gifUrl = null;
      // If we found a match and that match has an ID, construct a relative URL to our own backend proxy.
      if (fullExerciseData && fullExerciseData.id) {
        // This URL points to our own server, not directly to RapidAPI.
        gifUrl = fullExerciseData.id;
      }

      return {
        ...aiExercise,
        gifUrl: gifUrl, // Use the newly constructed proxy URL
        targetMuscle: fullExerciseData ? fullExerciseData.target : null,
        equipment: fullExerciseData ? fullExerciseData.equipment : null,
      };
    });

    planJson.planDetails.exercises = enrichedExercises;

    // 9. Save the new daily plan
    const newAiPlan = new AIPlan({
      user: user._id,
      planType: "workout",
      startDate: startOfDayIST,
      endDate: endOfDayIST,
      planDetails: planJson.planDetails,
      sourcePrompt: prompt,
    });

    await newAiPlan.save();

    // 10. Send the enriched plan to the Flutter app
    res.status(201).json({
      message: "New daily workout plan with videos generated successfully!",
      plan: newAiPlan,
    });
  } catch (error) {
    console.error("AI Plan Generation Error:", error);
    res.status(500).json({ message: "Failed to generate AI workout plan." });
  }
};

// Function to get exercise GIFs from ExerciseDB
exports.getExerciseGif = async (req, res) => {
  try {
    const { exerciseId } = req.query;
    if (!exerciseId) {
      return res.status(400).json({ message: "Exercise ID is required." });
    }

    const EXERCISEDB_API_KEY = process.env.EXERCISEDB_API_KEY;
    const imageUrl = `https://exercisedb.p.rapidapi.com/image?resolution=180&exerciseId=${exerciseId}`;

    const imageResponse = await fetch(imageUrl, {
      method: 'GET',
      headers: {
        'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        'X-RapidAPI-Key': EXERCISEDB_API_KEY,
      }
    });

    if (!imageResponse.ok) {
      throw new Error(`Failed to fetch image from ExerciseDB. Status: ${imageResponse.status}`);
    }

    // Set the correct content type for the response (e.g., image/gif)
    res.setHeader('Content-Type', imageResponse.headers.get('content-type'));
    imageResponse.body.pipe(res);

  } catch (error) {
    console.error("Image Proxy Error:", error);
    res.status(500).json({ message: "Failed to retrieve exercise image." });
  }
};

exports.generateAIMealPlan = async (req, res) => {
  try {
    const user = req.user;

    // 1. Define IST boundaries for the current day
    const now = new Date();
    const istDate = new Date(now.toLocaleString("en-US", { timeZone: "Asia/Kolkata" }));
    const startOfDayIST = new Date(istDate);
    startOfDayIST.setHours(0, 0, 0, 0);
    const endOfDayIST = new Date(istDate);
    endOfDayIST.setHours(23, 59, 59, 999);

    // 2. Check if a meal plan already exists for today
    const todaysMealPlan = await AIPlan.findOne({
      user: user._id,
      planType: "nutrition",
      startDate: { $gte: startOfDayIST, $lt: endOfDayIST },
    });

    if (todaysMealPlan) {
      return res.status(200).json({
        message: "A meal plan for today already exists.",
        plan: todaysMealPlan,
      });
    }

    // 3. Fetch user data for the prompt


    // 4. Construct the prompt for the meal plan
    const prompt = `
            You are an expert nutritionist AI. Your task is to create a balanced, healthy meal plan for a user for one day, strictly following their dietary preference.

            USER PROFILE:
            - Gender: ${user.profile.gender || 'Not specified'}
            - Dietary Preference: ${user.profile.mealType || 'vegetarian'}
            - Goals: ${user.profile.goals.join(", ")}
            - Activity Level: ${user.profile.activityLevel}
            - Current Weight: ${user.profile.weight.length > 0 ? user.profile.weight.slice(-1)[0].valueKg + ' kg' : 'Not specified'}
            - Height: ${user.profile.heightCm ? user.profile.heightCm + ' cm' : 'Not specified'}

            INSTRUCTIONS:
            Generate a single, detailed ${user.profile.mealType || 'vegetarian'} meal plan for today.
            The response MUST be ONLY a valid, minified JSON object.
            The JSON object must have a root key "planDetails" containing:
            1. An object "summary" with keys: "totalCalories" (number), "proteinGrams" (number), "carbGrams" (number), and "fatGrams" (number).
            2. An array "meals" with objects for "Breakfast", "Lunch", "Snack", and "Dinner".
            Each meal object MUST have "name" (string), "description" (string), and an array of "ingredients" (strings).
        `;

    // 5. Connect to the Google Gemini API
    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
    const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_API_KEY}`;

    const aiResponse = await fetchWithRetry(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
    }, retries = 10);

    if (!aiResponse.ok) {
      const errorBody = await aiResponse.text();
      throw new Error(`Gemini API request failed with status ${aiResponse.status}: ${errorBody}`);
    }

    const aiData = await aiResponse.json();

    // 6. Extract and parse the AI's response
    if (!aiData.candidates || !aiData.candidates[0].content || !aiData.candidates[0].content.parts[0].text) {
      throw new Error("Invalid response structure from Gemini API.");
    }
    const rawJsonText = aiData.candidates[0].content.parts[0].text;
    const planJson = JSON.parse(rawJsonText.replace(/```json/g, "").replace(/```/g, "").trim());

    // 7. NEW: Enrich the meal plan with photos from Pexels
    const PEXELS_API_KEY = process.env.PEXELS_API_KEY;
    const enrichedMeals = await Promise.all(planJson.planDetails.meals.map(async (meal) => {
      const pexelsUrl = `https://api.pexels.com/v1/search?query=${encodeURIComponent(meal.name)}&per_page=1`;
      let imageUrl = null;
      try {
        const pexelsResponse = await fetch(pexelsUrl, {
          headers: { 'Authorization': PEXELS_API_KEY }
        });
        if (pexelsResponse.ok) {
          const pexelsData = await pexelsResponse.json();
          if (pexelsData.photos && pexelsData.photos.length > 0) {
            imageUrl = pexelsData.photos[0].src.medium; // Get a medium-sized photo URL
          }
        }
      } catch (e) {
        console.error("Pexels API call failed:", e);
      }
      return { ...meal, imageUrl };
    }));

    planJson.planDetails.meals = enrichedMeals;

    // 8. Save the new daily meal plan
    const newMealPlan = new AIPlan({
      user: user._id,
      planType: "nutrition",
      startDate: startOfDayIST,
      endDate: endOfDayIST,
      planDetails: planJson.planDetails,
      sourcePrompt: prompt,
    });

    await newMealPlan.save();

    // 9. Send the new meal plan to the Flutter app
    res.status(201).json({
      message: "New daily meal plan generated successfully!",
      plan: newMealPlan,
    });

  } catch (error) {
    console.error("Meal Plan Generation Error:", error);
    res.status(500).json({ message: "Failed to generate AI meal plan." });
  }
};