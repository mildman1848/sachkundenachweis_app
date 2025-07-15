# scripts/update_questions.py – Skript zum Download, OCR und Update von questions.json.

import requests
import hashlib
import os
import json
from io import BytesIO
import fitz  # pymupdf für PDF-Text-Extraktion
from PIL import Image
import pytesseract  # Für OCR, falls textbasiert nicht möglich

# PDF-URLs (aktualisiere bei Bedarf)
QUESTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-neu-ab-01.01.2025.pdf"
SOLUTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-Loesungen-neu-ab-01.01.2025.pdf"

# Lokale Pfade
QUESTIONS_PDF = "temp_questions.pdf"
SOLUTIONS_PDF = "temp_solutions.pdf"
JSON_PATH = "assets/questions.json"

def download_pdf(url, path):
    """PDF herunterladen."""
    response = requests.get(url)
    if response.status_code == 200:
        with open(path, 'wb') as f:
            f.write(response.content)
        return True
    return False

def get_pdf_hash(path):
    """Hash der PDF berechnen."""
    if os.path.exists(path):
        hasher = hashlib.sha256()
        with open(path, 'rb') as f:
            hasher.update(f.read())
        return hasher.hexdigest()
    return None

def check_pdf_changed(url, local_path):
    """Prüfen, ob PDF geändert (Head-Request für Last-Modified, fallback Hash)."""
    head = requests.head(url)
    last_modified = head.headers.get('Last-Modified')
    etag = head.headers.get('ETag')

    if os.path.exists(local_path):
        old_hash = get_pdf_hash(local_path)
        # Download new and compare hash if etag or last_modified changed
        temp_path = "temp.pdf"
        if download_pdf(url, temp_path):
            new_hash = get_pdf_hash(temp_path)
            os.remove(temp_path)
            return old_hash != new_hash
    return True  # Download if no local or changed

def extract_text_from_pdf(path):
    """Text aus PDF extrahieren (Text-based oder OCR)."""
    doc = fitz.open(path)
    text = ""
    for page in doc:
        page_text = page.get_text()
        if page_text.strip():  # Text-based
            text += page_text + "\n"
        else:  # Image-based, OCR
            pix = page.get_pixmap()
            img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
            text += pytesseract.image_to_string(img, lang='deu') + "\n"
    doc.close()
    return text

def parse_to_json(questions_text, solutions_text):
    """Text parsen zu JSON-Struktur (Beispiel-Logik, passe an PDF-Format an)."""
    # Hier Logik implementieren: Fragen, Antworten, Korrekte parsen.
    # Annahme: Fragen-Text hat Format "ID. Frage\nA. ...\nB. ...\n" usw.
    # Lösungen haben "ID. Korrekte: A,B,C"
    # Implementiere Parser basierend auf PDF-Struktur (Regex oder line-by-line).
    questions = []
    # Beispiel-Stub (ersetze mit realem Parser)
    lines = questions_text.split('\n')
    for line in lines:
        if line.strip().isdigit():  # ID
            q_id = int(line.strip())
            # Nächste Zeile Frage, dann Answers
            # ...
            questions.append({
                "id": q_id,
                "question": "Beispiel Frage",
                "answers": ["A", "B", "C", "D"],
                "correctAnswers": [0, 1],
                "image": null
            })
    return questions

def update_json():
    """Hauptfunktion: Prüfen, Download, Extraktion, Update."""
    changed = False
    if check_pdf_changed(QUESTIONS_URL, QUESTIONS_PDF):
        if download_pdf(QUESTIONS_URL, QUESTIONS_PDF):
            changed = True
    if check_pdf_changed(SOLUTIONS_URL, SOLUTIONS_PDF):
        if download_pdf(SOLUTIONS_URL, SOLUTIONS_PDF):
            changed = True

    if changed:
        questions_text = extract_text_from_pdf(QUESTIONS_PDF)
        solutions_text = extract_text_from_pdf(SOLUTIONS_PDF)
        data = parse_to_json(questions_text, solutions_text)
        with open(JSON_PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print("questions.json updated.")
    else:
        print("No changes in PDFs.")

if __name__ == "__main__":
    update_json()