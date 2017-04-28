#!/usr/bin/python
# -*- coding: utf-8 -*-
from django.shortcuts import render_to_response, render, \
    RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse

from niblack.models import Document
from niblack.forms import *

import xmltodict
import os
import scipy.io

from time import gmtime, strftime, localtime
import paramiko
import time

# workflow: upload TIF through home view
# 1. prompt use to run to upload image to titan server
# 2. check view ask for run_id and compares grayscale with binary result on same page
# 3. check view - if run_id valid - ask for adjust window size - continue to run

ServerNiblackParent = '/home/NANOMINE/ONR/niblack_web/archive/' # on Titan
ServerNiblackSrc = '/home/NANOMINE/ONR/niblack_web/src/'
HttpDir = '/var/www/html/nanomine/niblack/' # on titan
TitanServerIP = '129.105.90.149' # todo: move this to ENV
SCPSink = 'NANOMINE@'+TitanServerIP+':~/ONR/niblack_web/archive/'

def home(request):
    if request.user.is_authenticated():
        # get current time
        timestamp = strftime("%Y%M%d%H%M%S", localtime())
        
        # get current run count
        f = open('./niblack/RunCount.num', 'r+')
        count = f.readlines()
        f.close()
        
        if request.method == 'POST':
            form = DocumentForm(request.POST, request.FILES)
            if form.is_valid():
                newdoc = Document(docfile=request.FILES['docfile'])
                newdoc.save()

                # update run count
                f = open('./niblack/RunCount.num', 'r+')
                count = f.readlines()
                print count
                f.seek(0)
                newcount = int(count[0]) + 1
                f.write(str(newcount))
                f.close()
                
                # generate unique run_id
                run_id = timestamp+'_'+ str(int(count[0]))
                with open('./niblack/run_id', 'w+') as f:
                    f.write(run_id)
                
                # record run_id to be looked up with count
                with open('./niblack/run_id_lookup', 'a+') as f:
                    f.write(run_id+','+count[0]+ '\n')
                    
                # path to uploaded file
                DocPath = './niblack/media/documents/'+str(strftime("%Y/%m/%d", localtime()))+'/'+str(count[0])
                
                # connect to titan server
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.load_system_host_keys()
                ssh.connect(TitanServerIP, username='NANOMINE')
                # make new folder for image
                stdin, stdout, stderr = ssh.exec_command('mkdir '+ServerNiblackParent+run_id) # data folder
                os.system('mkdir '+HttpDir+run_id) # www folder
                # copy source files to new folder
                stdin, stdout, stderr = ssh.exec_command('cp -r '+ServerNiblackSrc+'* '+ServerNiblackParent+run_id+'/')
                # SCP uploaded image to titan server
                os.system('scp '+DocPath+'/*.TIF '+SCPSink+run_id+'/')
                
                # Run MATLAB when file is valid
                stdin, stdout, stderr = ssh.exec_command('matlab -nodesktop -nodisplay -nojvm -nosplash -r "cd '+ServerNiblackParent+run_id+'/mfiles;run_niblack;exit"')
                
                # copy result JPGs to www folder
                time.sleep(5)
                cmd_server_copy_to_http = 'scp -r '+SCPSink+run_id+'/*.jpg '+HttpDir+run_id 
                os.system(cmd_server_copy_to_http)
                print cmd_server_copy_to_http
                
                return HttpResponseRedirect(reverse('niblack.views.home'
                        ))
        else:
            form = DocumentForm()  # A empty, unbound form

        # Load documents for the list page
        documents = Document.objects.all()

        # Render list page with the documents and the form
        return render_to_response('niblack.html',
                                  {'documents': documents,
                                  'form': form},
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def check(request):
    if request.user.is_authenticated():

        # Perform dynamic binarization

        # Load summary parameters

        if os.path.isfile('./niblack/mfiles/niblack/imgs/NiblackSummary.mat'
                          ):
            mat = \
                scipy.io.loadmat('./niblack/mfiles/niblack/imgs/NiblackSummary.mat'
                                 )
            fname = mat['fname'][0]
            img_size = int(mat['img_size'])
            win_size = int(mat['win_size'])  # adjusted window size
        else:
            fname = ''
            img_size = ''
            win_size = ''

        # Get adjust win size value from form

        if request.method == 'POST':
            form = NiblackAdjustForm(request.POST)
            if form.is_valid():
                adjust = request.POST['adjust']

            # adjust = NiblackAdjust(AdjustValue)

                print 'User input adjust win size:'
                print request.POST['adjust']

                f1 = open('./niblack/mfiles/adjust', 'w')
                s = str(adjust)
                f1.write(s)
                f1.close()

                f2 = open('./niblack/mfiles/winsize', 'w')
                s2 = str(win_size)
                print s2
                f2.write(s2)
                f2.close()

            # Run MATLAB when form is valid

                os.system('matlab -nodesktop -nodisplay -nojvm -nosplash -r "cd niblack/mfiles;run_niblack;exit"'
                          )
                os.system('mv ./niblack/media/documents/jpg/NBbefore.tif /var/www/html/nm/NBbefore.tif'
                          )
                os.system('mv ./niblack/media/documents/jpg/NBafter.jpg /var/www/html/nm/NBafter.jpg'
                          )
        else:

            form = NiblackAdjustForm()

        return render_to_response('niblack_result.html', {
            'fname': fname,
            'img_pix_size': img_size,
            'win_size': win_size,
            'form': form,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')



			