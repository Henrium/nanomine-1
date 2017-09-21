#!/usr/bin/python
# -*- coding: utf-8 -*-
from django.shortcuts import render, render_to_response, \
    RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse

import os
import random
import getpass

from time import localtime, strftime
from operator import itemgetter

import time
import math
import numpy as np
import random

import paramiko

kB = 1.38e-23  # m2 kg s-2 K-1, Boltzman, seen here as JK-1
T = 298  # K
h_p = 6.626e-34  # m2kg s-1, Plank

LocalParentDir = '/home/NANOMINE/nmdata/dielec2d/archive/'
ServerParentDir = '/home/NANOMINE/ONR/dielec2d_web/archive/'
ServerSrc = '/home/NANOMINE/ONR/dielec2d_web/code/'
HttpDir = '/var/www/html/nanomine/DielectricFEA2D/' # on titan
TitanServerIP = '129.105.90.149'
SCPSink = 'NANOMINE@'+TitanServerIP+':~/ONR/dielec2d_web/archive/'

def home(request):
    if request.user.is_authenticated():
        timestamp = strftime('%Y%m%d%H%M%S', localtime())
        
        if len(request.POST) != 0:
            global run_id   # pass on run_id to the validate view in the same session. any better way than global var?
            
            # update run count
            f = open('./dielec2d/RunCount.num', 'r+')
            count = f.readlines()
            print 'total count so far is:'
            print count
            f.seek(0)
            newcount = int(count[0]) + 1
            f.write(str(newcount))
            f.close
        
            # generate unique run_id
            run_id = timestamp+'_'+ str(int(count[0]))
            # record run_id to be looked up with count
            with open('./dielec2d/run_id_lookup', 'a+') as f:
                f.write(run_id+','+count[0]+ '\n')
            print 'run_id:', run_id
            
            # local data folder
            LocalDataDir = LocalParentDir+run_id
            os.system('mkdir '+LocalDataDir) # local data folder
                    
            # write names to file     
            polymer = request.POST['polymer']
            particle = request.POST['particle']
            graft = request.POST['graft']
            vf = request.POST['vf']
            ipthick = request.POST['ipthick']
            with open(LocalDataDir+'/polymer.runconfig', 'w+') as f:
                f.write(polymer)
            with open(LocalDataDir+'/particle.runconfig', 'w+') as f:
                f.write(particle)
            with open(LocalDataDir+'/graft.runconfig', 'w+') as f:
                f.write(graft)
            with open(LocalDataDir+'/vf.runconfig', 'w+') as f:
                f.write(polymer)
            with open(LocalDataDir+'/ipthick.runconfig', 'w+') as f:
                f.write(ipthick)
                    
            # Get values and compute energy from web page input
            if request.POST['method'] == 'one':
                # write method to file
                with open(LocalDataDir+'/FEAmethod.runconfig', 'w+') as f:
                    f.write('1')
                
            elif request.POST['method'] == 'two':

                eps_shortbrush = request.POST['eps_shortbrush']
                n_shortbrush = request.POST['n_shortbrush']
                v_shortbrush = request.POST['v_shortbrush']
                eps_funcG = request.POST['eps_funcG']
                n_funcG = request.POST['n_funcG']
                v_funcG = request.POST['v_funcG']
                n_p = request.POST['n_p']
                Rg = request.POST['Rg']
                b = request.POST['b']
                N = request.POST['N']
                a = request.POST['a']
                eps_particle = request.POST['eps_particle']
                n_particle = request.POST['n_particle']
                R = request.POST['R']
                eps_poly = request.POST['eps_poly']
                n_poly = request.POST['n_poly']
                P = request.POST['P']
                d = request.POST['d']

                eps_graft = mix_eps(float(eps_shortbrush),
                                    float(v_shortbrush),
                                    float(eps_funcG), float(v_funcG))
                n_graft = mix_n(float(n_shortbrush),
                                float(v_shortbrush), float(n_funcG),
                                float(v_funcG))
                Hamaker_Polymer = HamakerConst(float(eps_poly),
                        float(n_poly))
                Hamaker_graft = HamakerConst(eps_graft, n_graft)
                Hamaker_Particle = HamakerConst(float(eps_particle),
                        float(n_particle))

                chi = Chi(
                    Hamaker_Polymer,
                    Hamaker_graft,
                    Hamaker_Particle,
                    float(R),
                    float(d),
                    float(Rg),
                    )
                chi_bare = Chi_bare(Hamaker_Polymer, Hamaker_Particle,
                                    float(R), float(d))

                sigma_DC = Sigma_DorC(float(n_p), float(R))  # Just sigma
                sigma_H = Sigma_H(float(n_p), float(R))

                h_i_DC = h_i(float(N), float(a), float(sigma_DC),
                             float(P))
                h_i_H = h_i(float(N), float(a), float(sigma_H),
                            float(P))

                phi_DC = Phi_i(h_i_DC, sigma_DC, float(N), float(a),
                               float(d))
                phi_H = Phi_i(h_i_H, sigma_H, float(N), float(a),
                              float(d))

                F_D_flat = phi_DC  # only in per unit area, in this case, and the unit is in KB*T
                F_C_flat = phi_DC
                F_H_flat = phi_H
                F_A_flat = func_F_A_flat(float(a), float(N), float(R),
                        float(n_p), float(P))

                F_D = func_F_D(F_D_flat, float(R), h_i_DC)
                F_C = func_F_C(F_C_flat, float(R), h_i_DC)
                F_H = func_F_H(F_H_flat)
                F_A = func_FA(F_A_flat, float(b))

                FD = F_D + Chi_i(0, chi, float(b))
                FC = F_C + Chi_i(1, chi, float(b))
                FA = F_A + Chi_i(6, chi, float(b))
                FH = F_H + Chi_i(3, chi, float(b))

                with open(LocalDataDir+'/FEAmethod.runconfig', 'w+') as f:
                    f.write('2')
                    
                with open(LocalDataDir+'/FD.runconfig', 'w+') as f:
                    f.write(str(FD))
                with open(LocalDataDir+'/FC.runconfig', 'w+') as f:
                    f.write(str(FC))
                with open(LocalDataDir+'/FA.runconfig', 'w+') as f:
                    f.write(str(FA))
                with open(LocalDataDir+'/FH.runconfig', 'w+') as f:
                    f.write(str(FH))
            print 'POST model method:', request.POST['method']
            
        return render_to_response('DielectricFEA2D.html', locals(),
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def validate(request):
    '''Validate input params from main tool page before running'''
    
    if request.user.is_authenticated():
        global run_id
        
        if len(request.POST) > 0:
            print request.POST['method']
            print request.POST['polymer']
            print request.POST['vf']
            
        if 'run_id' in globals():
            LocalDataDir = LocalParentDir+run_id
            with open(LocalDataDir+'/FEAmethod.runconfig', 'r') as f:
                METHOD = f.read()
            print 'run_id:', run_id
            print 'method:', METHOD
            
            # init empty strings
            phase = ''  # dummy for method one
            IMGFILE = ''
            TEMIMGFILE = ''
            STRUCTIMGFILE = ''
            BINIMGFILE=''
        else:
            # return to configs input page
            return redirect('/dielec2d')
            # return render_to_response('DielectricFEA2D.html', locals(),
                                  # context_instance=RequestContext(request))
        
        # read params from file
        params = {}
        with open(LocalDataDir+'/polymer.runconfig', 'r') as f:
            polymer = f.read()
        with open(LocalDataDir+'/particle.runconfig', 'r') as f:
            particle= f.read()
        with open(LocalDataDir+'/graft.runconfig', 'r') as f:
            graft= f.read()
        with open(LocalDataDir+'/vf.runconfig', 'r') as f:
            vf= f.read()
        with open(LocalDataDir+'/ipthick.runconfig', 'r') as f:
            ipthick= f.read()
        
        params['Polymer'] = polymer
        params['Particle'] = particle
        params['Volume Fraction'] = vf
        
        if METHOD == '1':
            params['Surface Treatment'] = graft
            params['Interphase Thickness(nm)'] = ipthick
    
            if graft == 'bare':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_BS_1wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_1BAREsilica-min.jpg'
                STRUCTIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/structure-bare.jpg'
            elif graft == 'monoPGMA':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_PGMA_2wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_2silica_PGMA_4-min.jpg'
                STRUCTIMGFILE = ''
            elif graft == 'ferroPGMA':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_ferroPGMA_2wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_2ferroPGMAsilica-min.jpg'
                STRUCTIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/structure-ferro.jpg'
            elif graft == 'terthiophenePGMA':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_terthiophenePGMA_2wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_terthiophene2_005-min.jpg'
                STRUCTIMGFILE = ''
            elif graft == 'monothiophenePGMA':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_monothiophenePGMA_2wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_monothiophene_3-min.jpg'
                STRUCTIMGFILE = ''
            elif graft == 'anthraenePGMA':
                BINIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_anthracenePGMA_2wt.jpg'
                TEMIMGFILE = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_anthracene_3-min.jpg'
                STRUCTIMGFILE = ''


        elif METHOD == '2':
            with open(LocalDataDir+'/FD.runconfig', 'r') as f:
                FD = float(f.read())
            with open(LocalDataDir+'/FC.runconfig', 'r') as f:
                FC = float(f.read())
            with open(LocalDataDir+'/FA.runconfig', 'r') as f:
                FA = float(f.read())
            with open(LocalDataDir+'/FH.runconfig', 'r') as f:
                FH = float(f.read())
            params = {}       
            params['Dispersed (D) '] = '%.2f' % round(FD, 2)
            params['String-like (C)'] = '%.2f' % round(FC, 2)
            params['Sheet-like (H)'] = '%.2f' % round(FH, 2)
            params['Aggregated (A)'] = '%.2f' % round(FA, 2)

                # Find the phase corresponding to minimum energy
             # Index value - 0: D, dispersed, 1: C, string, 2: H, sheet, 3: A, agglomerated
            Flist = [FD, FC, FH, FA]
            PHASE = min(enumerate(Flist), key=itemgetter(1))[0] 

            if PHASE == 0:
                # Dispersed. Generate descriptors rc, rd
                rd = 131.7 * math.exp(-2.709 * vf) + 48.64 \
                    * math.exp(-0.0318 * vf)
                rc = np.random.normal(10, 2, 1)[0]
                phase = 'well dispersed'
            elif PHASE == 1:
                        # String like
                rd = -4.22 * vf + 77.374
                rc = np.random.normal(30, 5, 1)[0]
                phase = 'string-like'
            elif PHASE == 2:
                        # Unassigned values
                rd = 50
                rc = 20
                phase = 'sheet-like'
            elif PHASE == 3:
                        # Unassigned values
                rd = 100
                rc = 20
                phase = 'agglomerated'
            with open(LocalDataDir+'/rc.runconfig', 'w+') as f:
                f.write(str(rc))
            with open(LocalDataDir+'/rd.runconfig', 'w+') as f:
                f.write(str(rd))  

        return render_to_response('DielectricFEA2DValidateInput.html', {
            'params': sorted(params.iteritems()),
            'method': METHOD,
            'binimg': BINIMGFILE,
            'temimg': TEMIMGFILE,
            'structimg': STRUCTIMGFILE,
            'phase': phase,
            'run_id': run_id,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')


def runmodel(request):
    '''Views to run the configured model.'''
    if request.user.is_authenticated():
        # Action to run 
        global run_id
        
        # find run_id from current session
        if 'run_id' in globals():
            LocalDataDir = LocalParentDir+run_id
            with open(LocalDataDir+'/FEAmethod.runconfig', 'r') as f:
                METHOD = f.read()
            print 'run_id:', run_id
            print 'method:', METHOD

        # ran = 5 * random.random()
        # time.sleep(ran)
        
        f = open('./dielec2d/PortCount.num', 'r+')
        PORT = int(f.readlines()[0])
        print 'using port:'
        print PORT
        f.seek(0)
        if PORT == 2300:
            f.write(str(2200))
        else:
            newport = PORT + 1
            f.write(str(newport))
        f.close

        # connec to server
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.load_system_host_keys()
        ssh.connect(TitanServerIP, username='NANOMINE')
                
        # ssh: copy source code to working dir
        stdin, stdout, stderr = ssh.exec_command('mkdir '+ServerParentDir+run_id)
        stdin, stdout, stderr = ssh.exec_command('cp -r '+ServerSrc+'* '+ServerParentDir+run_id+'/')
        # copy local configs to server
        os.system('scp '+LocalDataDir+'/* '+SCPSink+run_id)
        
        # Create new HTML in apache path to display modeling progress
        ApacheCaseDir = HttpDir + run_id
        stdin, stdout, stderr = ssh.exec_command('mkdir '+ApacheCaseDir)
        
        # # Link of Apache page
        # link2result = \
        #     'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/' \
        #     + timestamp + '_' + str(int(count[0]))

        IN_QUEUE = False  # Default not put in queue - assign a port from 2044 - 2048

        if not IN_QUEUE:  # Run model if a port can be assigned
            # read config files 
            with open(LocalDataDir+'/polymer.runconfig', 'r') as f:
                polymer = f.read()
            with open(LocalDataDir+'/particle.runconfig', 'r') as f:
                particle= f.read()
            with open(LocalDataDir+'/graft.runconfig', 'r') as f:
                graft= f.read()
            with open(LocalDataDir+'/vf.runconfig', 'r') as f:
                vf= f.read()
            with open(LocalDataDir+'/ipthick.runconfig', 'r') as f:
                ipthick= f.read()
                
            if METHOD == '1':  
                # start comsol server with a port
                str_OpenPort = '/usr/local/bin/comsol server -port ' \
                    + str(PORT) + ' &'
                print 'remote command opening COMSOl port: ', str_OpenPort
                
                # MATLAB commands to add path and connect to port
                str_PATH = \
                    "addpath('/usr/local/comsol52/multiphysics/mli', '/usr/local/comsol52/multiphysics/mli/startup');"
                str_PathPort = str_PATH + 'mphstart(' + str(PORT) + ');'

                str_matlab_run_model = \
                    'nohup matlab -nodesktop -nosplash -nodisplay -r "cd ' \
                    + ServerParentDir+run_id + ';' + str_PathPort + ' runmain(1,' \
                    + str(PORT) + ');exit" > ~/ONR/dielec2d/log/MATLABRUN_' \
                    + run_id + '.log &'
                print 'Run MATLAB shell command:'
                print str_matlab_run_model
                
                # ssh: run commands
                stdin, stdout, stderr = ssh.exec_command(str_OpenPort)
                stdin, stdout, stderr = ssh.exec_command(str_matlab_run_model)  # PORT changed back to 'on' in MATLAB code
                
            elif METHOD == '2':

                # read model configs
                with open(LocalDataDir+'/FD.runconfig', 'r') as f:
                    FD = float(f.read())
                with open(LocalDataDir+'/FC.runconfig', 'r') as f:
                    FC = float(f.read())
                with open(LocalDataDir+'/FA.runconfig', 'r') as f:
                    FA = float(f.read())
                with open(LocalDataDir+'/FH.runconfig', 'r') as f:
                    FH = float(f.read())
                
                SideL = 1000
                ClusterNo = math.ceil(float(vf) * float(SideL) ** 2
                        / (3.1416 * float(rc) ** 2))
                ssh_recon = \
                    'nohup matlab -nodesktop -nosplash -nodisplay -r "cd ' \
                    + ServerParentDir+run_id + ';descriptor_recon_smooth(' \
                    + str(SideL) + ',' + vf + ',' + str(ClusterNo) \
                    + ',' + str(rd) \
                    + ',1);exit" > ~/ONR/dielec2d/log/RECON2DRUN_' + run_id + '.log &'
                print 'Run recom script shell command:'
                print ssh_recon
                
                # ssh: run command
                stdin, stdout, stderr = ssh.exec_command(ssh_recon)

                ssh_run_method_2 = \
                    'nohup matlab -nodesktop -nosplash -nodisplay -r "cd ' \
                    + ServerParentDir+run_id + ';trigger2(' + str(PORT) \
                    + ');exit" > ./FEA2D/log/MATLABRUN_' + run_id + '.log &'
                print 'Run MATLAB shell command:'
                print ssh_run_method_2
                
                # ssh: run command
                stdin, stdout, stderr = ssh.exec_command(ssh_run_method_2)
        else:

            return render_to_response('DielectricFEA2DBusy.html',
                    locals(), context_instance=RequestContext(request))

        return render_to_response('DielectricFEA2DRun.html',
                                  {
                                  'jobid': run_id},
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')

def check(request):
    if request.user.is_authenticated():

        # job progress checker. default job ID taken from current view.

        # Standalone view. NO GLOBAL VARIABLE SHOULD BE USED HERE!

        FINISH = 0
        polymer_read = ''
        particle_read = ''
        graft_read = ''
        vf_read = ''
        ip_read = ''
        image_read = ''
        material_read = ''
        model_read = ''
        mesh_read = ''
        physics_read = ''
        study_read = ''
        structure_read = ''
        solution_read = ''
        finish_read = ''

        try:
            JOBID
        except NameError:
            defaultJobID = ''
        else:
            defaultJobID = JOBID

        GEOM = ''
        EP_IMG = ''
        EPP_IMG = ''
        EP_LINK = ''
        EPP_LINK = ''

        if len(request.POST) != 0:  # when there is actual input
            jobID = request.POST['job_ID']
            defaultJobID = jobID

            WORKDING_DIR = ParentDir + str(jobID)
            ApacheCaseDir = '/var/www/html/nanomine/DielectricFEA2D/' \
                + str(jobID)

            POLYMER_FILE = WORKDING_DIR + '/polymer.word'
            if os.path.exists(POLYMER_FILE):
                f = open(POLYMER_FILE, 'r')
                polymer_read = f.read()
                f.close
            PARTICLE_FILE = WORKDING_DIR + '/particle.word'
            if os.path.exists(PARTICLE_FILE):
                f = open(PARTICLE_FILE, 'r')
                particle_read = f.read()
                f.close
            GRAFT_FILE = WORKDING_DIR + '/graft.word'
            if os.path.exists(GRAFT_FILE):
                f = open(GRAFT_FILE, 'r')
                graft_read = f.read()
                f.close
            VF_FILE = WORKDING_DIR + '/vf.word'
            list1 = {}
            if os.path.exists(VF_FILE):
                f = open(VF_FILE, 'r')
                vf_read = f.read()
                f.close

            IP_FILE = WORKDING_DIR + '/ipthick.word'
            if os.path.exists(IP_FILE):
                f = open(IP_FILE, 'r')
                ip_read = f.read()
                f.close

                # Status flags

            if os.path.exists(WORKDING_DIR + '/load_image.status'):
                f = open(WORKDING_DIR + '/load_image.status', 'r')
                image_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_material.status'):
                f = open(WORKDING_DIR + '/create_material.status', 'r')
                material_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_model.status'):
                f = open(WORKDING_DIR + '/create_model.status', 'r')
                model_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_mesh.status'):
                f = open(WORKDING_DIR + '/create_mesh.status', 'r')
                mesh_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_physics.status'):
                f = open(WORKDING_DIR + '/create_physics.status', 'r')
                physics_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_study.status'):
                f = open(WORKDING_DIR + '/create_study.status', 'r')
                study_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_structure.status'
                              ):
                f = open(WORKDING_DIR + '/create_structure.status', 'r')
                structure_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/create_solution.status'):
                f = open(WORKDING_DIR + '/create_solution.status', 'r')
                solution_read = f.read()
                f.close
            if os.path.exists(WORKDING_DIR + '/job_finish.status'):
                f = open(WORKDING_DIR + '/job_finish.status', 'r')
                finish_read = f.read()
                f.close

                FINISH = 1

                # Display results if job is finished

            if FINISH == 1:
                os.system('cp ' + WORKDING_DIR + '/*.jpg '
                          + ApacheCaseDir)
                os.system('cp ' + WORKDING_DIR + '/*.csv '
                          + ApacheCaseDir)
                HTTPROOT = \
                    'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/' \
                    + str(jobID)
                GEOM = HTTPROOT + '/microstructure.jpg'
                EP_IMG = HTTPROOT + '/epsilon_real.jpg'
                EPP_IMG = HTTPROOT + '/epsilon_imag.jpg'
                EPP_LINK = HTTPROOT + '/CompPermImag.csv'
                EP_LINK = HTTPROOT + '/eCompPermReal.csv'

        return render_to_response('DielectricFEA2DCheckProgress.html', {
            'finish': FINISH,
            'defaultID': defaultJobID,
            'w1': polymer_read,
            'w2': particle_read,
            'w3': graft_read,
            'w4': vf_read,
            'w5': ip_read,
            's1': image_read,
            's2': material_read,
            's3': model_read,
            's4': mesh_read,
            's5': physics_read,
            's6': study_read,
            's7': structure_read,
            's8': solution_read,
            's9': finish_read,
            'geom': GEOM,
            'ep': EP_IMG,
            'epp': EPP_IMG,
            'ep_link': EP_LINK,
            'epp_link': EPP_LINK,
            }, context_instance=RequestContext(request))
    else:
        return redirect('/login')


def result(request):
    if request.user.is_authenticated():
        return render_to_response('DielectricFEA2DResult.html',
                                  locals(),
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


def sample(request):
    if request.user.is_authenticated():
        return render_to_response('DielectricFEA2DResultSample.html',
                                  locals(),
                                  context_instance=RequestContext(request))
    else:
        return redirect('/login')


### Below are not directly used in Django functions.=========================================

# Energy.py

def HamakerConst(eps_i, n_i):
    global kB, T, h_p
    ve = 3e15  # Hz
    A_i = 3.0 / 4 * kB * T * ((eps_i - 1) / (eps_i + 1)) ** 2 + 3 * h_p \
        * ve / 16 / np.sqrt(2) * (n_i ** 2 - 1) ** 2 / (n_i ** 2 + 1) \
        ** (3.0 / 2)
    return A_i


def Chi(
    Hamaker_Polymer,
    Hamaker_graft,
    Hamaker_Particle,
    R,
    h,
    L,
    ):

      # chi is the enthalpy for
      # h is the particle-particle outer surface distance, use 0.165nm in the literature
      # L is the thickness of the hybrid layer
      # R is the particle radius
      # This value only valid when d-2L<<R

    # global kB, T
    chi = -R / 12.0 * ((np.sqrt(Hamaker_Polymer)
                       - np.sqrt(Hamaker_graft)) ** 2 / h
                       + (np.sqrt(Hamaker_graft)
                       - np.sqrt(Hamaker_Particle)) ** 2 / (h + 2 * L)
                       + (np.sqrt(Hamaker_Polymer)
                       - np.sqrt(Hamaker_graft))
                       * (np.sqrt(Hamaker_graft)
                       - np.sqrt(Hamaker_Particle)) / (h + L))
    return chi / kB / T


def Chi_bare(
    Hamaker_Polymer,
    Hamaker_Particle,
    R,
    h,
    ):
    chi_bare = -R / 12.0 / h * (np.sqrt(Hamaker_Polymer)
                                - np.sqrt(Hamaker_Particle)) ** 2
    return chi_bare / kB / T


def mix_eps(
    eps_shortbrush,
    v_shortbrush,
    eps_funcG,
    v_funcG,
    ):
    return np.exp(v_shortbrush * np.log(eps_shortbrush) + v_funcG
                  * np.log(eps_funcG))


def mix_n(
    n_shortbrush,
    v_shortbrush,
    n_funcG,
    v_funcG,
    ):
    return v_shortbrush * n_shortbrush + v_funcG * n_funcG


# For entropy

def func_F_D(F_D_flat, R, h_i):
    f_d = F_D_flat * 3 * R / 5 / h_i * np.log(1 + 5 * h_i / 3 / R)
    return f_d


def func_F_C(F_C_flat, R, h_i):
    f_c = F_C_flat * 2 * R / h_i * ((1 + 4 * h_i / 3 / R) ** (3.0
                                    / 8.0) - 1)
    return f_c


def func_F_H(F_H_flat):
    f_h = 2 * F_H_flat
    return f_h


def Sigma_DorC(n_p, R):

      # n_p is number of the grafted brush

    return n_p / 4 / np.pi / R / R


def Sigma_H(n_p, R):
    return n_p / 3 / np.sqrt(3) / R / R


def h_i(
    N,
    a,
    sigma,
    P,
    ):

      # N is the polymerization of the short brush
      # a is the monomer size
      # sigma is the graft density of the short brush

    return N * a ** (5.0 / 3) * sigma ** (1.0 / 3) * P ** (-1.0 / 3)


def Phi_i(
    h_i,
    sigma,
    N,
    a,
    d,
    ):

      # is to compute the free energy per unit area

    phi_i = np.pi ** 2 / 24 * h_i ** 2 * sigma / N / a ** 2 * (2 * h_i
            / d + 2 * (d / 2 / h_i) ** 2 - 1 / 5.0 * (d / 2 / h_i) ** 5
            - 9 / 5.0)
    return phi_i


def func_F_A_flat(
    a,
    N,
    R,
    n_p,
    P,
    ):
    f_a_flat = a ** 2 * N / R ** 2 + a ** 3 * n_p * N ** 2 / (R ** 3
            * P) * n_p
    return f_a_flat


def func_FA(f_a_flat, b):
    return f_a_flat / (np.pi * (b / 2) ** 2)


def Chi_i(alpha, chi, b):
    return alpha * chi / np.pi / (b / 2) ** 2



			