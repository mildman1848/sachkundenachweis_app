# scripts/update_questions.py – Skript zum Download, OCR und Update von questions.json.

import requests
import hashlib
import os
import json
import re
from io import BytesIO
import fitz  # pymupdf für PDF-Text-Extraktion und Image-Extraction
from PIL import Image
import pytesseract  # Für OCR, falls textbasiert nicht möglich

# PDF-URLs (aktualisiere bei Bedarf)
QUESTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-neu-ab-01.01.2025.pdf"
SOLUTIONS_URL = "https://www.tieraerztekammer-nordrhein.de/wp-content/uploads/2024/11/Sachkundefragen-Loesungen-neu-ab-01.01.2025.pdf"

# Lokale Pfade
QUESTIONS_PDF = "temp_questions.pdf"
SOLUTIONS_PDF = "temp_solutions.pdf"
JSON_PATH = "assets/questions.json"
IMAGES_DIR = "assets/images"  # Verzeichnis für extrahierte Bilder

# Stelle sicher, dass Verzeichnisse existieren
os.makedirs(IMAGES_DIR, exist_ok=True)

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
        # Wenn ETag oder Last-Modified verfügbar, vergleichen (einfach, da local keine Metadaten speichert)
        # Für Einfachheit: Immer Hash vergleichen, wenn Download klein ist
        temp_path = "temp.pdf"
        if download_pdf(url, temp_path):
            new_hash = get_pdf_hash(temp_path)
            old_hash = get_pdf_hash(local_path)
            changed = old_hash != new_hash
            if changed:
                os.replace(temp_path, local_path)  # Ersetze local mit new
            else:
                os.remove(temp_path)
            return changed
    else:
        return True  # Download if no local
    return False

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

def extract_images_from_pdf(path):
    """Bilder aus PDF extrahieren und speichern."""
    doc = fitz.open(path)
    images = {}
    for page_num, page in enumerate(doc):
        image_list = page.get_images(full=True)
        for img_index, img in enumerate(image_list):
            xref = img[0]
            base_image = doc.extract_image(xref)
            image_bytes = base_image["image"]
            image_ext = base_image["ext"]
            image_path = os.path.join(IMAGES_DIR, f"question_page{page_num}_img{img_index}.{image_ext}")
            with open(image_path, "wb") as image_file:
                image_file.write(image_bytes)
            images[(page_num, img_index)] = image_path
    doc.close()
    return images

def parse_to_json(questions_text, solutions_text):
    """Text parsen zu JSON-Struktur."""
    questions = []
    current_question = None
    answers = []
    id = None
    question_str = ""
    in_answers = False

    # Parse Questions
    lines = questions_text.split('\n')
    for line in lines:
        line = line.strip()
        if line and line.startswith('| ') and 'Welchen Ausdruck' in line:  # Frage-Start (anpassen an reales Format)
            if current_question:
                current_question['answers'] = answers
                questions.append(current_question)
            parts = line.split('|')
            if len(parts) > 1:
                id_str = parts[1].strip()
                if id_str.isdigit():
                    id = int(id_str)
                    question_str = ' '.join(parts[2:]).strip() if len(parts) > 2 else ""
                    current_question = {"id": id, "question": question_str, "answers": [], "correctAnswers": [], "image": None}
                    answers = []
                    in_answers = True
        elif in_answers and line.startswith('| '):
            parts = line.split('|')
            if len(parts) > 1 and parts[1].strip() in ['A.', 'B.', 'C.', 'D.']:
                answer = ' '.join(parts[2:]).strip() if len(parts) > 2 else ""
                answers.append(answer.replace('.', ''))
    if current_question:
        current_question['answers'] = answers
        questions.append(current_question)

    # Parse Solutions
    solutions = {}
    lines = solutions_text.split('\n')
    in_table = False
    for line in lines:
        line = line.strip()
        if line.startswith('| Frage Nr. | Lösung |'):
            in_table = True
            continue
        if in_table and line.startswith('| ') and ' | ' in line:
            parts = line.split(' | ')
            if len(parts) >= 3:
                q_id_str = parts[1].strip()
                sol = parts[2].strip()
                if q_id_str.isdigit():
                    q_id = int(q_id_str)
                    correct_letters = re.split(r',\s*', sol)
                    solutions[q_id] = [ord(letter) - ord('A') for letter in correct_letters if letter in 'ABCD']

    # Match Solutions to Questions und Images hinzufügen (bei "zeigt dieser Hund")
    for q in questions:
        if q['id'] in solutions:
            q['correctAnswers'] = solutions[q['id']]
        if 'zeigt dieser Hund' in q['question']:
            q['image'] = f"assets/images/question_{q['id']}.png"  # Annahme: Extrahierte Images benennen

    return questions

def update_json():
    """Hauptfunktion: Prüfen, Download, Extraktion, Update."""
    changed = False
    if check_pdf_changed(QUESTIONS_URL, QUESTIONS_PDF):
        changed = True
    if check_pdf_changed(SOLUTIONS_URL, SOLUTIONS_PDF):
        changed = True

    if changed:
        questions_text = extract_text_from_pdf(QUESTIONS_PDF)
        solutions_text = extract_text_from_pdf(SOLUTIONS_PDF)
        # Images extrahieren (optional, falls benötigt)
        extract_images_from_pdf(QUESTIONS_PDF)  # Extrahiert alle Bilder
        data = parse_to_json(questions_text, solutions_text)
        with open(JSON_PATH, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print("questions.json updated.")
    else:
        print("No changes in PDFs.")

if __name__ == "__main__":
    update_json()