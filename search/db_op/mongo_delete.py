import pymongo
from bson.objectid import ObjectId

c = pymongo.MongoClient('mongodb://129.105.90.95:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

db.xmldata.remove({'_id':ObjectId('55c01ef6571e253a22de342d')})