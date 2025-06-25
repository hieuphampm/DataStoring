from pymongo import MongoClient
from django.conf import settings

def get_mongo_client():
    """
    Returns a MongoDB client instance.
    """
    mongo_url = settings.MONGO_URL
    if not mongo_url:
        raise ValueError("MONGO_URL is not set in settings.")
    return MongoClient(mongo_url)

def get_mongo_db(db_name):
    client = get_mongo_client()
    return client[db_name]

def get_mongo_collection(db_name, collection_name):
    db = get_mongo_db(db_name)
    return db[collection_name]