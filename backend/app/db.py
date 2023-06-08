import os
import weaviate
from flask import g, Flask
from dotenv import load_dotenv

load_dotenv()

document_schema = {
    "class": "Document",
    "description": "A collection of documents",
    "vectorizer": "text2vec-openai",
    "moduleConfig": {
        "text2vec-openai": {"model": "ada", "modelVersion": "002", "type": "text"}
    },
    "properties": [
        {
            "name": "title",
            "description": "Title of the document",
            "dataType": ["text"],
        },
        {
            "name": "content",
            "description": "Contents of the document",
            "dataType": ["text"],
        },
        {
            "name": "data",
            "description": "File data as byte array",
            "dataType": ["blob"],
            "moduleConfig": {
                "text2vec-openai": {
                    "skip": True,
                }
            },
        },
    ],
}

# should be in a separate db, but due to simplicity we use the same db
category_schema = {
    "class": "Category",
    "description": "A collection of categories",
    "properties": [
        {
            "name": "title",
            "description": "Title of the Category",
            "dataType": ["text"],
        },
        {
            "name": "parentId",
            "description": "Id of the parent category",
            "dataType": ["text"],
        },
        {
            "name": "fileIds",
            "description": "Files assigned to the category by id",
            "dataType": ["text[]"],
        }
    ],
}

def get_db() -> weaviate.Client:
    if "db" not in g:
        open_ai_api_key = os.getenv("OPEN_AI_API_KEY")
        g.db = weaviate.Client(
            "http://localhost:8080",
            additional_headers={"X-OpenAI-API-Key": open_ai_api_key},
        )

        g.db.batch.configure(
            batch_size=100,
            dynamic=True,
            timeout_retries=3,
        )

    return g.db


def init_db(app: Flask):
    """
    Initialize the database.
    Creates the schema if it doesn't exist.
    """
    with app.app_context():
      db = get_db()

      schema = db.schema.get()
      if schema.get("classes") is None or not schema["classes"]:
          db.schema.create_class(document_schema)
          db.schema.create_class(category_schema)

def near_text(query, collection_name):
  """
  Query Weaviate for similar documents.
  :return: A list of similar documents. Including the title, content, certainty and distance.
  """
  db = get_db()
  nearText = {
    "concepts": [query],
  }
  properties = [
    "title", "content",
    "_additional {certainty distance}"
  ]
  query_result = (
    db.query
    .get(collection_name, properties)
    .with_near_text(nearText)
    .with_additional("id")
    .do()
  )["data"]["Get"][collection_name]
  return query_result