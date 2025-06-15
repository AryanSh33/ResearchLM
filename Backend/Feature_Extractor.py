import spacy
import torch
from transformers import AutoTokenizer, AutoModel
from sklearn.metrics.pairwise import cosine_similarity
import gradio as gr
import requests

# ----------- CONFIG -----------
GRADIO_APP_B_URL = "https://your-app-b-url.gradio.live/run/predict"  # Change this to your App B endpoint
MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
# ------------------------------

class KeywordPhraseExtractor:
    def __init__(self, model_name=MODEL_NAME):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name).to(self.device)
        self.model.eval()
        self.spacy_nlp = spacy.load("en_core_web_sm")

    def embed(self, text):
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512).to(self.device)
        with torch.no_grad():
            outputs = self.model(**inputs)
        return outputs.last_hidden_state.mean(dim=1).cpu().numpy()

    def extract_phrases(self, text):
        doc = self.spacy_nlp(text)
        phrases = set()

        # Add noun chunks
        for chunk in doc.noun_chunks:
            phrases.add(chunk.text.strip().lower())

        # Also add cleaned version of original input
        clean = text.lower()
        for prefix in ["give me", "get me", "find me", "show me", "search for", "look for", "find articles about"]:
            if clean.startswith(prefix):
                clean = clean[len(prefix):].strip()
                break
        phrases.add(clean)

        return list(phrases)

    def best_phrase(self, query):
        base_embedding = self.embed(query)
        candidates = self.extract_phrases(query)

        if not candidates:
            return "No key phrase found."

        scored = []
        for phrase in candidates:
            emb = self.embed(phrase)
            score = cosine_similarity(base_embedding, emb)[0][0]
            scored.append((phrase, score))

        best = max(scored, key=lambda x: x[1])[0]
        return best.capitalize()

extractor = KeywordPhraseExtractor()

def extract_and_send_to_app_b(query):
    if not query.strip():
        return "Please enter a query."

    # Step 1: Extract best phrase
    extracted_query = extractor.best_phrase(query)

    # Step 2: Send extracted query to App B
    try:
        response = requests.post(
            GRADIO_APP_B_URL,
            json={"data": [extracted_query]},
            timeout=60
        )

        if response.status_code == 200:
            result = response.json().get("data", ["No result from App B"])[0]
        else:
            result = f"❌ App B returned error {response.status_code}:\n{response.text}"
    except Exception as e:
        result = f"❌ Failed to connect to App B:\n{e}"

    # Step 3: Return combined display
    return f"### ✅ Extracted Query:\n`{extracted_query}`\n\n---\n\n### 📚 Literature Survey Result:\n{result}"

# Launch Gradio App A interface
iface = gr.Interface(
    fn=extract_and_send_to_app_b,
    inputs=gr.Textbox(label="🔍 Enter your research query"),
    outputs=gr.Markdown(label="📄 Output"),
    title="🔗 Research Query Extractor + Semantic Scholar Pipeline",
    description="Extracts the best research topic phrase and passes it to another AI app for literature analysis."
)

iface.launch()
