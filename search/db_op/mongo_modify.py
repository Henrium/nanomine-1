# mongo_modify.py
# MongoDB insertion tool

# He Zhao, Aug 3, 2015
# This tool migrates saved documents in MDC mongoDB from one version to another. You will need to specify
# title of the document in both previous and new templates, and also the path to the parameter you would like to modify
# (edit, insert, remove). You can also insert a new field for data in spreadsheet. 

# Use MDC UI to work with most current template

import pymongo
import copy
from bson.objectid import ObjectId

c = pymongo.MongoClient('mongodb://129.105.90.95:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

### Modify here
# Define title names 
OldTitle = 'L124_Stest_Smith_2008' 			# Title of paper from old template
OldTitle2 = 'L136_S1_Vescovo_2010'
NewTitle = 'L124_Stest_Smith_2008_fake4' 	# Title of paper to save in new template
###

# Read content from old document
sample1 = db.xmldata.find_one({'title':OldTitle})
content = sample1[u'content'] 
oldId = sample1[u'_id']
oldSchema = sample1[u'schema']
# NewSchema = oldSchema
NewSchema = unicode('55bf9c03571e25157eccc7f5') # SchemaID for template PNC Aug 3
NewContent = copy.deepcopy(content)
NewTitle = unicode(NewTitle)

### Add field from another document if applicable
sample2 = db.xmldata.find_one({'title':OldTitle2})
content2 = sample2[u'content'] 
## Modify below: path to the Profile element. Also copy to line 47. 
curve = content2[u'PolymerNanocomposite'][u'PROPERTIES'][u'Viscoelastic'][u'DynamicProperties'][u'DynamicPropertyProfile']

### Modify here
# Simple parameters. Use unicode prefix 'u' before all strings
## Add or modify field 
# NewContent[u'PolymerNanocomposite'][u'DATA_SOURCE'][u'Reference'][u'CommonCitationFields'][u'Language'] = 'Jibberish'
## Copy path from line 39: add a spreadsheet or curve from another document
NewContent[u'PolymerNanocomposite'][u'PROPERTIES'][u'Viscoelastic'][u'DynamicProperties'][u'DynamicPropertyProfile'] = curve
## Remove a field
# del NewContent[u'PolymerNanocomposite'][u'PROCESSING'][u'MeltMixing'][u'ChooseParameter'][u'Molding']
###

# NewEntry[u'_id'] = unicode(ObjectId())
NewEntry = {}
NewEntry[u'schema'] = unicode(NewSchema)
NewEntry[u'title']= unicode(NewTitle)
NewEntry[u'content']=NewContent

# print sample1
# print unicode(NewEntry)

db.xmldata.insert(NewEntry)
print 'Success. New document uploaded'
c.close()