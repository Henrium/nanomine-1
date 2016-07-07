# Use pymongo to connect with mongodb
# This can only be run on PUMA

from pymongo import MongoClient
import xmltodict
c = MongoClient('mongodb://129.105.90.95:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

# suppose we obtain a query result, type <dict>
sample1 = db.xmldata.find_one({'title':'L109_S1_Pothukuchi_2004'})

# list all keys in this dict
sample1.keys()

# In mgi htmlform, should return four: content, schema, _id, title
result = sample1[u'content'] # xml string

print result

c.close()

# parse xml string to dict
#dict1 = xmltodict.parse(result)