# find using property

import pymongo
import copy
from bson.objectid import ObjectId

c = pymongo.MongoClient('mongodb://localhost:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

# input property name. One level down PROPERTIES category
MatProperty = 'AC_DielectricDispersion'
# find documents with property

# [u'content'] [u'PolymerNanocomposite'][u'PROPERTIES'][u'Electrical'][u'AC_DielectricDispersion']

sample1 = db.xmldata.find({
    u'content':{ u'PolymerNanocomposite':{
        u'PROPERTIES':{
            u'Electrical':{
                u'AC_DielectricDispersion':{'$exists': True},
            }
        }
    }}})

sample2 = db.xmldata.find({
    u'content':{ u'PolymerNanocomposite':{'$exists': True},
            }
        }
    )

print sample2

for doc in sample2:
    print 'one doc'