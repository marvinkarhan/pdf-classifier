import base64
import io

import pypdf
from flask import Blueprint, request, send_file, jsonify
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
        ids = []
        with db.batch as batch:
            file_dict = read_pdf(file)
            file.seek(0)
            file_dict["data"] = base64.b64encode(file.read()).decode("utf-8")
            ids.append(batch.add_data_object(file_dict, "Document"))
        assign_documents_to_categories("root")
        return jsonify(ids), 201
    except Exception as e:
        return f"Cloud not save the document: {e}", 400


def read_pdf(file: FileStorage) -> dict[str, any]:
    text = ""

    # Loop through each page in the PDF file and print its contents
    pdf_reader = pypdf.PdfReader(file.stream)
    for page_num in range(len(pdf_reader.pages)):
        page = pdf_reader.pages[page_num]
        text += page.extract_text()

    file_dict = {"title": file.filename, "content": text}
    return file_dict


@bp.route("/resource/delete/<id>", methods=["GET"])
def delete_resource(id: str):
    db = get_db()
    try:
        # check if the resource is a category
        category = (
            db.query.get("Category", ["title", "parentId"])
            .with_where({"path": ["id"], "operator": "Equal", "valueString": id})
            .do()["data"]["Get"]["Category"]
        )
        if category:
            # also delete all children of the category recursively
            delete_category_children(id)
        db.data_object.delete(id)
        if category:
            # reassign all documents
            assign_documents_to_categories(category[0]["parentId"])
        return "Deleted successfully", 200
    except Exception as e:
        return f"Cloud not delete the resource: {e}", 400
    
def delete_category_children(id: str):
    db = get_db()
    try:
        # get all children of the category
        result = (
            db.query.get("Category", ["title"])
            .with_where({"path": ["parentId"], "operator": "Equal", "valueText": id})
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
        db.query.get("Category", ["title", "parentId", "fileIds"])
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
    # try:
    category = request.json
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
        db.query.get("Category", ["title", "parentId"])
        .with_where(
            {
                "operator": "And",
                "operands": [
                    {"path": ["title"], "operator": "Equal", "valueText": category["title"]},
                    {"path": ["parentId"], "operator": "Equal", "valueText": category["parentId"]}
                ],
            }
        )
        .do()["data"]["Get"]["Category"]
    )
    if result:
        return f"Category already exists", 400

    id = db.data_object.create(category, "Category")
    # TODO: should assign based on category id and tree traversal, but does not work as intended
    assign_documents_to_categories("root")
    return id, 201
    # except Exception as e:
    #     return f"Cloud not create the category: {e}", 400

def assign_documents_to_categories(category_id: str):
    db = get_db()
    # get category
    if category_id == "root":
        category = {"parentId": "root"}
    else:
        category = (
            db.query.get("Category", ["parentId"])
            .with_where({"path": ["id"], "operator": "Equal", "valueString": category_id})
            .do()["data"]["Get"]["Category"]
        )
        if not category:
            return
        category = category[0]
    # get parent
    if category["parentId"] == "root":
        parent = {"id": "root"}
    else:
        parent = (
            db.query.get("Category", ["title", "parentId"])
            .with_additional("id")
            .with_where({"path": ["id"], "operator": "Equal", "valueString": category["parentId"]})
            .do()["data"]["Get"]["Category"]
        )
        parent = flatten_id_prop(parent[0])
        if not parent:
            return
    # get all categories that are in the subtree of the category's parent
    subtree = get_flat_subtree(parent)
    # filter root category
    subtree = [category for category in subtree if category["id"] != "root"]
    # get all documents assigned to the parent and the neighboring categories
    if category["parentId"] == "root":
        documents = (
            db.query.get("Document", ["title"])
            .with_additional("id")
            .do()["data"]["Get"]["Document"]
        )
        file_ids = [document["_additional"]["id"] for document in documents]
    else:
        file_ids = [file_id for dict in subtree for file_id in dict.get("fileIds", [])]
    # assign documents to the category level by level
    assign_documents_to_categories_helper(subtree, category["parentId"], file_ids)

def assign_documents_to_categories_helper(categories, category_level, file_ids):
    current_categories = [category for category in categories if category["parentId"] == category_level]

    # get all document certainties for each category
    documents_per_category = {category['id']: near_text(category["title"], "Document") for category in current_categories}
    # prepare dictionary for assigning documents to categories and a list for all unassigned documents
    category_dict = {category['id']: [] for category in current_categories}
    unassigned = []
    for file_id in file_ids:
        highest_certainty = 0
        closest_category = None
        for category, distances in documents_per_category.items():
            result = next((d for d in distances if d["_additional"]["id"] == file_id), None)
            if result and result["_additional"]["certainty"] > highest_certainty:
                highest_certainty = result["_additional"]["certainty"]
                closest_category = category
        # assign document to current category level if blow threshold
        if highest_certainty < 0.8 or not closest_category:
            unassigned.append(file_id)
        else:
            category_dict[closest_category].append(file_id)

    # save documents on current level
    db = get_db()
    if category_level != "root":
        if unassigned:
            db.data_object.update({"fileIds": unassigned}, "Category", category_level)
        else:
            db.data_object.update({"fileIds": None}, "Category", category_level)

    # repeat for each child category
    for category_id, file_ids_per_category in category_dict.items():
        current_category = next((c for c in current_categories if c["id"] == category_id), None)
        if current_category:
            assign_documents_to_categories_helper(categories, current_category["id"], file_ids_per_category)

def get_flat_subtree(category):
    db = get_db()
    result = [category]
    # get children of the category
    children = (
        db.query.get("Category", ["title", "parentId"])
        .with_additional("id")
        .with_where({"path": ["parentId"], "operator": "Equal", "valueText": category["id"]})
        .do()["data"]["Get"]["Category"]
    )
    if not children:
        return result
    children = [flatten_id_prop(child) for child in children]
    # get all children of children
    for child in children:
        result = result + get_flat_subtree(child)
    return result
    
def flatten_id_prop(dict):
    dict["id"] = dict["_additional"]["id"]
    del dict["_additional"]
    return dict