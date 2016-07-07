### DEMO FOR GROUP MEETING

import pymongo
import copy
from bson.objectid import ObjectId

c = pymongo.MongoClient('mongodb://localhost:27017/')
db = c.mgi
db.authenticate('admin1','admin1', source='admin')

title = 'L137_S12_Yang_2014'
sample1 = db.xmldata.find({'title':title})

for doc in sample1:
    print doc.has_key('content')
    if doc[u'content'] [u'PolymerNanocomposite'].has_key('PROPERTIES'):
        
        item = doc[u'content'] [u'PolymerNanocomposite'][u'PROPERTIES']
        data_ep = item[u'Electrical'][u'AC_DielectricDispersion']
        
        # Read data
        for key1 in data_ep.keys():
            
            if key1 == 'AC_Dielectric_Constant':
                data = data_ep[u'AC_Dielectric_Constant']
                # header
                column = data[u'headers'][u'column']
                # header one
                for i in range(len(column)):
                    # show names of header columns
                    print column[i][u'#text']
                # print column
                row = data[u'rows'][u'row']
                for j in range(len(row)):
                    RowColumn = row[j][u'column']
                    freq = RowColumn[0][u'#text']
                    ep = RowColumn[1][u'#text']
                    print freq, ep  
                # print row
    elif doc[u'content'] [u'PolymerNanocomposite'].has_key('MATERIALS'):
        item = doc[u'content'] [u'PolymerNanocomposite'][u'MATERIALS']
        # polymer
        polymerChemicalname = item[u'Polymer'][u'ChemicalName']
        polymerAbbre = item[u'Polymer'][u'Abbreviation']
        print polymerChemicalname
        # particle 
        particleChemicalName = item[u'Particle'][u'ChemicalName']
        print particleChemicalName
        particleVF = item[u'Particle'][u'VolumeFractionPercentage']
        print particleVF
        # surface treatment
        for i in range(len(item[u'ParticleSurfaceTreatment'])):
            graftName = item[u'ParticleSurfaceTreatment'][i][u'ChemicalName']
            graftDensity = item[u'ParticleSurfaceTreatment'][i][u'GraftDensity']
            graftDensityValue = graftDensity[u'value']
            graftDensityUnit = graftDensity[u'unit']
            print graftDensityUnit
    # print item.keys()
    print '--------- done with one doc'


c.close()
