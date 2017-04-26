#!/usr/bin/python
# -*- coding: utf-8 -*-

from django.shortcuts import render_to_response, render, \
    RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from django.utils.encoding import smart_unicode

from descchar.models import Document
from descchar.forms import DocumentForm

import xmltodict
import os
import scipy.io

import paramiko
from time import gmtime, strftime
import glob

# Create your views here.

ServerDesccharParent = '/home/NANOMINE/ONR/DescChar_web' # on Titan
HttpDir = '/var/www/html/nanomine/descchar'
TitanServerIP = '129.105.90.149'
SCPSink = 'NANOMINE@'+TitanServerIP+':~/ONR/DescChar_web/'

def home(request):
    
    
    if request.user.is_authenticated():
        
        # get current time
        timestamp = strftime("%Y%M%d%H%M%S", gmtime())
        
        # get current run count
        f = open('./descchar/RunCount.num', 'r+')
        count = f.readlines()
        
        # Handle file upload
        if request.method == 'POST':
            form = DocumentForm(request.POST, request.FILES)
            if form.is_valid():
                
                newdoc = Document(docfile=request.FILES['docfile'])
                newdoc.save()
                print 'FORM VALID'
                
                print 'total count so far is:'
                print count
                f.seek(0)
                newcount = int(count[0]) + 1
                f.write(str(newcount))
                f.close()
                
                # generate unique run_id
                run_id = timestamp+'_'+ str(int(count[0]))
                with open('./descchar/run_id', 'w+') as f:
                    f.write(run_id)
                    
                # path to uploaded file
                DocPath = './descchar/media/documents/'+str(strftime("%Y/%m/%d", gmtime()))+'/'+str(count[0])

                # copy the file with name as run_id
                uploaded_file = glob.glob(DocPath+'/*')
                os.system('cp '+uploaded_file[0]+' '+ DocPath+'/'+str(run_id)+'.mat')
                
                # Use remote SSH to trigger jobs at home server
                # connect to ssh remote server
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.load_system_host_keys()
                ssh.connect(TitanServerIP, username='NANOMINE')
                # transfer file to remote
                os.system('scp '+DocPath+'/'+str(run_id)+'.mat '+SCPSink+'data')
                os.system('scp ./descchar/run_id '+SCPSink)
                
                # run command on remote server
                cmd_server_run_matlab = 'matlab -nodesktop -nodisplay -nojvm -nosplash -logfile /home/NANOMINE/ONR/DescChar_web/matlab_logs/'+str(run_id)+'.log -r "cd ' \
                    + ServerDesccharParent + '/mfiles;run_descchar;exit"'
                stdin, stdout, stderr = ssh.exec_command(cmd_server_run_matlab)
                
                print stdout.read()

            # Redirect to the document list after POST

                return HttpResponseRedirect(reverse('descchar.views.home'
                        ))
        else:
            print 'FORM NOT VALID'
            form = DocumentForm()  # A empty, unbound form

        # Load documents for the list pag

        documents = Document.objects.all()

        # Render list page with the documents and the form

        return render(request, 'descchar.html',
                      {'documents': documents, 'form': form, 'run_count': count[0]},
                      context_instance=RequestContext(request))
    else:
        return redirect('/login')


def check(request):
    if request.user.is_authenticated():

        # Load selected descriptors from char result

        if os.path.isfile(DesccharParent
                          + '/mfiles/char_result/ch_result.mat'):
            mat = scipy.io.loadmat(DesccharParent
                                   + '/mfiles/char_result/ch_result.mat'
                                   )
            n = int(round(mat['R_n'], 0))
            rc = round(mat['P_awrc'][0][0], 2)
            ncd = round(mat['P_ncd'][0][0], 2)
            ar = round(mat['P_awar'][0][0], 2)
            rnds = round(mat['P_rnds'][0][0], 2)
            eccen = round(mat['P_eccen'][0][0], 2)
            ornang = round(mat['P_ornang'][0][0], 2)
            filename = mat['name'][0]
        else:
            n = ''
            rc = ''
            ncd = ''
            ar = ''
            rnds = ''
            eccen = ''
            ornang = ''
            filename = ''
        return render_to_response('descchar_view.html', {
            'name': filename,
            'n': n,
            'ar': ar,
            'rc': rc,
            'ncd': ncd,
            'rnds': rnds,
            'eccen': eccen,
            'ornang': ornang,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')



			