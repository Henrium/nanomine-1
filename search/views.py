from django.shortcuts import render, render_to_response, RequestContext

import pymongo, os
import copy, requests, json
from bson.objectid import ObjectId

from random import randint

# Create your views here.

def home(request):
        USER = "user1"
        PSWD = "user1"
        MDCS_URL = "http://localhost:8000"
        
        url = MDCS_URL + "/rest/explore/select/all"
        
        payload = {'dataformat':'json'}
        r = requests.get(url, params=payload,auth=(USER, PSWD))
        data = r.json() # returns list with single element of dict with mongo doc
        
        # Collect all particles and polymers
        # TO BE REPLACED BY DIRECT FILE INPUT
        AllPolymers = []
        AllPolymerAbbr =[]
        AllParticles = []
        AllParticleFormula = []
        ct = 1
        for doc in data:
            #print ct
            ct += 1
            #print doc['title']
            
            try:
                #MATERIALS = doc['content']['PolymerNanocomposite']['MATERIALS']
                PolymerName = doc['content']['PolymerNanocomposite']['MATERIALS']['Polymer']['ChemicalName']
                if PolymerName not in AllPolymers:
                    AllPolymers.append(PolymerName)
                PolymerAbbr = doc['content']['PolymerNanocomposite']['MATERIALS']['Polymer']['Abbreviation']
                if PolymerAbbr not in AllPolymerAbbr:
                    AllPolymerAbbr.append(PolymerAbbr)        
                #print PolymerName, PolymerAbbr
            except KeyError:
                pass
                
            try:
                ParticleName = doc['content']['PolymerNanocomposite']['MATERIALS']['Particle']['ChemicalName']
                if ParticleName not in AllParticles:
                    AllParticles.append(ParticleName)        
                ParticleFormula = doc['content']['PolymerNanocomposite']['MATERIALS']['Particle']['ChemicalStructure']
                if ParticleFormula not in AllParticleFormula:
                    AllParticleFormula.append(ParticleFormula)
                #print ParticleName, ParticleFormula
            except KeyError:
                pass
        
        QueryMatchCt = 0
        print (request.POST)
        if len(request.POST) != 0:
                print 'Query selections:'
                QueryPolymer = request.POST[u'polymer']
                print QueryPolymer
                QueryParticle = request.POST['particle']
                print QueryParticle
                
                # Perform query check
                QueryMatchCt = 0
                QueryMatchTitle = []
                PolymerExist = False
                ParticleExist = False
                for doc in data:
                        try:
                                TestPolymer = doc['content']['PolymerNanocomposite']['MATERIALS']['Polymer']['ChemicalName']
                                PolymerExist = True
                        except KeyError:
                                pass
                        try:
                                TestParticle = doc['content']['PolymerNanocomposite']['MATERIALS']['Particle']['ChemicalName']
                                ParticleExist = True
                        except KeyError:
                                pass
                        if PolymerExist and ParticleExist:
                                if TestParticle == QueryParticle and TestPolymer == QueryPolymer:
                                        global MatchedDoc
                                        QueryMatchTitle.append(doc['title'])
                                        QueryMatchCt += 1
                                        MatchedDoc = data
                                        
        return render_to_response('search.html',
                            locals(),
                            context_instance=RequestContext(request)
                            )

def SearchProperty(request):
        return render_to_response('search_properties.html',
                    locals(),
                    context_instance=RequestContext(request)
                    )

def ShowResult(request, titleId):
        
        print (request.POST)
        titleId = request.GET.get('titleId','')
        print titleId
        try:
                MatchedDoc
                # USE THE ACTUAL DOC SELECTED FROM SEARCH RESULT BY USER.
                QueryMsg = 'Displaying query result for sample ID: '+str(titleId)
                QueryExist = True
                for doc in MatchedDoc:
                        if doc['title'] == str(titleId):
                                SelectedDoc = doc                
        except NameError:
                QueryMsg = 'No query is submitted.'
                QueryExist = False

        if QueryExist == True:
                # metadata. all fields should exist
                QueryDict = SelectedDoc['content']['PolymerNanocomposite']
                # data source
                if QueryDict.has_key('DATA_SOURCE'):
                        DictDataSource = QueryDict['DATA_SOURCE']
                        PaperTitle = QueryDict['DATA_SOURCE']['Citation']['CommonFields']['Title']
                        Author = QueryDict['DATA_SOURCE']['Citation']['CommonFields']['Author']
                        Journal = QueryDict['DATA_SOURCE']['Citation']['CommonFields']['Publication']
                        Year = QueryDict['DATA_SOURCE']['Citation']['CommonFields']['PublicationYear']
                # materials
                if QueryDict.has_key('MATERIALS'):
                        DictMaterials = QueryDict['MATERIALS']
                        # polymer 
                        if DictMaterials.has_key('Polymer'):
                                DictPolymer = QueryDict['MATERIALS']['Polymer']
                        # Particle
                        if DictMaterials.has_key('Particle'):
                                DictParticle = QueryDict['MATERIALS']['Particle']
                                if DictParticle.has_key('ChemicalStructure'):
                                        ParticleStructure = DictParticle['ChemicalStructure']
                                if DictParticle.has_key('ChemicalName'):
                                        ParticleName = DictParticle['ChemicalName']                                
                                if DictParticle.has_key('CrystalPhase'):
                                        ParticleCystalPhase = DictParticle['CrystalPhase']
                                if DictParticle.has_key('TradeName'):
                                        ParticleTradeName = DictParticle['TradeName']                                
                                if DictParticle.has_key('Composition'):
                                        ParticleComposition = DictParticle['Composition']
                                        #NEED TO WRITE SUBROUTINE, AND USE HERE, TO TELL FIXED VALUE FROM DISTRIBUTION
                                        if 'volume' in ParticleComposition:
                                                CompositionKey = 'Volume Fraction'
                                                ParticleVF = ParticleComposition['volume']
                                        else:
                                                CompositionKey = 'Weight Fraction'
                                                ParticleWF = ParticleComposition['weight']
                                if DictParticle.has_key('ParticleSize'):
                                        ParticleSize = DictParticle['ParticleSize']
                                        if ParticleSize.has_key('FixedValue'):
                                                PartSizeVal = ParticleSize['FixedValue']['value']['value']
                                                PartSizeUnit = ParticleSize['FixedValue']['value']['unit']
                                if DictParticle.has_key('SpecificSurfaceArea'):
                                        ParticleSSAVal = DictParticle['SpecificSurfaceArea']['value']['value']
                                        ParticleSSAUnit = DictParticle['SpecificSurfaceArea']['value']['unit']
                        # surface treatment 
                        if DictMaterials.has_key('ParticleSurfaceTreatment'):
                                GenSurfTreat = QueryDict['MATERIALS']['ParticleSurfaceTreatment']
                                if type(GenSurfTreat) == dict:
                                        DictSurfTreat = GenSurfTreat
                                        if DictSurfTreat.has_key('ChemicalName'):
                                                SurfTreatName = DictSurfTreat['ChemicalName']
                                        if DictSurfTreat.has_key('Abbreviation'):
                                                SurfTreatStructure = DictSurfTreat['Abbreviation']
                                        if DictSurfTreat.has_key('Composition'):
                                                SurfTreatFract = DictSurfTreat['Composition']['Fraction']
                                elif type(GenSurfTreat) == list:
                                        # multiple surf treatment
                                        for DictSurfTreat in GenSurfTreat:
                                                if DictSurfTreat.has_key('ChemicalName'):
                                                        SurfTreatName = DictSurfTreat['ChemicalName']
                                                if DictSurfTreat.has_key('Abbreviation'):
                                                        SurfTreatStructure = DictSurfTreat['Abbreviation']
                                                if DictSurfTreat.has_key('Composition'):
                                                        SurfTreatFract = DictSurfTreat['Composition']['Fraction']
                if QueryDict.has_key('PROCESSING'):
                        DictProcess = QueryDict['PROCESSING']
                        #for ProcessMethod in DictProcess.keys():
                        #        for ProcessStep in DictProcess[ProcessMethod]:
                if QueryDict.has_key('PROPERTIES'):
                        DictProperties = QueryDict['PROPERTIES']
                        if DictProperties.has_key('Electrical'):
                                DictElectrical = DictProperties['Electrical']
                                if DictElectrical.has_key('AC_DielectricDispersion'):
                                        pass # plot data in excel
                                
                if QueryDict.has_key('MICROSTRUCTURE'):
                        DictStructure = QueryDict['MICROSTRUCTURE']
                        if DictStructure.has_key('ImageFile'):
                                DictImage = DictStructure['ImageFile']
                                if DictImage.has_key('File'):
                                        ImgBlob = DictImage['File']
                                if DictImage.has_key('ScaleBarPixelSize') and DictImage.has_key('ScaleBarPhysicalSize'):
                                        ScaleBarPixSize = DictImage['ScaleBarPixelSize']['value']
                                        ScaleBarActualSize = DictImage['ScaleBarPhysicalSize']['value']
                                        ScaleBarUnit = DictImage['ScaleBarPhysicalSize']['unit']
                                        ScaleBarRatio = ScaleBarActualSize/ScaleBarPixSize
                                if DictImage.has_key('MicroscopyType'):
                                        ImgGraphType = DictImage['MicroscopyType']
                                        
        return render_to_response('search_result.html',
                            locals(),
                            context_instance=RequestContext(request)
                            )