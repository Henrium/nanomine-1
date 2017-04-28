#!/usr/bin/python
# -*- coding: utf-8 -*-
from django.shortcuts import render, render_to_response, \
    RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from forms import *

import os
import random
import getpass
from dynamfit.models import Document
from dynamfit.forms import DocumentForm
from time import gmtime, strftime, localtime
from operator import itemgetter

import time
import math
import numpy as np

import os.path
import glob
import paramiko


ParentDir = '/home/NANOMINE/nmdata/dynamfit/archive/'
TitanServerIP = '129.105.90.149' # todo: move this to ENV
SCPSink = 'NANOMINE@'+TitanServerIP+':~/ONR/DynamFit_web/'
ServerDynamfitParent = '/home/NANOMINE/ONR/DynamFit_web/' # on Titan
URLHead = 'http://54.190.30.121/nanomine/Dynamfit/'

# Action sequence:
# 1. check input from POST
# 2. create new working directory and copy source files to it
# 3. run compiled a.out on the input datafile. generate xpr file
#4. ssh to titan server and use matlab to generate plot (todo: change it to python)

def home(request):

    # Handle file upload

    if request.user.is_authenticated():
        # global WorkingDir, timestamp, datafile, weight, std, NumEle, \
        #     mtd, link2result, ApacheCaseDir
        timestamp = strftime('%Y%m%d%H%M%S', localtime())

        f = open('./dynamfit/RunCount.num', 'r+')
        count = f.readlines()
            
        if request.method == 'POST':

            # run model to nuhup
            print 'total count so far is:'
            print count
            f.seek(0)
            newcount = int(count[0]) + 1
            f.write(str(newcount))
            f.close()
            run_id = timestamp + '_' \
                + str(int(count[0]))
            WorkingDir = ParentDir + run_id
                    
            if not os.path.exists(WorkingDir):
                os.makedirs(WorkingDir)
                print '---------------------------Created working folder'

            f = open('./dynamfit/workingdir.str', 'w+')
            f.write(WorkingDir)
            f.close()

            # Copy source code to working dir

            os.system('cp /home/NANOMINE/nmdata/dynamfit/src/* '
                      + WorkingDir)
            os.system('cp ./dynamfit/workingdir.str ' + WorkingDir)
            
            # todo: rename X_T file to upper case
            
            # Create new HTML in apache path to display modeling process
            ApacheCaseDir = '/var/www/html/nanomine/Dynamfit/' \
                + run_id

            if not os.path.exists(ApacheCaseDir):
                os.makedirs(ApacheCaseDir)
                print '----------------Created user case Apache folder'

                # os.system('cp '+WorkingDir+'/*.word '+ ApacheCaseDir)

            form = DocumentForm(request.POST, request.FILES)
            if form.is_valid():
                newdoc = Document(docfile=request.FILES['docfile'])
                newdoc.save()

                        # copy input file to wdir

                cpfile = 'mv ./dynamfit/media/*' + ' ' + WorkingDir
                print cpfile
                os.system(cpfile)
                x_t_name = glob.glob(WorkingDir + '/*.X_T')

                if len(x_t_name) == 1:
                    datafile = x_t_name[0].split('/')[-1].split('.')[0]
                    # record run_id to be looked up with count
                    with open('./dynamfit/run_id_lookup', 'a+') as f:
                        f.write(run_id+','+count[0]+ ','+datafile+'\n')
                
                weight = request.POST['weight']
                std = request.POST['std']
                NumEle = request.POST['NumEle']
                mtd = request.POST['mtd']

                # run model
                call_start = 'python start.py %s %s %s %s %s' \
                    % (datafile, weight, std, NumEle, mtd)
                toPath = 'cd ' + WorkingDir + ';'
                os.system(toPath + call_start)
                
                # copy results to apache folder
                os.system(toPath + 'cp *.XPR '+ApacheCaseDir)
                os.system(toPath + 'cp *.XFF '+ApacheCaseDir)
                os.system(toPath + 'cp *.XTF '+ApacheCaseDir)
                
                # plot results. connect to titan
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.load_system_host_keys()
                ssh.connect(TitanServerIP, username='NANOMINE')
                stdin, stdout, stderr = ssh.exec_command('mkdir '+ServerDynamfitParent+run_id)
                cmd_server_copy_plot_m = 'cp '+ServerDynamfitParent+'matlab_plot_code/*.m '\
                                          + ServerDynamfitParent + run_id

                stdin, stdout, stderr = ssh.exec_command(cmd_server_copy_plot_m)
                
                # send x_t and xpr files to titan server 
                os.system('scp '+ WorkingDir+'/*.X_T '+ SCPSink+run_id+'/')
                os.system('scp '+ WorkingDir+'/*.XPR '+ SCPSink+run_id+'/')
                
                cmd_serve_cd = 'cd '+ServerDynamfitParent+run_id+';'
                call_plot = \
                    'nohup matlab -nosplash -nodisplay -nodesktop -r "cd ' \
                    +ServerDynamfitParent+run_id
                call_plot2 = "; myfun_plot('" + datafile + ".X_T', '" \
                    + datafile + ".XPR', '" + str(NumEle) + "'"
                call_plot3 = ');exit" > ./a.log &'
                print '\n'
                print call_plot + call_plot2 + call_plot3
                stdin, stdout, stderr = ssh.exec_command(cmd_serve_cd+call_plot + call_plot2 + call_plot3)

                time.sleep(20)
                os.system('scp ' + SCPSink+run_id + '/E.jpg '
                          + ApacheCaseDir)
                os.system('scp ' + SCPSink+run_id + '/EE.jpg '
                          + ApacheCaseDir)

            return HttpResponseRedirect(reverse('dynamfit.views.home'))
        else:

            print 'FORM NOT VALID'
            form = DocumentForm()  # A empty, unbound form

        # Load documents for the list page

        documents = Document.objects.all()

        # Render list page with the documents and the form

        return render(request, 'Dynamfit.html', {'form': form, 'run_count': count[0]},
                      context_instance=RequestContext(request))
    else:
        return redirect('/login')

def runmodel(request):
    '''View to check result. todo: change to ajax'''

    if request.user.is_authenticated():
        
        # initialize empty strings
        count = 0
        run_id_found = False
        run_id = ''
        url_XFF = ''
        url_XPR = ''
        url_XTF = ''
        url_img_ep = ''
        url_img_epp = ''
        if len(request.POST) != 0:
            count = request.POST['job_id']
            # assign dummy 0 if no job_id is entered
            try:
                int(count)
            except ValueError:
                count = 0
            with open('./dynamfit/run_id_lookup', 'r') as f:
                table_content = f.readlines()
            for l in table_content:
                tp = l.strip('\n') # tuple of run_id, count
                if int( tp.split(',')[-2] ) == int(count):
                    run_id = str(tp.split(',')[0])
                    datafile = str(tp.split(',')[-1])
                    URLCaseHead = URLHead + run_id
                    run_id_found = True
                    break
                # no match found
                run_id = 'not found'
            del table_content
            
            if run_id_found:
                # get img url
                url_img_ep = URLCaseHead+'/E.jpg'
                url_img_epp = URLCaseHead+'/EE.jpg'
                url_XPR = URLCaseHead+'/'+datafile+'.XPR'
                url_XTF = URLCaseHead+'/'+datafile+'.XTF'
                url_XFF = URLCaseHead+'/'+datafile+'.XFF'
            
            print url_img_ep, url_img_epp, url_XPR
            
        return render_to_response('DynamfitRun.html', {
                        'E_link': url_img_ep,
            'EE_link': url_img_epp,
            'XFF_link': url_XFF,
            'XPR_link': url_XPR,
            'XTF_link': url_XTF,
            'job_id_num': run_id,
            'job_found': run_id_found
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')


def sample(request):
    if request.user.is_authenticated():
        return render_to_response('DynamfitExample.html', locals(),
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def sampleinput(request):
    if request.user.is_authenticated():
        global examplelink2result
        if request.method == 'POST':

            # Link of Apache page

            examplelink2result = \
                'http://nanomine.northwestern.edu/nanomine/Dynamfit/'

            if len(request.POST) != 0:
                exampleweight = request.POST['weight']
                examplestd = request.POST['std']
                exampleNumEle = request.POST['NumEle']
                examplemtd = request.POST['mtd']

                # run model

                call_start = 'python start.py EXAMPLE %s %s %s %s' \
                    % (exampleweight, examplestd, exampleNumEle,
                       examplemtd)
                toPath = \
                    'cd /home/NANOMINE/Develop/mdcs/Dynamfit/example;'
                os.system(toPath + call_start)

                # time.sleep(3)

                call_plot = \
                    'nohup matlab -nosplash -nodisplay -nodesktop -r "cd /home/NANOMINE/Develop/mdcs/Dynamfit/example'
                call_plot2 = "; myfun_plot('EXAMPLE.XPR', '" \
                    + str(exampleNumEle) + "'"
                call_plot3 = ');exit" > ./a.log &'
                print '\n'
                print call_plot + call_plot2 + call_plot3
                os.system(toPath + call_plot + call_plot2 + call_plot3)

                time.sleep(15)
                if os.path.isfile('/var/www/html/nanomine/Dynamfit/exampleE.jpg'
                                  ):
                    os.system('rm /var/www/html/nanomine/Dynamfit/exampleE.jpg'
                              )
                if os.path.isfile('/var/www/html/nanomine/Dynamfit/exampleEE.jpg'
                                  ):
                    os.system('rm /var/www/html/nanomine/Dynamfit/exampleEE.jpg'
                              )
                os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleE.jpg /var/www/html/nanomine/Dynamfit'
                          )
                os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleEE.jpg /var/www/html/nanomine/Dynamfit'
                          )
                os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XPR /var/www/html/nanomine/Dynamfit'
                          )
                os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XFF /var/www/html/nanomine/Dynamfit'
                          )
                os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XTF /var/www/html/nanomine/Dynamfit'
                          )

                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XFF')
                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XPR')
                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XTF')
                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleE.jpg')
                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleEE.jpg')
                # os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/a.log')

                # os.system('cp '+WorkingDir+'/*.XFF '+ ApacheCaseDir)
                # os.system('cp '+WorkingDir+'/*.XPR '+ ApacheCaseDir)
                # os.system('cp '+WorkingDir+'/*.XTF '+ ApacheCaseDir)

            return HttpResponseRedirect(reverse('dynamfit.views.sampleinput'
                    ))
        else:

            print 'NOT VALID'

        # Render list page with the documents and the form

        return render_to_response('DynamfitExampleInput.html',
                                  locals(),
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def samplerun(request):
    if request.user.is_authenticated():
        Eprime = \
            'http://nanomine.northwestern.edu/nanomine/Dynamfit/exampleE.jpg'
        EEprime = \
            'http://nanomine.northwestern.edu/nanomine/Dynamfit/exampleEE.jpg'
        XPR_link = \
            'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XPR'
        XFF_link = \
            'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XFF'
        XTF_link = \
            'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XTF'

        return render_to_response('DynamfitExampleRun.html', {
            'E_link': Eprime,
            'EE_link': EEprime,
            'XPR_link': XPR_link,
            'XFF_link': XFF_link,
            'XTF_link': XTF_link,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')



			