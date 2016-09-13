from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass
from XMLCONV.models import Document
from XMLCONV.forms import DocumentForm
from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np

import os.path
# Create your views here.

ParentDir = '/home/NANOMINE/ONR/Converter_web/'

def home(request):
    if request.user.is_authenticated():
        global timestamp, excel_file, img_file
        timestamp = strftime("%Y%M%d%H%M%S", gmtime())
        
        if request.method == 'POST':
            
            form = DocumentForm(request.POST, request.FILES)
            if form.is_valid():
                files = request.FILES.getlist('docfile')
                for f in files:
                    newdoc = Document(docfile = f)
                    newdoc.save()            
            
                excel_file = request.POST.get('excel_file')
                img_file = request.POST.get('img_file')
 
                f = open('./XMLCONV/RunCount.num', 'r+')
                count = f.readlines()
                print 'total count so far is:'
                print count
                f.seek(0)
                newcount = int(count[0]) + 1
                f.write(str(newcount))
                f.close()
                
                WorkingDir = ParentDir + timestamp + '_' + str(int(count[0]))
                if not os.path.exists(WorkingDir):
                    os.makedirs(WorkingDir)
                    print '---------------------------Created working folder'
                
                f = open('./XMLCONV/workingdir.str', 'w+')
                f.write(WorkingDir)
                f.close()
        
                
                # Copy source code to working dir
                os.system('cp -avr /home/NANOMINE/ONR/Converter_web/code/* '+WorkingDir)
                os.system('cp ./XMLCONV/workingdir.str '+WorkingDir)
                
        
                cpfile = 'mv ./XMLCONV/media/'+excel_file+' '+ WorkingDir
                print cpfile
                os.system(cpfile)
                
                toPath = 'cd '+WorkingDir+'/Huddle-parsingmsexcel;'
                call_start = "python run_yzj.py %s" %(excel_file)
                call_start2 = "python run2_yzj.py %s" %(excel_file)
                print toPath
                print call_start + call_start2
                os.system(toPath + call_start)
                os.system(toPath + call_start2)
                
                for i in img_file.split(';'):
                    cpimg = 'mv ./XMLCONV/media/'+i+' /var/www/html/nanomine/XMLCONV/media'
                    os.system(cpimg)
 
 
                return HttpResponseRedirect(reverse('XMLCONV.views.home'))
        else:
            print 'not valid'
            form = DocumentForm()
        documents = Document.objects.all()
        return render(request, 'XMLCONV.html', {'form': form}, context_instance=RequestContext(request))
    else:
        return redirect('/login')
    
    
    
#def runmodel(request):
#    if request.user.is_authenticated():
#        global JOBID, WorkingDir

		
		# run model to nuhup

#        f = open('./XMLCONV/RunCount.num', 'r+')
#        count = f.readlines()
#        print 'total count so far is:'
#        print count
#        f.seek(0)
#        newcount = int(count[0]) + 1
#        f.write(str(newcount))
#        f.close()
        
#        WorkingDir = ParentDir + timestamp + '_' + str(int(count[0]))
#        if not os.path.exists(WorkingDir):
#            os.makedirs(WorkingDir)
#            print '---------------------------Created working folder'
        
#        f = open('./XMLCONV/workingdir.str', 'w+')
#        f.write(WorkingDir)
#        f.close()

        
        # Copy source code to working dir
#        os.system('cp /home/NANOMINE/ONR/Converter_web/code/* '+WorkingDir)
#        os.system('cp ./XMLCONV/workingdir.str '+WorkingDir)
        

#        cpfile = 'mv ./XMLCONV/media/* ' + WorkingDir
#        print cpfile
#        os.system(cpfile)
        
#        toPath = 'cd '+WorkingDir+'/Huddle-parsingmsexcel;'
#        call_start = "python run_yzj.py %s" %(excel_file)
#        print call_start
#        os.system(toPath + call_start)





#       return render_to_response("XMLCONVRun.html", locals(), context_instance=RequestContext(request))
#    else:
#        return redirect('/login')
