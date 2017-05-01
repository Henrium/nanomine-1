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

# common path and urls
ServerNiblackParent = '/home/NANOMINE/ONR/niblack_web/archive/' # on Titan
ServerNiblackSrc = '/home/NANOMINE/ONR/niblack_web/src/'
HttpDir = '/var/www/html/nanomine/niblack/' # on titan
TitanServerIP = '129.105.90.149' # todo: move this to ENV
SCPSink = 'NANOMINE@'+TitanServerIP+':~/ONR/niblack_web/archive/'

LocalUrlRoot = 'http://54.190.30.121/nanomine/niblack/'
LocalNiblackParent = '/home/NANOMINE/nmdata/niblack/archive/' # on web server
url_img_not_found = 'http://nanomine.northwestern.edu/nanomine/image-not-found.jpg'

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
                os.system('mkdir '+LocalNiblackParent+run_id) # local data folder
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
                
                # copy niblack summary to local data folder
                cmd_scp_summary = 'scp '+SCPSink+run_id+'/NiblackSummary.mat '+LocalNiblackParent+run_id
                os.system(cmd_scp_summary)
                
                return HttpResponseRedirect(reverse('niblack.views.home'
                        ))
        else:
            form = DocumentForm()  # A empty, unbound form

        return render_to_response('niblack.html',
                                  {
                                  'form': form,
                                  'run_count': count[0]},
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def check(request):
    '''Check previous niblack run and config next run if any'''
    if request.user.is_authenticated():
        
        # initialize null values to prevent valueerror
        fname = ''
        img_size = ''
        win_size = ''
        count = 0
        run_id_found = False
        run_id = ''
        # init img url to not found img
        url_jpg_before = url_img_not_found
        url_jpg_after = url_img_not_found
        count = '' # init with empty JID to send to html
        if request.method == 'POST':
            count = request.POST['job_id']
            # assign dummy 0 if no job_id is entered
            try:
                int(count)
            except ValueError:
                count = 0
            with open('./niblack/run_id_lookup', 'r') as f:
                table_content = f.readlines()
            for l in table_content:
                tp = l.strip('\n') # tuple of run_id, count
                if int( tp.split(',')[-1] ) == int(count):
                    run_id = str(tp.split(',')[0])
                    run_id_found = True
                    print 'JID found'
                    break
                # no match found
                run_id = 'not found'
            del table_content
            
            if run_id_found:
                # pass JPG url for display
                url_parent_server = LocalUrlRoot
                url_jpg_before = url_parent_server+run_id+'/NBbefore.jpg'
                url_jpg_after = url_parent_server+run_id+'/NBafter.jpg'
                
                # read summary from last run
                LocalSummaryMat = LocalNiblackParent+run_id+'/NiblackSummary.mat'
                print 'local summary mat file loc:', LocalSummaryMat
                if os.path.isfile(LocalSummaryMat):
                    mat = scipy.io.loadmat(LocalSummaryMat)
                    fname = mat['fname'][0]
                    img_size = int(mat['img_size'])
                    win_size = int(mat['win_size'])  # adjusted window size
            
                # Get adjust win size value from form
                try:
                    adjust = request.POST['val_adjust']
                except:
                    adjust = ''
                if adjust != '':
                    # if there is input for adjust
                    # todo: add sanity check. avoid non integer input
                    
                    print 'User input adjust win size:'
                    print adjust
                    
                    # write param for next run to passed to server
                    with open(LocalNiblackParent+run_id+'/adjust', 'w') as f:
                        f.write(str(adjust))
                    with open(LocalNiblackParent+run_id+'/winsize', 'w') as f:
                        f.write(str(win_size))
                    
                    print win_size
                    
                    # send the files to server
                    cmd_scp_adjust_to_server = 'scp '+LocalNiblackParent+run_id+'/adjust '+SCPSink+run_id+'/mfiles'
                    os.system(cmd_scp_adjust_to_server)
                    cmd_scp_win_size_to_server = 'scp '+LocalNiblackParent+run_id+'/winsize '+SCPSink+run_id+'/mfiles'
                    os.system(cmd_scp_win_size_to_server)
                    
                    # Run MATLAB for next run
                    # connect to titan server
                    ssh = paramiko.SSHClient()
                    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                    ssh.load_system_host_keys()
                    ssh.connect(TitanServerIP, username='NANOMINE')
                    stdin, stdout, stderr = ssh.exec_command('matlab -nodesktop -nodisplay -nojvm -nosplash -r "cd '+ServerNiblackParent+run_id+'/mfiles;run_niblack;exit"')
                    
                    # copy result JPGs to www folder
                    time.sleep(20) # leave at least 20 s for processing
                    cmd_server_copy_to_http = 'scp -r '+SCPSink+run_id+'/*.jpg '+HttpDir+run_id 
                    os.system(cmd_server_copy_to_http)
                    print cmd_server_copy_to_http
                    
                    # copy niblack summary to local data folder
                    cmd_scp_summary = 'scp '+SCPSink+run_id+'/NiblackSummary.mat '+LocalNiblackParent+run_id
                    os.system(cmd_scp_summary)
                else:
                    # if not valid, prompt for new form
                    form = NiblackAdjustForm()

        return render_to_response('niblack_result.html', {
            'job_id_init': count,
            'fname': fname.upper(),
            'img_pix_size': img_size,
            'win_size': win_size,
            'url_before': url_jpg_before,
            'url_after': url_jpg_after,
            'job_found':run_id_found,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')



			