from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass
from xmlconv.models import Document
from xmlconv.forms import DocumentForm
from time import gmtime, strftime
from operator import itemgetter

import time, math, glob
import numpy as np

import os.path
# Create your views here.

ParentDir = '/home/NANOMINE/nmdata/xmlconv/archive/'
SrcDir = '/home/NANOMINE/Develop/src/xmlconv/'

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
 
                f = open('./xmlconv/RunCount.num', 'r+')
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
                
                f = open('./xmlconv/workingdir.str', 'w+')
                f.write(WorkingDir)
                f.close()
        
                # Copy source code to working dir
                os.system('cp -avr '+SrcDir+'* '+WorkingDir)
                os.system('cp ./xmlconv/workingdir.str '+WorkingDir)
                
                # move all files to WorkingDir
                # cpfile = 'mv ./xmlconv/media/'+excel_file+' '+ WorkingDir
                cpfile = 'mv ./xmlconv/media/*'+' '+ WorkingDir
                print cpfile
                os.system(cpfile)
                
                # Get excel_file from Excel that ends with .xlsx or .xls
                xlsx_files = glob.glob(WorkingDir + '/*.xlsx')
                xls_files = glob.glob(WorkingDir + '/*.xls')
                print 'xlsx files:', xlsx_files
                print 'xls files:', xls_files
                
                # with extension
                if len(xlsx_files) >= 1:
                    # excel_file = xlsx_files[0].split('/')[-1]
                    excel_file = 'data.xlsx'
                elif len(xls_files) >= 1:
                    # excel_file = xls_files[0].split('/')[-1]
                    excel_file = 'data.xls'
                
                print 'excel_file', excel_file
                
                toPath = 'cd '+WorkingDir+'/;'
                call_start = "python compile_xml_ec2_040617.py %s" %(excel_file)
                os.system(toPath+call_start)
                with open(WorkingDir + '/ID.txt') as _f:
                    doc_ID = _f.read()
                call_start2 = "python upload_to_db.py %s" %(doc_ID)
                print call_start
                print call_start2
                os.system(toPath + call_start2)
                
                all_files = glob.glob(WorkingDir + '/*.*')
                img_file = list()
                for f in all_files:
                    if f.split('.')[-1] in ['png', 'jpg', 'tif']:
                        img_file.append(f)
                print 'img_file:', img_file
                
                cmd_mkdir_media = 'mkdir /var/www/html/nanomine/xmlconv/media/' + str(count[0])
                os.system(cmd_mkdir_media)
                    
                # copy image files to html folder
                for i in img_file:                    

                    cpimg = 'cp '+i+' /var/www/html/nanomine/xmlconv/media/'+ str(count[0])
                    os.system(cpimg)
 
 
                return HttpResponseRedirect(reverse('xmlconv.views.home'))
        else:
            print 'not valid'
            form = DocumentForm()
        documents = Document.objects.all()
        return render(request, 'xmlconv.html', {'form': form}, context_instance=RequestContext(request))
    else:
        return redirect('/login')