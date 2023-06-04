import base64
import functools
import io

import pypdf
import tabula
from flask import Blueprint, request, send_file
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
            file.seek(0)
            file_dict["data"] = base64.b64encode(file.read()).decode("utf-8")
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


@bp.route("/resource/delete/<id>", methods=["GET"])
def delete_resource(id: str):
    db = get_db()
    try:
        # check if the resource is a category
        result = (
            db.query.get("Category", ["title"])
            .with_where({"path": ["id"], "operator": "Equal", "valueString": id})
            .do()["data"]["Get"]["Category"]
        )
        if result:
            # also delete all children of the category recursively
            delete_category_children(id)
        db.data_object.delete(id)
        return "Deleted successfully", 200
    except Exception as e:
        return f"Cloud not delete the resource: {e}", 400
    
def delete_category_children(id: str):
    db = get_db()
    try:
        # get all children of the category
        result = (
            db.query.get("Category", ["title"])
            .with_where({"path": ["parentId"], "operator": "Equal", "valueString": id})
            .with_additional("id")
            .do()["data"]["Get"]["Category"]
        )
        for category in result:
            db.data_object.delete(category["_additional"]["id"])
            delete_category_children(category["_additional"]["id"])
        return "Deleted successfully", 200
    except Exception as e:
        return f"Cloud not delete the resource: {e}", 400


@bp.route("/document/query/<query>", methods=["GET"])
def query_document(query: str):
    try:
        result = near_text(query, "Document")
        # flatten document certainty and distance
        for document in result:
            document["certainty"] = document["_additional"]["certainty"]
            document["distance"] = document["_additional"]["distance"]
            document["id"] = document["_additional"]["id"]
            del document["_additional"]
        return result, 200
    except Exception as e:
        return f"Cloud not query the document: {e}", 400


@bp.route("/document/<id>", methods=["GET"])
def get_document(id: str):
    db = get_db()
    try:
        result = (
            db.query.get("Document", ["title", "data"])
            .with_where({"path": ["id"], "operator": "Equal", "valueString": id})
            .do()["data"]["Get"]["Document"]
        )
        if not result:
            return f"No document found with id: {id}", 404

        document = result[0]
        base64_data = document["data"]
        binary_data = base64.b64decode(base64_data)
        title = document["title"]
        return send_file(
            io.BytesIO(binary_data),
            mimetype="application/pdf",
            download_name=title,
        )
    except Exception as e:
        return f"Could not retrieve the document: {e}", 400
    
@bp.route("/category/all", methods=["GET"])
def categories():
    db = get_db()
    result = (
        db.query.get("Category", ["title", "parentId"])
        .with_additional("id")
        .do()["data"]["Get"]["Category"]
    )
    # flatten document id
    for document in result:
        document["id"] = document["_additional"]["id"]
        del document["_additional"]

    return result

@bp.route("/category", methods=["POST"])
def create_category():
    db = get_db()
    try:
        category = request.json
        print(category)
        if not category["title"]:
            return f"Cloud not create the category: no title provided", 400
        if not "parentId" in category or not category["parentId"] or category["parentId"] == "root":
            category["parentId"] = "root"
        else:
            # check if the parent category exists
            result = (
                db.query.get("Category", ["title"])
                .with_where({"path": ["id"], "operator": "Equal", "valueString": category["parentId"]})
                .do()["data"]["Get"]["Category"]
            )
            if not result:
                return f"Parent category does not exist", 400
        # check if a category exists with the same name and parentId
        result = (
            db.query.get("Category", ["title"])
            .with_where(
                {
                    "operator": "And",
                    "operands": [
                        {"path": ["title"], "operator": "Equal", "valueString": category["title"]},
                        {"path": ["title"], "operator": "Equal", "valueString": category["title"]}
                    ],
                }
            )
            .do()["data"]["Get"]["Category"]
        )
        if result:
            return f"Category already exists", 400

        id = db.data_object.create(category, "Category")
        return id, 201
    except Exception as e:
        return f"Cloud not create the category: {e}", 400

