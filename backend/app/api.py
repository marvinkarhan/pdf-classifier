import functools
import pypdf
import tabula
from flask import (
    Blueprint,
    request,
)
from werkzeug.datastructures import FileStorage

from .db import get_db, near_text

bp = Blueprint("api", __name__, url_prefix="/api/v1")

@bp.route("/document/all", methods=["GET"])
def documents():
    db = get_db()
    result = (
        db.query.get("Document", ["title", "content"])
        .with_additional("id")
        .do()["data"]["Get"]["Document"]
    )
    # flatten document id
    for document in result:
        document["id"] = document["_additional"]["id"]
        del document["_additional"]

    return result

@bp.route("/document", methods=["POST"])
def create_document():
    db = get_db()
    try:
        file = request.files["file"]
        id = ""
        with db.batch as batch:
            file_dict = read_pdf(file)
            id = batch.add_data_object(file_dict, "Document")
        return id, 201
    except Exception as e:
        return f"Cloud not save the document: {e}", 400

def read_pdf(file: FileStorage) -> dict[str, any]:
    text = ""

    # Loop through each page in the PDF file and print its contents
    pdf_reader = pypdf.PdfReader(file.stream)
    for page_num in range(len(pdf_reader.pages)):
        page = pdf_reader.pages[page_num]
        text += page.extract_text()

    # Read the PDF file and extract the tables
    tables = tabula.read_pdf(file.stream, pages="all")
    for table in tables:
        text += table.to_string()

    file_dict = {"title": file.filename, "content": text}
    return file_dict

@bp.route("/document/delete/<id>", methods=["GET"])
def delete_document(id: str):
    db = get_db()
    try:
        db.data_object.delete(id)
        return "Deleted successfully", 200
    except Exception as e:
        return f"Cloud not delete the document: {e}", 400

@bp.route("/document/query/<query>", methods=["GET"])
def query_document(query: str):
    try:
        result = near_text(query, "Document")
        # flatten document certainty and distance
        for document in result:
            document["certainty"] = document["_additional"]["certainty"]
            document["distance"] = document["_additional"]["distance"]
            del document["_additional"]
        return result, 200
    except Exception as e:
        return f"Cloud not delete the document: {e}", 400