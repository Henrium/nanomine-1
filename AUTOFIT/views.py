from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass
from AUTOFIT.models import Document
from AUTOFIT.forms import DocumentForm
from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np

import os.path
# Create your views here.

ParentDir = '/home/NANOMINE/ONR/AUTOFIT_web/'

            
def home(request):
    if request.user.is_authenticated():
        global timestamp, binary_file, real_file, img_file, actuallength, DiToPi, vf_expt
        timestamp = strftime("%Y%M%d%H%M%S", gmtime())
        
        if request.method == 'POST':
            
            form = DocumentForm(request.POST, request.FILES)
            if form.is_valid():
                files = request.FILES.getlist('docfile')
                for f in files:
                    newdoc = Document(docfile = f)
                    newdoc.save()            
            
                binary_file = request.POST.get('binary_file')
                real_file = request.POST.get('real_file')
                img_file = request.POST.get('img_file')
                actuallength = request.POST['actuallength']
                DiToPi = request.POST['DiToPi']
                vf_expt = request.POST['vf_expt']
 
                return HttpResponseRedirect(reverse('AUTOFIT.views.home'))
        else:
            print 'not valid'
            form = DocumentForm()
        documents = Document.objects.all()
        return render(request, 'AUTOFIT.html', {'form': form}, context_instance=RequestContext(request))
    else:
        return redirect('/login')
    
def runmodel(request):
    if request.user.is_authenticated():
        global JOBID, WorkingDir, link2result, ApacheCaseDir
        # run model to nuhup
        f = open('./AUTOFIT/RunCount.num', 'r+')
        count = f.readlines()
        print 'total count so far is:'
        print count
        f.seek(0)
        newcount = int(count[0]) + 1
        f.write(str(newcount))
        f.close()
        
        f = open('./AUTOFIT/PortCount.num', 'r+')
        PORT = int(f.readlines()[0])
        f.seek(0)
        if PORT == 5300:
            f.write(str(4300))
        else:
            newport = PORT + 2
            f.write(str(newport))
        f.close

        WorkingDir = ParentDir + timestamp + '_' + str(int(count[0]))
        if not os.path.exists(WorkingDir):
        	os.makedirs(WorkingDir)
        	print '---------------------------Created working folder'

		f = open('./AUTOFIT/workingdir.str', 'w+')
		f.write(WorkingDir)
		f.close()

        # copy cource code to working dir
        #os.makedirs(WorkingDir+'/FEA50DOE')
        os.system('cp /home/NANOMINE/ONR/AUTOFIT_web/code/FEA50DOE/* '+WorkingDir)
        #os.makedirs(WorkingDir+'/bin2structure')
        os.system('cp /home/NANOMINE/ONR/AUTOFIT_web/code/bin2structure/* '+WorkingDir)
        #os.makedirs(WorkingDir+'/singelrunopt0722')
        os.system('cp /home/NANOMINE/ONR/AUTOFIT_web/code/singelrunopt0722/* '+WorkingDir)
        #os.makedirs(WorkingDir+'/DOE50')
        os.system('cp ./AUTOFIT/workingdir.str '+WorkingDir)
        
        # Create new HTML in apache path to display modeling process
        ApacheCaseDir = '/var/www/html/nanomine/AUTOFIT/'+timestamp+'_'+str(int(count[0]))	

		# Link of Apache page

        link2result = 'http://nanomine.northwestern.edu/nanomine/AUTOFIT/'+timestamp+'_'+str(int(count[0]))
        if not os.path.exists(ApacheCaseDir):
        	os.makedirs(ApacheCaseDir)
        	print '----------------Created user case Apache folder'
        
        cpbinary = 'mv ./AUTOFIT/media/'+binary_file+'.mat '+WorkingDir
        os.system(cpbinary)
        cpimg = 'mv ./AUTOFIT/media/'+img_file+' '+WorkingDir
        cpreal = 'mv ./AUTOFIT/media/'+real_file+' '+WorkingDir
        os.system(cpimg)
        os.system(cpreal)

        JOBID = timestamp+'_'+str(int(count[0]))
        toPath = 'cd '+WorkingDir
        # run bin to struction code
        callbin = 'nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'
        callbin2 = " runbin('"+binary_file+"', '"+str(actuallength)+"','"+str(DiToPi)+"','"+str(vf_expt)+"'"
        callbin3 = ');exit" > a.log &'
        print callbin+callbin2+callbin3
        os.system(toPath+';'+callbin+callbin2+callbin3)
        
        # run comsol code to get 50 doe....csv file
        str_OpenPort1 = '/usr/local/bin/comsol server -port '+str(PORT)+' &'
        str_PATH = "addpath('/usr/local/comsol52/multiphysics/mli', '/usr/local/comsol52/multiphysics/mli/startup');"
        str_PathPort1 = str_PATH + "mphstart("+str(PORT)+");"
        callcomsol1 = '(nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'+str_PathPort1
        callcomsol12 = " comsol_conf('small.txt', '"+binary_file+"_2D_structure_output.mat'"
        callcomsol13 = ');exit" > b.log &&'
        print str_OpenPort1
        print callcomsol1+callcomsol12+callcomsol13
        os.system(str_OpenPort1)
        #os.system(toPath+';'+callcomsol1+callcomsol12+callcomsol13)
        
        
        # run runoptimal.m to get validation.txt
        callopt = ' nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'
        callopt2 = " runoptimal('"+img_file+"','"+real_file+"'"
        callopt3 = ');exit" > c.log &&'
        #print callopt+callopt2+callopt3
        #os.system(toPath+';'+callopt+callopt2+callopt3)
        
      
        # run comsol code again with validation.mat to get predict's DOE...csv
        str_OpenPort2 = '/usr/local/bin/comsol server -port '+str(PORT+1)+' &'
        str_PATH = "addpath('/usr/local/comsol52/multiphysics/mli', '/usr/local/comsol52/multiphysics/mli/startup');"
        str_PathPort2 = str_PATH + "mphstart("+str(PORT+1)+");"
        callcomsol2 = ' nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'+str_PathPort2
        callcomsol22 = " comsol_conf('validation.txt', '"+binary_file+"_2D_structure_output.mat'"
        callcomsol23 = ');exit" > d.log &&'
        #print callcomsol2+callcomsol22+callcomsol23
        os.system(str_OpenPort2)
        #os.system(toPath+';'+callcomsol2+callcomsol22+callcomsol23)        
        
        #time.sleep(120)
        # run compareplot to plot 2 figures
        callplot = ' nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'
        callplot2 = " compareplot('"+img_file+"','"+real_file+"'"
        callplot3 = ');exit" > e.log) &'
        #print callplot+callplot2+callplot3
        #os.system(toPath+';'+callplot+callplot2+callplot3)

        os.system(toPath+';'+callcomsol1+callcomsol12+callcomsol13+
                  callopt+callopt2+callopt3+
                  callcomsol2+callcomsol22+callcomsol23+
                  callplot+callplot2+callplot3)
 

        return render_to_response("AUTOFITRun.html", {'jobid':JOBID}, context_instance=RequestContext(request))
    else:
        return redirect('/login')

def check(request):
    if request.user.is_authenticated():
        FINISH = 0
        real_file = ''
        img_file = ''
        out_file = ''
        
        try:
            JOBID
        except NameError:
            defaultJobID = ''
        else:
            defaultJobID = JOBID
            
        if len(request.POST) != 0:
            jobID = request.POST['job_ID']
            defaultJobID = jobID
            
            WORKDING_DIR = ParentDir+str(jobID)
            ApacheCaseDir = '/var/www/html/nanomine/AUTOFIT/'+str(jobID)
            # some status file to make sure job is done
            if os.path.exists(WORKDING_DIR+'/compareImag.png'):
                FINISH = 1;
            
            if FINISH == 1:		
                os.system('cp '+WORKDING_DIR+'/validation.txt '+ApacheCaseDir)
    
                os.system('cp '+WORKDING_DIR+'/comparereal.png '+ApacheCaseDir)
                os.system('cp '+WORKDING_DIR+'/compareImag.png '+ApacheCaseDir)
                HTTPROOT = 'http://nanomine.northwestern.edu/nanomine/AUTOFIT/'+str(jobID)
                out_file = HTTPROOT+'/validation.txt'
                img_file = HTTPROOT+'/compareImag.png'
                real_file = HTTPROOT+'/comparereal.png'
        return render_to_response("AUTOFITCheck.html",
                                    {'defaultID': defaultJobID,
                                    'real_img':real_file, 'img_img':img_file, 'out_csv':out_file, 'finish':FINISH},
                                context_instance=RequestContext(request))
    else:
        return redirect('/login')


def result(request):
	if request.user.is_authenticated():
		return render_to_response("AUTOFITResult.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')

def sample(request):
	if request.user.is_authenticated():
		return render_to_response("AUTOFITSample.html", locals(),
				context_instance=RequestContext(request))
	else:
		return redirect('/login')	
	


