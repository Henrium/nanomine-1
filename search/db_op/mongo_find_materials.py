# find using materials
import pymongo
import copy
from bson.objectid import ObjectId

from random import randint

c = pymongo.MongoClient('mongodb://localhost:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

AllSamples = db.xmldata.find()

# polymer = 'polystyrene' # query 
# 
# titles = []
# for doc in AllSamples:
#     if doc[u'content'].has_key('PolymerNanocomposite'):
#         if doc[u'content'][u'PolymerNanocomposite'].has_key('MATERIALS'):
#             if doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'].has_key('Polymer'):
#                 polymername = doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'][u'Polymer'][u'ChemicalName']
#                 # print polymername
#                 if polymername == polymer:
#                     # find title
#                     title = doc[u'title']
#                     # titles.append(title)
#                     # search by title
#                     print title
                    
                    
querytitle = 'Akcora S3'
ManufName = 'Dow Chemical'
for doc in AllSamples:
    if doc[u'title'] == querytitle:
        oldId = doc[u'_id']
        print oldId
        doc1 = copy.deepcopy(doc)
        del doc1[u'_id']
        doc1[u'content'][u'PolymerNanocomposite'][u'MATERIALS'][u'Polymer']['ManufacturerName'] = ManufName
        print 'done'
        db.xmldata.insert(doc1)
        db.xmldata.remove({'_id':(oldId)})
c.close()

    
            #        samples = db.xmldata.find({'title':title})
            #        for doc1 in samples:
            #            if doc1[u'content'] [u'PolymerNanocomposite'].has_key('PROPERTIES'):
            #                Property = doc[u'content'] [u'PolymerNanocomposite'][u'PROPERTIES']
            #                Properties = Property.keys()
            #                print Properties
            #if doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'].has_key('Particle'):
            #    if type(doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'][u'Particle']) == dict:
            #        if  doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'][u'Particle'].has_key('ChemicalName'):
            #            particlename = doc[u'content'][u'PolymerNanocomposite'][u'MATERIALS'][u'Particle'][u'ChemicalName']
            
# title = titles[int(randint(0, len(titles)-1))]
# print 'random title:', title
# 
# AllSamples = db.xmldata.find()
# 
# ct = 0 
# for doc in AllSamples:
#     
#     if doc[u'content'].has_key('PolymerNanocomposite') and doc.has_key('title'):
#         ct += 1
# 
#         if doc[u'title'] == title:
#             print 'found it!'
#             print doc[u'content'][u'PolymerNanocomposite'].keys()
# print ct 