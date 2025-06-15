
# 📚 ResearchLM — AI-Powered Literature Survey Assistant

ResearchLM is an intelligent assistant that extracts key phrases from natural language queries, retrieves relevant academic papers using the Semantic Scholar API, and analyzes abstracts using Google's Gemini API. It offers an interactive chat-like frontend built with HTML, TailwindCSS, and JavaScript, and a FastAPI backend for processing.

---

## 🚀 Features

- 🔍 Smart phrase extraction using Transformer embeddings
- 📄 Literature retrieval from Semantic Scholar
- 🤖 Abstract analysis via Gemini API
- 🧠 Semantic similarity ranking
- ⚡ FastAPI backend
- 🌐 TailwindCSS-powered frontend UI
- 🌗 Theme toggle (Dark/Light)

---

## 🧱 Project Structure

```

ResearchLM/
├── app.py                     # FastAPI backend server (App B)
├── Feature\_Extractor.py       # Phrase extractor using Gradio (App A, optional)
├── script.js                  # Chat frontend logic
├── index.html                 # Frontend UI using TailwindCSS
├── research\_Paper\_Analysis.ipynb  # Jupyter notebook for testing
├── FastAPI (1).ipynb              # Jupyter notebook for API testing

````

---

## 🔑 API Keys Setup

Create API keys and set them in `app.py`:

```python
SEMANTIC_SCHOLAR_API_KEY = "your_semantic_scholar_api_key"
GEMINI_API_KEY = "your_google_gemini_api_key"
````

* [Semantic Scholar API](https://www.semanticscholar.org/product/api)
* [Google Gemini (via MakerSuite)](https://makersuite.google.com/)

---

## ⚙️ Backend Setup (FastAPI)

```bash
# 1. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install fastapi uvicorn spacy torch transformers scikit-learn requests

# 3. Download spaCy model
python -m spacy download en_core_web_sm

# 4. Run the server
uvicorn app:app --reload
```

Server will run at:
`http://127.0.0.1:8000`

Try the API:
`http://127.0.0.1:8000/literature-survey?query=machine+translation`

---

## 🌐 Frontend Setup (HTML + TailwindCSS)

Use `index.html` and `script.js` for a lightweight, fully responsive chat interface.

### To Run Locally:

```bash
# Option 1: Use Python static server
python -m http.server

# Option 2: Use Live Server extension (in VS Code)
```

Make sure the API base URL in `script.js` is correct:

```javascript
const baseUrl = 'http://localhost:8000'; // or your ngrok URL
```

---

## 🧪 Example Usage

1. Start the backend:

   ```
   uvicorn app:app --reload
   ```

2. Open `index.html` in browser

3. Enter a query like:

   ```
   recent advancements in multimodal emotion recognition
   ```

4. You'll receive:

   * ✅ Extracted key phrase
   * 📑 Top-cited, recent, foundational & semantically similar papers
   * 📋 AI-generated abstract analysis (via Gemini)

---

## 🌍 Deployment (Optional)

To expose your FastAPI server publicly:

```bash
# Install ngrok
ngrok http 8000
```

Then update the base URL in `script.js` to the ngrok URL:

```javascript
const baseUrl = 'https://your-ngrok-url.ngrok-free.app';
```

---

## 🧠 Technologies Used

| Purpose           | Technology                               |
| ----------------- | ---------------------------------------- |
| Backend API       | FastAPI                                  |
| Language Modeling | `sentence-transformers/all-MiniLM-L6-v2` |
| Semantic Matching | `paraphrase-MiniLM-L6-v2`                |
| NLP               | spaCy `en_core_web_sm`                   |
| Paper Retrieval   | Semantic Scholar API                     |
| Text Analysis     | Google Gemini API                        |
| Frontend          | HTML + TailwindCSS + Vanilla JavaScript  |

---

## 📌 Sample Prompt for Gemini

```
You are a research assistant. Analyze the following abstract and provide:
1. A brief summary
2. Key challenges
3. Authors’ perspective
4. Scope for improvement or future work
```

---

## 📷 UI Highlights

> <img src="Screenshot 2025-06-15 160105.png" alt="Description of image" width="600"/>
> <img src="Screenshot 2025-06-15 161211.png" alt="Description of image" width="600"/>
> <img src="Screenshot 2025-06-15 162044.png" alt="Description of image" width="600"/>
> <img src="ss1.png" alt="Description of image" width="600"/>
> <img src="ss2.png" alt="Description of image" width="600"/>

---

## 📄 License

MIT License.
Free to use, modify, and share for academic or personal research.

---



