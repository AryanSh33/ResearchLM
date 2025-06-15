from fastapi import FastAPI, Query
from pydantic import BaseModel
from typing import Dict
import requests
import torch
import spacy
import time
from transformers import AutoTokenizer, AutoModel
from sklearn.metrics.pairwise import cosine_similarity

SEMANTIC_SCHOLAR_API_KEY = "Vs5X8oxztw9W8Uc5OUWEP8eKQgi3apKcaHxVy63a"
GEMINI_API_KEY = "AIzaSyDBCwgbIw4q1jqIbVfIA1Ax4Gl_O0vAbYY"

SEARCH_URL = "https://api.semanticscholar.org/graph/v1/paper/search"
HEADERS = {"x-api-key": SEMANTIC_SCHOLAR_API_KEY}
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"

app = FastAPI(title="📚 AI-Powered Literature Survey API")

def load_model_with_retries(model_name, retries=3, delay=5):
    for attempt in range(retries):
        try:
            tokenizer = AutoTokenizer.from_pretrained(model_name)
            model = AutoModel.from_pretrained(model_name)
            return tokenizer, model
        except Exception as e:
            print(f"⚠️ Attempt {attempt + 1} failed: {e}")
            time.sleep(delay)
    raise Exception("❌ Failed to load model after retries.")

class KeywordPhraseExtractor:
    def __init__(self, model_name="sentence-transformers/paraphrase-MiniLM-L6-v2"):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.tokenizer, model = load_model_with_retries(model_name)
        self.model = model.to(self.device).eval()
        self.spacy_nlp = spacy.load("en_core_web_sm")

    def embed(self, text):
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512).to(self.device)
        with torch.no_grad():
            outputs = self.model(**inputs)
        return outputs.last_hidden_state.mean(dim=1).cpu().numpy()

    def extract_phrases(self, text):
        doc = self.spacy_nlp(text)
        phrases = set()

        for chunk in doc.noun_chunks:
            phrases.add(chunk.text.strip().lower())

        clean = text.lower()
        for prefix in ["give me", "get me", "find me", "show me", "search for", "look for", "find articles about", "paper on"]:
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

def retrieve_top_papers(query, top_k_cited=3, top_k_recent=3, top_k_similar=2, top_k_foundational=2):
    collected = []
    offset = 0
    limit = 20
    max_pages = 10

    while len(collected) < 100 and max_pages > 0:
        params = {
            "query": query,
            "fields": "title,abstract,year,citationCount,authors,url",
            "limit": limit,
            "offset": offset
        }
        response = requests.get(SEARCH_URL, headers=HEADERS, params=params)
        if response.status_code != 200:
            print("Search Error:", response.status_code)
            break

        papers = response.json().get("data", [])
        for paper in papers:
            if paper.get("abstract"):
                collected.append(paper)

        offset += limit
        max_pages -= 1

    if not collected:
        return {}

    current_year = 2025

    # Top cited papers overall
    cited_sorted = sorted(collected, key=lambda x: x.get("citationCount", 0), reverse=True)[:top_k_cited]

    # Recent impactful papers
    recent_sorted = sorted(
        [p for p in collected if p.get("year", 0) >= current_year - 5 and p.get("citationCount", 0) >= 30],
        key=lambda x: (x.get("year", 0), x.get("citationCount", 0)),
        reverse=True
    )[:top_k_recent]

    # Foundational (old + highly cited)
    foundational_sorted = sorted(
        [p for p in collected if p.get("year", 0) < 2015 and p.get("citationCount", 0) >= 500],
        key=lambda x: x.get("citationCount", 0),
        reverse=True
    )[:top_k_foundational]

    # Semantic similarity
    extractor = KeywordPhraseExtractor()
    query_emb = extractor.embed(query)
    paper_scores = []
    for paper in collected:
        emb = extractor.embed(paper["abstract"])
        score = cosine_similarity(query_emb, emb)[0][0]
        paper_scores.append((paper, score))

    similar_sorted = sorted(paper_scores, key=lambda x: x[1], reverse=True)[:top_k_similar]
    similar_papers = [item[0] for item in similar_sorted]

    # Merge all sets and deduplicate
    all_papers = cited_sorted + recent_sorted + foundational_sorted + similar_papers
    seen_titles = set()
    unique_final = []
    for p in all_papers:
        if p["title"] not in seen_titles:
            seen_titles.add(p["title"])
            unique_final.append(p)

    result_dict = {}
    for idx, paper in enumerate(unique_final, 1):
        result_dict[f"Paper {idx}"] = {
            "title": paper["title"],
            "abstract": paper["abstract"],
            "year": paper["year"],
            "citations": paper["citationCount"],
            "url": paper.get("url", "")
        }

    return result_dict

def analyze_abstract_dict(papers_dict):
    analyzed = {}

    for paper_id, paper in papers_dict.items():
        abstract = paper["abstract"]
        prompt = (
            "You are a research assistant. Analyze the following abstract and provide:\n"
            "1. A brief summary\n"
            "2. Key challenges mentioned or implied\n"
            "3. Authors' perspective\n"
            "4. Scope for improvement or future work\n"
            "(Tip: If any section is missing, infer it from the abstract.)\n\n"
            f"Abstract:\n\"\"\"\n{abstract}\n\"\"\""
        )

        payload = {
            "contents": [
                {
                    "parts": [{"text": prompt}]
                }
            ]
        }

        response = requests.post(GEMINI_URL, json=payload)
        if response.status_code == 200:
            gemini_reply = response.json()
            generated_text = gemini_reply["candidates"][0]["content"]["parts"][0]["text"]
            analyzed[paper_id] = {
                "title": paper["title"],
                "year": paper["year"],
                "citations": paper["citations"],
                "url": paper["url"],
                "analysis": generated_text.strip()
            }
        else:
            analyzed[paper_id] = {
                "title": paper["title"],
                "error": f"Error: {response.status_code}"
            }

    return analyzed

@app.get("/literature-survey")
def get_literature_analysis(query: str = Query(..., description="Your research topic")):
    phrase_extractor = KeywordPhraseExtractor()
    extracted_phrase = phrase_extractor.best_phrase(query)
    papers = retrieve_top_papers(extracted_phrase)

    if not papers:
        return {"error": "No papers found for the given phrase."}

    analysis = analyze_abstract_dict(papers)
    return {
        "query": query,
        "extracted_phrase": extracted_phrase,
        "results": analysis
    }
