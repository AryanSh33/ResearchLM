// Custom Theme Switch Script
const toggleSwitch = document.querySelector('.theme-switch-wrapper input[type="checkbox"]');
const lightThemeText = document.getElementById("light-theme-text");
const darkThemeText = document.getElementById("dark-theme-text");
const htmlEl = document.documentElement;

// Initialize theme - start with dark mode
let isDarkMode = true;

function updateTheme() {
    if (isDarkMode) {
        htmlEl.classList.add('dark');
        htmlEl.setAttribute("data-theme", "dark");
        toggleSwitch.checked = true;
        lightThemeText.classList.add("disabled");
        darkThemeText.classList.remove("disabled");
    } else {
        htmlEl.classList.remove('dark');
        htmlEl.setAttribute("data-theme", "light");
        toggleSwitch.checked = false;
        lightThemeText.classList.remove("disabled");
        darkThemeText.classList.add("disabled");
    }
}

// Initialize theme
updateTheme();

// Toggle theme on switch change
toggleSwitch.addEventListener("change", (e) => {
    isDarkMode = !isDarkMode;
    updateTheme();
});

// Add smooth transition effects
document.addEventListener('DOMContentLoaded', () => {
    document.body.style.transition = 'background-color 0.3s ease, color 0.3s ease';
});

// Chat functionality
const welcomeArea = document.getElementById('welcomeArea');
const chatArea = document.getElementById('chatArea');
const messagesContainer = document.getElementById('messagesContainer');
const chatTextarea = document.getElementById('chatTextarea');
const chatSubmitBtn = document.getElementById('chatSubmitBtn');
const newChatBtn = document.getElementById('newChatBtn');
const newChatShortcut = document.getElementById('newChatShortcut');
const typingIndicator = document.getElementById('typingIndicator');
const recentChats = document.getElementById('recentChats');

// Search functionality elements
const searchModal = document.getElementById('searchModal');
const searchChatInput = document.getElementById('searchChatInput');
const searchResults = document.getElementById('searchResults');
const closeSearchModal = document.getElementById('closeSearchModal');

// Library functionality elements
const libraryBtn = document.getElementById('libraryBtn');
const libraryModal = document.getElementById('libraryModal');
const libraryContent = document.getElementById('libraryContent');
const closeLibraryModal = document.getElementById('closeLibraryModal');

// Chat state
let currentChatId = null;
let chatHistory = [];
let chats = {}; // Store all chats with their messages
let typewriterInterval = null;

// Auto-resize textarea function
function adjustTextareaHeight(textarea) {
    textarea.style.height = 'auto';
    const newHeight = Math.max(48, Math.min(textarea.scrollHeight, 120));
    textarea.style.height = newHeight + 'px';
    
    if (newHeight <= 48) {
        textarea.style.lineHeight = '24px';
        textarea.style.paddingTop = '12px';
        textarea.style.paddingBottom = '12px';
    } else {
        textarea.style.lineHeight = '1.5';
        textarea.style.paddingTop = '12px';
        textarea.style.paddingBottom = '12px';
    }
}

// Setup textarea auto-resize
chatTextarea.addEventListener('input', () => adjustTextareaHeight(chatTextarea));
adjustTextareaHeight(chatTextarea);

// Generate chat ID
function generateChatId() {
    return 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// Add message to chat with typewriter effect
function addMessage(content, isUser = true) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user-message' : 'ai-message'}`;
    
    if (isUser) {
        messageDiv.textContent = content;
    } else {
        messageDiv.textContent = '';
        let i = 0;
        const speed = 20;
        const totalTime = 3000;
        const contentLength = content.length;
        const adjustedSpeed = Math.max(10, Math.min(50, Math.floor(totalTime / contentLength)));
        
        clearInterval(typewriterInterval);
        typewriterInterval = setInterval(() => {
            if (i < content.length) {
                messageDiv.textContent += content.charAt(i);
                i++;
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            } else {
                clearInterval(typewriterInterval);
            }
        }, adjustedSpeed);
    }
    
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    return messageDiv;
}

// Show typing indicator
function showTyping() {
    typingIndicator.style.display = 'flex';
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Hide typing indicator
function hideTyping() {
    typingIndicator.style.display = 'none';
}

// Connect to Literature Survey API and get response
// Connect to Literature Survey API and get response
// Connect to Literature Survey API and get response
async function getAIResponse(userMessage) {
    try {
        showTyping();
        console.log("🔄 Sending request to Literature Survey API with query:", userMessage);
        
        const baseUrl = 'https://7782-35-227-66-108.ngrok-free.app';
        const endpoint = '/literature-survey';
        const apiUrl = baseUrl + endpoint;
        
        console.log("🌐 Full API URL:", apiUrl);
        
        // First, let's try to test if the server is reachable
        let response;
        
        // Method 1: Try GET request with query parameter
        try {
            const getUrl = `${apiUrl}

// Debug function - call this from browser console to test connection
async function testAPIConnection() {
    const baseUrl = 'https://7782-35-227-66-108.ngrok-free.app';
    const endpoint = '/literature-survey';
    
    console.log("🧪 Testing API Connection...");
    
    // Test 1: Basic connectivity
    try {
        console.log("1️⃣ Testing basic connectivity to ngrok...");
        const response = await fetch(baseUrl, {
            method: 'GET',
            headers: { 'ngrok-skip-browser-warning': 'true' }
        });
        console.log("✅ Base URL accessible - Status:", response.status);
    } catch (e) {
        console.log("❌ Base URL test failed:", e.message);
        return;
    }
    
    // Test 2: Options request to check CORS
    try {
        console.log("2️⃣ Testing CORS preflight...");
        const response = await fetch(baseUrl + endpoint, {
            method: 'OPTIONS',
            headers: { 'ngrok-skip-browser-warning': 'true' }
        });
        console.log("✅ OPTIONS request - Status:", response.status);
        console.log("CORS headers:", Object.fromEntries(response.headers.entries()));
    } catch (e) {
        console.log("⚠️ OPTIONS test failed:", e.message);
    }
    
    // Test 3: Actual API call
    try {
        console.log("3️⃣ Testing actual API call...");
        const testQuery = "machine learning";
        const response = await fetch(`${baseUrl}${endpoint}?query=${encodeURIComponent(testQuery)}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'ngrok-skip-browser-warning': 'true'
            }
        });
        console.log("✅ API call - Status:", response.status);
        
        if (response.ok) {
            const data = await response.json();
            console.log("📊 API Response sample:", data);
        } else {
            const errorText = await response.text();
            console.log("❌ API Error:", errorText);
        }
    } catch (e) {
        console.log("❌ API call failed:", e.message);
    }
}?query=${encodeURIComponent(userMessage)}`;
            console.log("📡 Attempting GET request to:", getUrl);
            
            response = await fetch(getUrl, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'ngrok-skip-browser-warning': 'true',
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                },
                mode: 'cors'
            });
            
            console.log("✅ GET response received - Status:", response.status);
            console.log("📋 Response headers:", Object.fromEntries(response.headers.entries()));
            
        } catch (getError) {
            console.log("❌ GET request failed, trying POST method");
            console.log("Error details:", getError);
            
            // Method 2: Try POST request as fallback
            try {
                console.log("📡 Attempting POST request to:", apiUrl);
                
                response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'ngrok-skip-browser-warning': 'true',
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                    },
                    mode: 'cors',
                    body: JSON.stringify({
                        query: userMessage
                    })
                });
                
                console.log("✅ POST response received - Status:", response.status);
                
            } catch (postError) {
                console.log("❌ POST request also failed");
                console.log("POST Error details:", postError);
                
                // Method 3: Try basic connectivity test
                try {
                    console.log("🔍 Testing basic connectivity to ngrok domain...");
                    const testResponse = await fetch(baseUrl, {
                        method: 'GET',
                        headers: {
                            'ngrok-skip-browser-warning': 'true'
                        },
                        mode: 'cors'
                    });
                    console.log("🌐 Base URL test - Status:", testResponse.status);
                } catch (testError) {
                    console.log("❌ Base URL test failed:", testError);
                }
                
                throw new Error(`Both GET and POST failed. GET: ${getError.message}, POST: ${postError.message}`);
            }
        }

        // Check if response is successful
        if (!response.ok) {
            let errorText;
            try {
                errorText = await response.text();
                console.error("❌ API Error Response Body:", errorText);
            } catch (e) {
                errorText = `HTTP ${response.status} ${response.statusText}`;
                console.error("❌ Could not read error response body");
            }
            
            console.error("📊 Response Details:");
            console.error("- Status:", response.status);
            console.error("- Status Text:", response.statusText);
            console.error("- Headers:", Object.fromEntries(response.headers.entries()));
            
            throw new Error(`API request failed with status ${response.status}: ${errorText}`);
        }

        // Parse response
        let data;
        try {
            const responseText = await response.text();
            console.log("Raw API Response:", responseText);
            
            if (!responseText.trim()) {
                throw new Error("Empty response from server");
            }
            
            data = JSON.parse(responseText);
            console.log("Parsed API Response:", data);
        } catch (parseError) {
            console.error("Failed to parse JSON response:", parseError);
            throw new Error("Invalid JSON response from server");
        }

        hideTyping();
        
        // Handle error in response data
        if (data.error) {
            return `🚨 Error: ${data.error}`;
        }

        // Check if we have valid results
        if (!data.results || typeof data.results !== 'object') {
            return `⚠️ No valid results found in the response for query: "${userMessage}"`;
        }

        // Format the response for display
        let formattedResponse = `📚 Literature Survey Results\n\n`;
        formattedResponse += `🔍 Query: "${data.query || userMessage}"\n`;
        formattedResponse += `🎯 Key Phrase: ${data.extracted_phrase || 'N/A'}\n\n`;

        const resultsCount = Object.keys(data.results).length;
        if (resultsCount > 0) {
            formattedResponse += `📄 Found ${resultsCount} Relevant Papers:\n\n`;
            
            Object.entries(data.results).forEach(([paperId, paper], index) => {
                formattedResponse += `${index + 1}. **${paper.title || 'Untitled Paper'}**\n`;
                
                if (paper.year) {
                    formattedResponse += `   📅 Year: ${paper.year}`;
                }
                if (paper.citations !== undefined && paper.citations !== null) {
                    formattedResponse += `   📊 Citations: ${paper.citations}`;
                }
                formattedResponse += `\n`;
                
                if (paper.url && paper.url.trim()) {
                    formattedResponse += `   🔗 Link: ${paper.url}\n`;
                }
                
                if (paper.analysis && paper.analysis.trim()) {
                    // Clean up the analysis text and add proper formatting
                    const cleanAnalysis = paper.analysis
                        .replace(/\*\*(.*?)\*\*/g, '$1') // Remove markdown bold
                        .replace(/\n+/g, '\n') // Normalize line breaks
                        .trim();
                    
                    formattedResponse += `\n   📋 Analysis:\n`;
                    formattedResponse += `   ${cleanAnalysis.replace(/\n/g, '\n   ')}\n\n`;
                } else if (paper.error) {
                    formattedResponse += `   ⚠️ Analysis Error: ${paper.error}\n\n`;
                } else {
                    formattedResponse += `   ℹ️ No analysis available\n\n`;
                }
            });
        } else {
            formattedResponse += "❌ No relevant papers found for this query.\n";
            formattedResponse += "💡 Try refining your search terms or using different keywords.\n";
        }
        
        return formattedResponse;
        
    } catch (error) {
        console.error('🚨 API Error:', error);
        console.error('Error type:', error.constructor.name);
        console.error('Error message:', error.message);
        console.error('Stack trace:', error.stack);
        
        hideTyping();
        
        // Enhanced error diagnosis
        if (error.message.includes('Failed to fetch') || error.name === 'TypeError') {
            // Check if it's a network issue vs CORS vs server down
            console.log("🔍 Diagnosing network error...");
            
            // Test if we can reach ngrok at all
            try {
                await fetch('https://ngrok.com', { method: 'HEAD', mode: 'no-cors' });
                console.log("✅ External network connectivity confirmed");
            } catch (e) {
                console.log("❌ Network connectivity issue detected");
                return "🌐 Network Issue: Unable to reach external services. Please check your internet connection.";
            }
            
            return "🚨 Connection Error: Cannot connect to the literature survey service.\n\n" +
                   "Possible causes:\n" +
                   "• The ngrok tunnel may have expired or changed\n" +
                   "• The backend server is not running\n" +
                   "• Firewall blocking the request\n" +
                   "• Browser security restrictions\n\n" +
                   "Solutions to try:\n" +
                   "1. Verify the ngrok URL is still active\n" +
                   "2. Check if the backend server is running\n" +
                   "3. Open browser developer tools for more details\n" +
                   "4. Try accessing the API URL directly in a new tab";
        } 
        else if (error.message.includes('status 404')) {
            return "🔍 Endpoint Not Found: The '/literature-survey' endpoint was not found.\n\n" +
                   "This means either:\n" +
                   "• The backend server is running but the endpoint is incorrect\n" +
                   "• The FastAPI application hasn't loaded the route properly\n\n" +
                   "Try accessing: " + baseUrl + " directly to see if the server responds.";
        }
        else if (error.message.includes('status 405')) {
            return "❌ Method Not Allowed: The server rejected the request method.\n\n" +
                   "This suggests:\n" +
                   "• The endpoint exists but doesn't accept GET/POST requests\n" +
                   "• There might be a routing configuration issue\n\n" +
                   "Backend Debug: Check if the @app.api_route decorator is correct.";
        }
        else if (error.message.includes('status 422')) {
            return "📝 Validation Error: The server couldn't process the request parameters.\n\n" +
                   "This usually means:\n" +
                   "• The 'query' parameter is missing or malformed\n" +
                   "• FastAPI pydantic validation failed\n\n" +
                   "Query sent: '" + userMessage + "'";
        }
        else if (error.message.includes('status 500')) {
            return "⚠️ Server Error: The backend encountered an internal error.\n\n" +
                   "Common causes:\n" +
                   "• Missing dependencies (spaCy, transformers, etc.)\n" +
                   "• API key issues (Semantic Scholar or Gemini)\n" +
                   "• Model loading failures\n\n" +
                   "Check the backend server logs for detailed error information.";
        }
        else if (error.message.includes('status 503')) {
            return "🔧 Service Unavailable: The server is temporarily unavailable.\n" +
                   "This might indicate the backend is overloaded or starting up.";
        }
        else {
            return "❌ Unexpected Error: " + (error.message || "Unknown error occurred") + "\n\n" +
                   "Debug Information:\n" +
                   "• Time: " + new Date().toISOString() + "\n" +
                   "• Query: '" + userMessage + "'\n" +
                   "• Error Type: " + error.constructor.name + "\n\n" +
                   "Please check the browser console for more details.";
        }
    }
}

// Handle API errors (keep this as backup, but main error handling is now in getAIResponse)
function handleAPIError(error) {
    console.error('API Error:', error);
    let errorMessage = "An error occurred while processing your request.";
    
    if (error.message.includes('Failed to fetch')) {
        errorMessage = "Unable to connect to the literature survey service. Please check your internet connection.";
    } else if (error.message.includes('status 500')) {
        errorMessage = "The literature survey service is currently unavailable. Please try again later.";
    } else if (error.message.includes('status 404')) {
        errorMessage = "The literature survey endpoint was not found.";
    } else if (error.message.includes('status 429')) {
        errorMessage = "Too many requests. Please wait a moment and try again.";
    } else if (error.message.includes('status 405')) {
        errorMessage = "Method not allowed. The API request configuration needs adjustment.";
    }
    
    return errorMessage;
}

// Update chat input placeholder based on context
function updateChatInputPlaceholder() {
    if (currentChatId && chats[currentChatId] && chats[currentChatId].messages.length > 0) {
        chatTextarea.placeholder = "Continue the conversation...";
    } else {
        chatTextarea.placeholder = "Ask your research query...";
    }
}

// Handle message submission
async function handleSubmit(message) {
    if (!message.trim()) return;

    if (!chatArea.classList.contains('active')) {
        welcomeArea.classList.add('hidden');
        chatArea.classList.add('active');
        
        if (!currentChatId) {
            currentChatId = generateChatId();
            chats[currentChatId] = {
                title: message.substring(0, 30) + (message.length > 30 ? '...' : ''),
                messages: []
            };
            addChatToSidebar(chats[currentChatId].title, currentChatId);
        }
    }

    addMessage(message, true);
    chatHistory.push({ role: 'user', content: message });
    chats[currentChatId].messages.push({ role: 'user', content: message });

    chatTextarea.value = '';
    adjustTextareaHeight(chatTextarea);
    updateChatInputPlaceholder();

    try {
        const aiResponse = await getAIResponse(message);
        addMessage(aiResponse, false);
        chatHistory.push({ role: 'assistant', content: aiResponse });
        chats[currentChatId].messages.push({ role: 'assistant', content: aiResponse });
        
        if (chats[currentChatId].messages.length === 2) {
            const extractedPhrase = aiResponse.match(/Literature Survey Results for: "([^"]+)"/);
            if (extractedPhrase && extractedPhrase[1]) {
                chats[currentChatId].title = "Research: " + extractedPhrase[1].substring(0, 25) + 
                    (extractedPhrase[1].length > 25 ? '...' : '');
            } else {
                chats[currentChatId].title = "Research: " + message.substring(0, 25) + 
                    (message.length > 25 ? '...' : '');
            }
            updateRecentChatsList();
        }
    } catch (error) {
        const errorMessage = handleAPIError(error);
        addMessage(errorMessage, false);
    }
}

// Add chat to sidebar
function addChatToSidebar(title, chatId) {
    const chatItemWrapper = document.createElement('div');
    chatItemWrapper.className = 'chat-item-wrapper';
    
    const chatItem = document.createElement('div');
    chatItem.className = 'chat-item';
    
    const chatContent = document.createElement('div');
    chatContent.className = 'chat-item-content text-sm text-gray-600 dark:text-gray-300 truncate';
    chatContent.textContent = title;
    
    const deleteBtn = document.createElement('button');
    deleteBtn.className = 'delete-chat-btn';
    deleteBtn.innerHTML = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>';
    
    deleteBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        deleteChat(chatId, chatItemWrapper);
    });
    
    chatItem.appendChild(chatContent);
    chatItem.appendChild(deleteBtn);
    chatItemWrapper.appendChild(chatItem);
    
    chatItemWrapper.addEventListener('click', () => {
        loadChat(chatId);
    });
    
    recentChats.insertBefore(chatItemWrapper, recentChats.firstChild);
}

// Update recent chats list
function updateRecentChatsList() {
    recentChats.innerHTML = '';
    Object.entries(chats).forEach(([chatId, chat]) => {
        addChatToSidebar(chat.title, chatId);
    });
}

// Delete chat from sidebar
function deleteChat(chatId, element) {
    delete chats[chatId];
    element.remove();
    
    if (currentChatId === chatId) {
        startNewChat();
    }
}

// Load chat from history
function loadChat(chatId) {
    if (!chats[chatId]) return;
    
    currentChatId = chatId;
    chatHistory = [...chats[chatId].messages];
    
    messagesContainer.innerHTML = '<div id="typingIndicator" class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>';
    
    const newTypingIndicator = document.getElementById('typingIndicator');
    
    welcomeArea.classList.add('hidden');
    chatArea.classList.add('active');
    updateChatInputPlaceholder();
    
    chatHistory.forEach((msg, index) => {
        setTimeout(() => {
            if (msg.role === 'user') {
                addMessage(msg.content, true);
            } else {
                const messageDiv = document.createElement('div');
                messageDiv.className = 'message ai-message';
                messageDiv.textContent = msg.content;
                messagesContainer.appendChild(messageDiv);
            }
        }, index * 300);
    });
    
    chatTextarea.focus();
}

// Start new chat
function startNewChat() {
    currentChatId = null;
    chatHistory = [];
    
    messagesContainer.innerHTML = '<div id="typingIndicator" class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>';
    
    const newTypingIndicator = document.getElementById('typingIndicator');
    
    chatArea.classList.remove('active');
    welcomeArea.classList.remove('hidden');
    updateChatInputPlaceholder();
    
    chatTextarea.value = '';
    adjustTextareaHeight(chatTextarea);
    chatTextarea.focus();
}

// Search chats function
function searchChats(keyword) {
    searchResults.innerHTML = '';
    
    if (!keyword.trim()) {
        searchResults.innerHTML = '<div class="no-results">Enter a search term to find chats</div>';
        return;
    }
    
    const lowerKeyword = keyword.toLowerCase();
    let hasResults = false;
    
    Object.entries(chats).forEach(([chatId, chat]) => {
        const matchedMessages = [];
        
        chat.messages.forEach((message, index) => {
            const lowerContent = message.content.toLowerCase();
            if (lowerContent.includes(lowerKeyword)) {
                const startPos = lowerContent.indexOf(lowerKeyword);
                const endPos = startPos + lowerKeyword.length;
                const start = Math.max(0, startPos - 20);
                const end = Math.min(message.content.length, endPos + 20);
                let snippet = message.content.substring(start, end);
                
                if (start > 0) snippet = '...' + snippet;
                if (end < message.content.length) snippet = snippet + '...';
                
                const highlightedSnippet = snippet.replace(
                    new RegExp(keyword, 'gi'),
                    match => `<span class="matched-keyword">${match}</span>`
                );
                
                matchedMessages.push({
                    role: message.role,
                    content: highlightedSnippet,
                    index: index
                });
            }
        });
        
        if (matchedMessages.length > 0) {
            hasResults = true;
            const resultItem = document.createElement('div');
            resultItem.className = 'search-result-item';
            resultItem.innerHTML = `
                <div class="chat-title">${chat.title}</div>
                <div class="matched-text">
                    ${matchedMessages.map(msg => 
                        `<strong>${msg.role === 'user' ? 'You' : 'AI'}:</strong> ${msg.content}`
                    ).join('<br>')}
                </div>
            `;
            
            resultItem.addEventListener('click', () => {
                loadChat(chatId);
                searchModal.classList.add('hidden');
                
                setTimeout(() => {
                    const messages = document.querySelectorAll('.message');
                    if (messages.length > matchedMessages[0].index) {
                        messages[matchedMessages[0].index].scrollIntoView({
                            behavior: 'smooth',
                            block: 'center'
                        });
                    }
                }, 300);
            });
            
            searchResults.appendChild(resultItem);
        }
    });
    
    if (!hasResults) {
        searchResults.innerHTML = '<div class="no-results">No chats found matching your search</div>';
    }
}

// Update library view
function updateLibraryView() {
    libraryContent.innerHTML = '';
    
    if (Object.keys(chats).length === 0) {
        libraryContent.innerHTML = `
            <div class="col-span-2 flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                <svg class="w-12 h-12 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"></path>
                </svg>
                <p>No chats found in your library</p>
                <p class="text-sm mt-2">Start a new chat to see it appear here</p>
            </div>
        `;
        return;
    }
    
    // Sort chats by most recent first
    const sortedChats = Object.entries(chats).sort((a, b) => {
        // Extract timestamp from chat ID (chat_<timestamp>_<random>)
        const aTime = parseInt(a[0].split('_')[1]);
        const bTime = parseInt(b[0].split('_')[1]);
        return bTime - aTime;
    });
    
    sortedChats.forEach(([chatId, chat]) => {
        const lastMessage = chat.messages[chat.messages.length - 1]?.content || "No messages yet";
        const previewText = lastMessage.length > 60 ? lastMessage.substring(0, 60) + '...' : lastMessage;
        
        // Extract date from chat ID
        const timestamp = parseInt(chatId.split('_')[1]);
        const chatDate = new Date(timestamp).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        });
        
        const libraryItem = document.createElement('div');
        libraryItem.className = 'library-item';
        libraryItem.innerHTML = `
            <div class="library-item-title">${chat.title}</div>
            <div class="library-item-preview">${previewText}</div>
            <div class="library-item-date">${chatDate}</div>
        `;
        
        libraryItem.addEventListener('click', () => {
            loadChat(chatId);
            libraryModal.classList.add('hidden');
        });
        
        libraryContent.appendChild(libraryItem);
    });
}

// Event listeners
newChatBtn.addEventListener('click', startNewChat);
newChatShortcut.addEventListener('click', startNewChat);
chatSubmitBtn.addEventListener('click', () => {
    const message = chatTextarea.value.trim();
    if (message) {
        handleSubmit(message);
    }
});

chatTextarea.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        const message = chatTextarea.value.trim();
        if (message) {
            handleSubmit(message);
        }
    }
});

document.querySelectorAll('button').forEach(button => {
    if (button.textContent.includes('Search chats')) {
        button.addEventListener('click', () => {
            searchModal.classList.remove('hidden');
            searchChatInput.focus();
        });
    }
});

closeSearchModal.addEventListener('click', () => {
    searchModal.classList.add('hidden');
});

searchModal.addEventListener('click', (e) => {
    if (e.target === searchModal) {
        searchModal.classList.add('hidden');
    }
});

searchChatInput.addEventListener('input', (e) => {
    searchChats(e.target.value);
});

libraryBtn.addEventListener('click', () => {
    updateLibraryView();
    libraryModal.classList.remove('hidden');
});

closeLibraryModal.addEventListener('click', () => {
    libraryModal.classList.add('hidden');
});

libraryModal.addEventListener('click', (e) => {
    if (e.target === libraryModal) {
        libraryModal.classList.add('hidden');
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !searchModal.classList.contains('hidden')) {
        searchModal.classList.add('hidden');
    }
    if (e.key === 'Escape' && !libraryModal.classList.contains('hidden')) {
        libraryModal.classList.add('hidden');
    }
});

// Typewriter effect for welcome message
const target = document.getElementById("typewriter");
const text = "What are you working on?";
let i = 0;

function typeWriter() {
    if (i < text.length) {
        target.innerHTML += text.charAt(i);
        i++;
        setTimeout(typeWriter, 60);
    }
}

// Update modals when theme changes
toggleSwitch.addEventListener("change", (e) => {
    updateTheme();
    // Refresh any open modals
    if (!searchModal.classList.contains('hidden')) {
        searchChats(searchChatInput.value);
    }
    if (!libraryModal.classList.contains('hidden')) {
        updateLibraryView();
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    chatTextarea.focus();
    updateChatInputPlaceholder();
    typeWriter();
});