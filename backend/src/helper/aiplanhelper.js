// Function to handle retries for API requests
exports.fetchWithRetry = async (url, options, retries = 3, backoff = 1000) => {
    for (let i = 0; i < retries; i++) {
        try {
            const response = await fetch(url, options);
            // If the model is overloaded (503), we wait and retry.
            if (response.status === 503) {
                console.log(`Attempt ${i + 1}: Model overloaded (503). Retrying in ${backoff / 1000}s...`);
                await new Promise(resolve => setTimeout(resolve, backoff));
                backoff *= 2; // Double the wait time for the next potential retry
                continue; // Go to the next iteration of the loop
            }
            return response; // If successful or a different error, return the response
        } catch (error) {
            if (i === retries - 1) throw error; // If it's the last retry, throw the error
            await new Promise(resolve => setTimeout(resolve, backoff));
            backoff *= 2;
        }
    }
    throw new Error('API request failed after all retries.');
};

// Function to normalize exercise names for robust matching
exports.normalizeString = (str) => {
    if (!str) return '';
    return str.toLowerCase().trim().replace(/\s+/g, ' ');
};