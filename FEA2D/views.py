from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass

from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np
import random

kB = 1.38e-23 #m2 kg s-2 K-1, Boltzman, seen here as JK-1
T=298 #K
h_p = 6.626e-34 #m2kg s-1, Plank

ParentDir = '/home/NANOMINE/ONR/web/'

# Create your views here.
def home(request):
	if request.user.is_authenticated():
		# main page to get materials and microstructure input 
		global METHOD, WorkingDir, timestamp
		timestamp = strftime("%Y%m%d%H%M%S", gmtime())
		# Get values and compute energy from web page input
		if len(request.POST) != 0: # when there is actual inputs
		        print 'length of return POST dict is:'
		        print len(request.POST)

		        global polymer, particle, graft, vf, ipthick
		        METHOD = 'one'
		        # Method one
		        polymer = request.POST['polymer']
		        particle = request.POST['particle']
		        graft = request.POST['graft']
		        vf = request.POST['vf']
		        ipthick = request.POST['ipthick']
		                
		        if request.POST['method'] == 'two':
		                global FD,FC,FH,FA
		                METHOD = 'two' 
		                # Method two
		                eps_shortbrush =  request.POST['eps_shortbrush']
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
		                n_poly =request.POST['n_poly']
		                P = request.POST['P']              
		                d = request.POST['d']
		                
		                eps_graft=mix_eps(float(eps_shortbrush), float(v_shortbrush),  float(eps_funcG), float(v_funcG))
		                n_graft = mix_n(float(n_shortbrush), float(v_shortbrush), float(n_funcG), float(v_funcG))
		                Hamaker_Polymer = HamakerConst(float(eps_poly),float(n_poly))
		                Hamaker_graft = HamakerConst(eps_graft, n_graft)
		                Hamaker_Particle = HamakerConst(float(eps_particle), float(n_particle))
		                
		                chi = Chi(Hamaker_Polymer, Hamaker_graft, Hamaker_Particle, float(R), float(d), float(Rg))
		                chi_bare = Chi_bare(Hamaker_Polymer, Hamaker_Particle, float(R), float(d))
		                
		                sigma_DC = Sigma_DorC(float(n_p),float(R)) #Just sigma
		                sigma_H = Sigma_H(float(n_p),float(R))
		                
		                h_i_DC=h_i(float(N),float(a),float(sigma_DC),float(P))
		                h_i_H =h_i(float(N),float(a),float(sigma_H),float(P))
		                
		                phi_DC = Phi_i(h_i_DC, sigma_DC, float(N), float(a), float(d))
		                phi_H = Phi_i(h_i_H, sigma_H, float(N), float(a), float(d))
		                
		                F_D_flat = phi_DC #only in per unit area, in this case, and the unit is in KB*T
		                F_C_flat = phi_DC
		                F_H_flat = phi_H
		                F_A_flat = func_F_A_flat(float(a),float(N),float(R), float(n_p), float(P))
		                
		                F_D=func_F_D(F_D_flat,float(R),h_i_DC)
		                F_C=func_F_C(F_C_flat,float(R),h_i_DC)
		                F_H=func_F_H(F_H_flat)
		                F_A = func_FA(F_A_flat, float(b))
		                
		                FD = F_D+(Chi_i(0,chi,float(b)))
		                FC = F_C+(Chi_i(1,chi,float(b)))
		                FA = F_A+(Chi_i(6,chi,float(b)))
		                FH = F_H+(Chi_i(3,chi,float(b)))                    
		                
		return render_to_response("DielectricFEA2D.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')

def validate(request):
        if request.user.is_authenticated():
		# validate input parameter. for option two, generate microstructure if needed
		
		# Default method one
		out1={}
		out2={}
		phase = '' # dummy for method one
		
		out1['Polymer'] = polymer
		out1['Particle'] = particle
		out1['Surface Treatment'] = graft
		out1['Volume Fraction'] = vf
		out1['Interphase Thickness(nm)'] = ipthick              
		
		if graft == 'bare':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_BS_1wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_1BAREsilica-min.jpg'
		        STRUCTIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/structure-bare.jpg'
		elif graft == 'monoPGMA':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_PGMA_2wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_2silica_PGMA_4-min.jpg'
		        STRUCTIMGFILE = ''
		elif graft == 'ferroPGMA':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_ferroPGMA_2wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_2ferroPGMAsilica-min.jpg'
		        STRUCTIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/structure-ferro.jpg'
		elif graft == 'terthiophenePGMA':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_terthiophenePGMA_2wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_terthiophene2_005-min.jpg'
		        STRUCTIMGFILE = ''
		elif graft == 'monothiophenePGMA':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_monothiophenePGMA_2wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_monothiophene_3-min.jpg'
		        STRUCTIMGFILE = ''
		elif graft == 'anthraenePGMA':
		        BINIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/crop_anthracenePGMA_2wt.jpg'
		        TEMIMGFILE = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/TEM_anthracene_3-min.jpg'
		        STRUCTIMGFILE = ''
		else:
		        IMGFILE = ''
		        TEMIMGFILE = ''
		        STRUCTIMGFILE = ''
		        
		if METHOD == 'two':
		        global rc, rd
		        
		        #out2[' Results']='Free Energy for Each Dispersion Phase'
		        out2['Dispersed (D) '] = "%.2f" % round(FD,2)
		        out2['String-like (C)'] = "%.2f" % round(FC,2)
		        out2['Sheet-like (H)'] = "%.2f" % round(FH,2)
		        out2['Aggregated (A)'] =  "%.2f" % round(FA,2)          
		        
		        # Find the phase corresponding to minimum energy
		        Flist = [FD, FC, FH, FA]
		        PHASE = min(enumerate(Flist), key=itemgetter(1))[0]  # Index value - 0: D, dispersed, 1: C, string, 2: H, sheet, 3: A, agglomerated
		        
		        # Get descriptors 
		        if PHASE == 0:
		                # Dispersed. Generate descriptors rc, rd
		                rd = 131.7*math.exp(-2.709*vf)+48.64*math.exp(-0.0318*vf)
		                rc = np.random.normal(10, 2, 1)[0]
		                phase = 'well dispersed'
		        elif PHASE == 1:
		                # String like
		                rd = -4.22*vf+77.374
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
		        print 'rc is: '
		        print rc
		        print 'rd is:'
		        print rd
		        
		return render_to_response("DielectricFEA2DValidateInput.html",
		                          {'data1': sorted(out1.iteritems()),
		                           'data2': sorted(out2.iteritems()),
		                           'method':METHOD,
		                           'binimg':BINIMGFILE,
		                           'temimg':TEMIMGFILE,
		                           'structimg':STRUCTIMGFILE,
		                           'phase':phase},
		                          context_instance=RequestContext(request))
		                        #{'vf':vfFlag, 'ipthick':ipthickFlag, 'polymer':polymerFlag,'particle':particleFlag,'graft':graftFlag},
	else:
		return redirect('/login')

def runmodel(request):
	if request.user.is_authenticated():    
		# run model to nohup
		
		# Update current count of total simulation run
		global JOBID, IN_QUEUE
		
		ran = 5 * random.random()
		time.sleep(ran)

		f = open('./FEA2D/RunCount.num', 'r+')
		count = f.readlines()
		print 'total count so far is:'
		print count
		f.seek(0)
		newcount = int(count[0]) + 1
		f.write(str(newcount))
		f.close

		f = open('./FEA2D/PortCount.num', 'r+')
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
		                
		# Proceed to create new dir for this user case if inputs are validated
		WorkingDir = ParentDir+timestamp+'_'+str(int(count[0]))
		JOBID = timestamp+'_'+str(int(count[0]))
		if not os.path.exists(WorkingDir):
		        os.makedirs(WorkingDir)
		        print '------------------Created working folder'
		f = open('./FEA2D/workingdir.str', 'w+')
		f.write(WorkingDir)
		f.close()
		
		# Copy source code to working dir
		os.system('cp /home/NANOMINE/ONR/web/code/* '+WorkingDir)
		os.system('cp ./FEA2D/workingdir.str '+WorkingDir)
		
		# Save input parameters to file
		f = open(WorkingDir+'/polymer.word', 'w+')
		f.write(polymer)
		f.close()
		f = open(WorkingDir+'/particle.word', 'w+')
		f.write(particle)
		f.close()
		f = open(WorkingDir+'/graft.word', 'w+')
		f.write(graft)
		f.close()
		f = open(WorkingDir+'/vf.word', 'w+')
		f.write(vf)
		f.close()
		f = open(WorkingDir+'/ipthick.word', 'w+')
		f.write(ipthick)
		f.close()


		#####################################
		#f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'a')
		#f.write(JOBID+'\n')
		#f.close()	
                #####################################		        

		# Create new HTML in apache path to display modeling progress
		ApacheCaseDir = '/var/www/html/nanomine/DielectricFEA2D/'+timestamp+'_'+str(int(count[0]))
		
		# Link of Apache page
		link2result = 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/'+timestamp+'_'+str(int(count[0]))
		if not os.path.exists(ApacheCaseDir):
		        os.makedirs(ApacheCaseDir)
		        print '------------------Created user case Apache folder'
		        #os.system('cp ./FEA2DResult.html '+ApacheCaseDir+'/index.html')
		        os.system('cp '+WorkingDir+'/*.word '+ ApacheCaseDir)
		
		## Run model
		# Specify a port and check whether job should be put in queue
		#f = open('/home/NANOMINE/ONR/web/port/2044', 'r')
		#f2044 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2045', 'r')
		#f2045 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2046', 'r')
		#f2046 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2047', 'r')
		#f2047 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2048', 'r')
		#f2048 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2049', 'r')
		#f2049 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2050', 'r')
		#f2050 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2051', 'r')
		#f2051 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2052', 'r')
		#f2052 = f.read()
		#f.close()        
		#f = open('/home/NANOMINE/ONR/web/port/2053', 'r')
		#f2053 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/web/port/2054', 'r')
		#f2054 = f.read()
		#f.close()
		
		IN_QUEUE = False # Default not put in queue - assign a port from 2044 - 2048
		#if f2044[:2] =='on':
		#        # use port 2044 if open
		#        PORT = 2044
		#        # change port to 'off' - being used
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2045[:2] =='on':
		#        PORT = 2045
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#elif f2046[:2] =='on':
		#        PORT = 2046
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#elif f2047[:2] =='on':
		#        PORT = 2047
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2048[:2] =='on':
		#        PORT = 2048
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2049[:2] =='on':
		#        PORT = 2049
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2050[:2] =='on':
		#        PORT = 2050
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2051[:2] =='on':
		#        PORT = 2051
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2052[:2] =='on':
		#        PORT = 2052
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2053[:2] =='on':
		#        PORT = 2053
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f2054[:2] =='on':
		#        PORT = 2054
		#        f = open('/home/NANOMINE/ONR/web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#else:
		#        # job put in queue
		#        IN_QUEUE = True
		##print 'Using COMSOL port:'
		##print PORT
		if not IN_QUEUE: # Run model if a port can be assigned


			########################
			#f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'r')
			#lines = f.readlines()
			#f.close()
			#f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'w')
			#f.writelines(lines[1:])		
			#f.close()

                        ########################
		        
		        if METHOD == 'one': # use pre-saved microstructure
		                
		                # Bash command to open port
		                str_OpenPort = '/usr/local/bin/comsol server -port '+str(PORT)+' &'
		                
		                # MATLAB commands to add path and connect to port
		                str_PATH = "addpath('/usr/local/comsol52/multiphysics/mli', '/usr/local/comsol52/multiphysics/mli/startup');"
		                str_PathPort = str_PATH + "mphstart("+str(PORT)+");"

		                str_matlab_run_model ='nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'+ str_PathPort +' runmain(1,'+str(PORT)+');exit" > ./FEA2D/log/MATLABRUN_'+timestamp+'_'+str(int(count[0]))+'.log &'        
		                print 'Run MATLAB shell command:'
		                print str_matlab_run_model
		                
		                os.system(str_OpenPort)
		                os.system(str_matlab_run_model) # PORT changed back to 'on' in MATLAB code
		                
		                #os.system('cp '+WorkingDir+'/output_efield.jpg '+ApacheCaseDir)            
		        elif METHOD == 'two':
		                #  Generate microstructure for method Two
		                ## Define recon length for each sample system
		                #if graft == 'bare':
		                #        SideL = math.ceil(1046*1.25)
		                #elif graft == 'monoPGMA':
		                #        SideL = math.ceil(2160*1.25)
		                #elif graft == 'ferroPGMA':
		                #        SideL = math.ceil(2160*1.25)
		                #elif graft == 'terthiophenePGMA':
		                #        SideL = math.ceil(1046*1.25)
		                #elif graft == 'monothiophenePGMA':
		                #        SideL = math.ceil(600*1.25)
		                #elif graft == 'anthraenePGMA':
		                #        SideL = math.ceil(600*1.25)                    
		                SideL = 1000
		                        
		                ClusterNo = math.ceil(float(vf)*float(SideL)**2/(3.1416*float(rc)**2));
		                RECONSCRIPT2D = 'nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';descriptor_recon_smooth('+str(SideL)+','+vf+','+str(ClusterNo)+','+str(rd)+',1);exit" > ./FEA2D/log/RECON2DRUN_'+timestamp+'_'+str(int(count[0]))+'.log &'
		                print 'Run recom script shell command:'
		                print RECONSCRIPT2D
		                os.system(RECONSCRIPT2D)
		                
		                RunShellScript='nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';trigger2('+str(PORT)+');exit" > ./FEA2D/log/MATLABRUN_'+timestamp+'_'+str(int(count[0]))+'.log &'        
		                print 'Run MATLAB shell command:'
		                print RunShellScript
		                os.system(RunShellScript)
		                #os.system('cp '+WorkingDir+'/output_efield.jpg '+ApacheCaseDir)
		else: # all ports are full
		        # Ask the user to re-submit job later
			###################################			
			#f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'a')
			#f.write(JOBID+'\n')
			#f.close()
			####################################
		        return render_to_response("DielectricFEA2DBusy.html",locals(),context_instance=RequestContext(request))
		        
		
		return render_to_response("DielectricFEA2DRun.html",
		                          {'UpdateLink':link2result, 'jobid':JOBID},
		                          context_instance=RequestContext(request))
	else:
		return redirect('/login')


###################################
#def wait(request):
	
#	jobflag = 1
#	while jobflag == 1:
#		flag = 1
#
#		while flag == 1:
#			f = open('/home/NANOMINE/ONR/web/port/2044', 'r')
#			ff2044 = f.read()
#			f.close()
#			if ff2044[:2] =='on':
#				# use port 2044 if open
#				port = 2044
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2045', 'r')
#			ff2045 = f.read()
#			f.close()
#			if ff2045[:2] =='on':
#				# use port 2044 if open
#				port = 2045
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2046', 'r')
#			ff2046 = f.read()
#			f.close()
#			if ff2046[:2] =='on':
#				# use port 2044 if open
#				port = 2046
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break		
#			f = open('/home/NANOMINE/ONR/web/port/2047', 'r')
#			ff2047 = f.read()
#			f.close()
#			if ff2047[:2] =='on':
#				# use port 2044 if open
#				port = 2047
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2048', 'r')
#			ff2048 = f.read()
#			f.close()
#			if ff2048[:2] =='on':
#				# use port 2044 if open
#				port = 2048
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2049', 'r')
#			ff2049 = f.read()
#			f.close()
#			if ff2049[:2] =='on':
#				# use port 2044 if open
#				port = 2049
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2050', 'r')
#			ff2050 = f.read()
#			f.close()
#			if ff2050[:2] =='on':
#				# use port 2044 if open
#				port = 2050
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2051', 'r')
#			ff2051 = f.read()
#			f.close()
#			if ff2051[:2] =='on':
#				# use port 2044 if open
#				port = 2051
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2052', 'r')
#			ff2052 = f.read()
#			f.close()
#			if ff2052[:2] =='on':
#				# use port 2044 if open
#				port = 2052
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2053', 'r')
#			ff2053 = f.read()
#			f.close()
#			if ff2053[:2] =='on':
#				# use port 2044 if open
#				port = 2053
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#			f = open('/home/NANOMINE/ONR/web/port/2054', 'r')
#			ff2054 = f.read()
#			f.close()
#			if ff2054[:2] =='on':
#				# use port 2044 if open
#				port = 2054
#				flag = 0
#				# change port to 'off' - being used
#				f = open('/home/NANOMINE/ONR/web/port/'+str(port), 'w+')
#				f.write('off')
#				f.close()
#				break
#
	
#			return render_to_response("DielectricFEA2DWait.html",
#			                  {'flag':flag, 'jobid':jobid},
#			                  context_instance=RequestContext(request))

#		f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'r')
#		lines = f.readlines()
#		if len(lines) == 0:
#			break
#		jobid = lines[0][:-1]
#		f.close()
#	 
#		f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'r')
#		lines = f.readlines()
#		f.close()
#		f = open('/home/NANOMINE/Develop/mdcs/FEA2D/log/job_queue.word', 'w')
#		f.writelines(lines[1:])		
#		f.close()
#
#
#		time.sleep(60)
#		print flag
#		if flag == 0: # Run model if a port can be assigned
#
#			#if METHOD == 'one': # use pre-saved microstructure
#			        
#			# Bash command to open port
#		        str_OpenPort = '~/comsol52/bin/comsol server -port '+str(port)+' &'
#		        
#		        # MATLAB commands to add path and connect to port
#		        str_PATH = "addpath('/home/NANOMINE/comsol52/mli','/home/NANOMINE/comsol52/mli/startup');"
#		        str_PathPort = str_PATH + "mphstart("+str(port)+");"
#
#		        str_matlab_run_model ='nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+ParentDir+jobid+';'+ str_PathPort +' runmain(1,'+str(port)+');exit" > ./FEA2D/log/MATLABRUN_'+jobid+'.log &'        
#		        print 'Run MATLAB shell command:'
#		        print str_matlab_run_model
#		        
#		        os.system(str_OpenPort)
#		        os.system(str_matlab_run_model) # PORT changed back to 'on' in MATLAB code
#		link2result = 'http://puma.mech.northwestern.edu/nanomine/DielectricFEA2D/'+jobid
#		return render_to_response("DielectricFEA2DRun.html",
#			  {'UpdateLink':link2result, 'jobid':jobid},
#			  context_instance=RequestContext(request))
#	return redirect('/FEA2D')
##################################

def check(request):
	if request.user.is_authenticated():
		# job progress checker. default job ID taken from current view. 
		
		# Standalone view. NO GLOBAL VARIABLE SHOULD BE USED HERE!
		FINISH = 0
		polymer_read=''
		particle_read=''
		graft_read=''
		vf_read=''
		ip_read=''
		image_read=''
		material_read=''
		model_read=''
		mesh_read=''
		physics_read=''
		study_read=''
		structure_read=''
		solution_read =''
		finish_read =''
		
		try:
		        JOBID
		except NameError:
		        defaultJobID=''
		else:
		        defaultJobID=JOBID
		        
		GEOM =''
		EP_IMG =''
		EPP_IMG=''
		EP_LINK=''
		EPP_LINK=''

		if len(request.POST) != 0: # when there is actual input
		        jobID = request.POST['job_ID']
		        defaultJobID = jobID

		        
		        WORKDING_DIR = ParentDir+str(jobID)
		        ApacheCaseDir ='/var/www/html/nanomine/DielectricFEA2D/'+str(jobID)
		        
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
		        list1={}
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
		        if os.path.exists(WORKDING_DIR + '/create_structure.status'):
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
		        if FINISH ==1 :
		                os.system('cp '+WORKDING_DIR+'/*.jpg '+ ApacheCaseDir)
		                os.system('cp '+WORKDING_DIR+'/*.csv '+ ApacheCaseDir)
		                HTTPROOT= 'http://nanomine.northwestern.edu/nanomine/DielectricFEA2D/'+str(jobID)
		                GEOM = HTTPROOT + '/microstructure.jpg'
		                EP_IMG = HTTPROOT+ '/epsilon_real.jpg'
		                EPP_IMG = HTTPROOT + '/epsilon_imag.jpg'
		                EPP_LINK = HTTPROOT+ '/CompPermImag.csv'
		                EP_LINK = HTTPROOT + '/eCompPermReal.csv'
		                
		return render_to_response("DielectricFEA2DCheckProgress.html",
		                          {'finish':FINISH,
		                           'defaultID': defaultJobID,
		                           'w1':polymer_read, 'w2':particle_read,'w3':graft_read,'w4':vf_read,'w5':ip_read,
		                           's1':image_read,'s2':material_read,'s3':model_read,'s4':mesh_read,'s5':physics_read,'s6':study_read,'s7':structure_read,'s8':solution_read ,'s9':finish_read,
		                           'geom':GEOM,'ep':EP_IMG,'epp':EPP_IMG,'ep_link':EP_LINK, 'epp_link':EPP_LINK},
		                          context_instance=RequestContext(request))
	else:
		return redirect('/login')

def result(request):
	if request.user.is_authenticated():
       		return render_to_response("DielectricFEA2DResult.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')
    
def sample(request):
	if request.user.is_authenticated():
	        return render_to_response("DielectricFEA2DResultSample.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')
    
### Below are not directly used in Django functions.========================================= 

# Energy.py

def HamakerConst(eps_i, n_i):
      global kB, T, h_p
      ve=3e15 #Hz
      A_i=3.0/4*kB*T*((eps_i-1)/(eps_i+1))**2 \
            + 3*h_p*ve/16/np.sqrt(2)*(n_i**2-1)**2/(n_i**2+1)**(3.0/2)
      return A_i

def Chi(Hamaker_Polymer, Hamaker_graft, Hamaker_Particle, R, h, L ):
      #chi is the enthalpy for 
      #h is the particle-particle outer surface distance, use 0.165nm in the literature
      # L is the thickness of the hybrid layer
      #R is the particle radius
      # This value only valid when d-2L<<R
      global kB, T
      chi = -R/12.0*( \
            (np.sqrt(Hamaker_Polymer) - np.sqrt(Hamaker_graft))**2/(h)+ \
            (np.sqrt(Hamaker_graft) - np.sqrt(Hamaker_Particle))**2/(h+2*L) + \
            ((np.sqrt(Hamaker_Polymer) - np.sqrt(Hamaker_graft))* \
            (np.sqrt(Hamaker_graft)-np.sqrt(Hamaker_Particle)))/(h+L))
      return chi/kB/T

def Chi_bare(Hamaker_Polymer, Hamaker_Particle, R,h):
      global kB, T
      chi_bare = -R/12.0/h*(np.sqrt(Hamaker_Polymer)-np.sqrt(Hamaker_Particle))**2
      return chi_bare/kB/T

def mix_eps(eps_shortbrush, v_shortbrush,  eps_funcG, v_funcG):
      return np.exp(v_shortbrush*np.log(eps_shortbrush)+v_funcG*np.log(eps_funcG))

def mix_n(n_shortbrush, v_shortbrush, n_funcG, v_funcG):
      return v_shortbrush*n_shortbrush+v_funcG*n_funcG


#For entropy
def func_F_D(F_D_flat, R, h_i):
      f_d = F_D_flat*3*R/5/h_i*np.log(1+5*h_i/3/R)
      return f_d

def func_F_C(F_C_flat, R, h_i):
      f_c = F_C_flat*2*R/h_i*((1+4*h_i/3/R)**(3.0/8.0)-1)
      return f_c

def func_F_H(F_H_flat):
      f_h=2*F_H_flat
      return f_h

def Sigma_DorC(n_p, R):
      #n_p is number of the grafted brush
      return n_p/4/np.pi/R/R

def Sigma_H(n_p, R):
      return n_p/3/np.sqrt(3)/R/R

def h_i(N, a, sigma, P):
      # N is the polymerization of the short brush
      # a is the monomer size
      # sigma is the graft density of the short brush
      return N*a**(5.0/3)*sigma**(1.0/3)*P**(-1.0/3)

def Phi_i(h_i, sigma, N, a, d):
      #is to compute the free energy per unit area
      phi_i = np.pi**2/24*h_i**2*sigma/N/a**2* \
              (2*h_i/d+2*(d/2/h_i)**2-1/5.0*(d/2/h_i)**5-9/5.0)
      return phi_i 

def func_F_A_flat(a, N, R, n_p, P):
      f_a_flat = a**2*N/R**2+a**3*n_p*N**2/(R**3*P)*n_p
      return f_a_flat

def func_FA(f_a_flat, b):
      return f_a_flat/(np.pi*(b/2)**2)

def Chi_i(alpha, chi, b):
      return alpha*chi/np.pi/(b/2)**2
