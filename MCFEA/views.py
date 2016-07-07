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

ParentDir = '/home/NANOMINE/ONR/MCFEA_web/'

# Create your views here.
def home(request):
	if request.user.is_authenticated():
		# main page to get user input
		global WorkingDir, timestamp
		timestamp = strftime("%Y%m%d%H%M%S", gmtime())
	

		if len(request.POST) != 0:
			global field, DOS, T0, probability, E_range, include_NP, NP_energy, mean_num_NP, dev, NP_radius, vf, ttype, FEA, rec_t, n
			print 'length of return POST dict is: '
			print len(request.POST)		
			field = request.POST['field']
			DOS = request.POST['DOS']
			if DOS == "gaussian" or DOS == "exponential":
				T0 = request.POST['T0']
			else:
				probability = request.POST['probability']
				E_range = request.POST['E_range']
			include_NP = request.POST['include_NP']
			if include_NP == "YES":
				NP_energy = request.POST['NP_energy']
				mean_num_NP = request.POST['mean_num_NP']
				dev = request.POST['dev']
				NP_radius = request.POST['NP_radius']
				vf = request.POST['vf']
				ttype = request.POST['ttype']
				FEA = request.POST['FEA']
			else:
				NP_radius = 2.5
			rec_t = request.POST['rec_t']
			n = request.POST['n']

	
		return render_to_response("MCFEA.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')
def validate(request):
	if request.user.is_authenticated():
		# validate input parameter.
		out1={}
		out1['Nominal field'] = field
		out1['Shape of density of states function'] = DOS
	
		out2 = {}
		if DOS == "gaussian":
			out2['T0'] = T0
		elif DOS == "exponential":
			out2['T0'] = T0
		else:
			out2['deepest energy with 0 as reference'] = probability
			out2['probability'] = E_range
		out2['whether to include nanoparticles'] = include_NP
	
		out3={}
		if include_NP == "YES":
			out3['NP energy'] = NP_energy
			out3['average size of cluster'] = mean_num_NP
			out3['standard deviation of distribution'] = dev
			out3['Particle radius'] = NP_radius
			out3['Volume fraction'] = vf
			out3['Agglomerates type'] = ttype
			out3['Whether to couple with the finite element'] = FEA
		else:
			out3['Particle radius'] = 2.5
		out3['Data points of transport time to record'] = rec_t
		out3['Repeat time'] = n

		return render_to_response("MCFEAValidateInput.html", 
					  {'data1': sorted(out1.iteritems()),
					   'data2': sorted(out2.iteritems()),
					   'data3': sorted(out3.iteritems())},
					  context_instance=RequestContext(request))
	else:
		return redirect('/login')

def runmodel(request):
	if request.user.is_authenticated():
		# run model to nohup
		# update current count of total simulation run
	
		global JOBID
	
		ran = 5 * random.random()
		time.sleep(ran)

		f = open('./MCFEA/RunCount.num', 'r+')
		count = f.readlines()
		print 'total count so far is:'
		print count
		f.seek(0)
		newcount = int(count[0]) + 1
		f.write(str(newcount))
		f.close

		f = open('./MCFEA/PortCount.num', 'r+')
		PORT = int(f.readlines()[0])
		print 'using port:'
		print PORT
		f.seek(0)
		if PORT == 3100:
			f.write(str(3000))
		else:
			newport = PORT + 1
			f.write(str(newport))
		f.close

		# Proceed to create new dir for this user case if inputs are validated
		WorkingDir = ParentDir + timestamp + '_' + str(int(count[0]))
		JOBID = timestamp + '_' + str(int(count[0]))
	 	if not os.path.exists(WorkingDir):
			os.makedirs(WorkingDir)
			print '---------------------Created working folder'
		f = open('./MCFEA/workingdir.str', 'w+')
		f.write(WorkingDir)
		f.close()

		# Copy source code to working dir
		os.system('cp /home/NANOMINE/ONR/MCFEA_web/code/* '+WorkingDir)
		os.system('cp -r /home/NANOMINE/ONR/MCFEA_web/code/MC_3D_hopping '+WorkingDir)
		os.system('cp -r /home/NANOMINE/ONR/MCFEA_web/code/MC_FEA '+WorkingDir)
		os.system('cp ./MCFEA/workingdir.str '+WorkingDir)

		# Save input parameters to file
		f = open(WorkingDir+'/input1_field.word', 'w+')
		f.write(field)
		f.close()
		f = open(WorkingDir+'/input2_DOS.word', 'w+')
		f.write(DOS)
		f.close()
		f = open(WorkingDir+'/input3_file.word', 'w+')
		if DOS == 'gaussian' or DOS == 'exponential':
			f.write(T0+'\n')
			f.write('0\n')
			f.write('0')
			f.close()
		else:
			f.write('0\n')
			f.write(probability+'\n')
			f.write(E_range)
			f.close()
		f = open(WorkingDir+'/input4.word', 'w+')
		if include_NP == "YES":
			f.write('1')
			f.close()
		else:
			f.write('0')
			f.close()
		f = open(WorkingDir+'/input5_file.word', 'w+')
		if include_NP == "YES":
			f.write(NP_energy+'\n')
			f.write(mean_num_NP+'\n')
			f.write(dev+'\n')
			f.write(NP_radius+'\n')
			f.write(vf+'\n')
			f.write(ttype+'\n')
			if FEA == "YES":
				f.write('1')
			else:
				f.write('0')
		else:
			f.write('0\n')
			f.write('0\n')
			f.write('0\n')
			f.write('2.5\n')
			f.write('0\n')
			f.write('0\n')
			f.write('0')
		f.close()
		f = open(WorkingDir+'/input6_file.word', 'w+')
		f.write(rec_t+'\n')
		f.write(n)
		f.close()

		# Create new HTML in apache path to display modeling process
		ApacheCaseDir = '/var/www/html/nanomine/MCFEA/'+timestamp+'_'+str(int(count[0]))

		# Link of Apache page
		link2result = 'http://puma.mech.northwestern.edu/nanomine/MCFEA/'+timestamp+'_'+str(int(count[0]))
		if not os.path.exists(ApacheCaseDir):
			os.makedirs(ApacheCaseDir)
			print '----------------Created user case Apache folder'
			os.system('cp '+WorkingDir+'/*.word '+ ApacheCaseDir)

		# Run model
		# Specify a port and check whether job should be put in queue
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3044', 'r')
		#f3044 = f.read()
		#print f3044
		#print len(f3044)
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3045', 'r')
		#f3045 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3046', 'r')
		#f3046 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3047', 'r')
		#f3047 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3048', 'r')
		#f3048 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3049', 'r')
		#f3049 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3050', 'r')
		#f3050 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3051', 'r')
		#f3051 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3052', 'r')
		#f3052 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3053', 'r')
		#f3053 = f.read()
		#f.close()
		#f = open('/home/NANOMINE/ONR/MCFEA_web/port/3054', 'r')
		#f3054 = f.read()
		#f.close()

		IN_QUEUE = False # Default not put in queue - assign a port from 3044 - 3054
		#if f3044[:2] == 'on':
		#        # use port 3044 if open
		#        PORT = 3044
		#        # change port to 'off' - being used
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3045[:2] =='on':
		#        PORT = 3045
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#elif f3046[:2] =='on':
		#        PORT = 3046
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#elif f3047[:2] =='on':
		#        PORT = 3047
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3048[:2] =='on':
		#        PORT = 3048
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3049[:2] =='on':
		#        PORT = 3049
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3050[:2] =='on':
		#        PORT = 3050
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3051[:2] =='on':
		#        PORT = 3051
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3052[:2] =='on':
		#        PORT = 3052
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3053[:2] =='on':
		#        PORT = 3053
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()
		#elif f3054[:2] =='on':
		#        PORT = 3054
		#        f = open('/home/NANOMINE/ONR/MCFEA_web/port/'+str(PORT), 'w+')
		#        f.write('off')
		#        f.close()                
		#else:
		#        # job put in queue
		#        IN_QUEUE = True	


		if not IN_QUEUE: # Run model if a port can be assign
			# Bash command to open port
			print 'Using COMSOL prot: '
			print PORT
			str_OpenPort = '~/comsol52/bin/comsol server -port '+str(PORT)+' &'
		
			# MATLAB commands to add path and connect to port
		        str_PATH1 = "addpath('/home/NANOMINE/comsol52/mli','/home/NANOMINE/comsol52/mli/startup');"		
			#str_PATH2 = str_PATH1 + "addpath(genpath('./MC_FEA'));"
			#str_PATH3 = str_PATH2 + "addpath('./MC_3D_hopping/');"
			#str_PATH4 = str_PATH3 + "addpath('./MC_3D_hopping/support_function/');"
		        str_PathPort = str_PATH1 + "mphstart("+str(PORT)+");"
		        str_matlab_run_model ='nohup matlab -nodesktop -nosplash -nodisplay -r "cd '+WorkingDir+';'+ str_PathPort +' run('+str(PORT)+');exit" > ./MCFEA/log/MATLABRUN_'+timestamp+'_'+str(int(count[0]))+'.log &'        
		        print 'Run MATLAB shell command:'
		        print str_matlab_run_model
		        
			# uncommand it when modify the source matlab code                        
			os.system(str_OpenPort)
		        os.system(str_matlab_run_model) # PORT changed back to 'on' in MATLAB code
		else:
			return render_to_response("MCFEABusy.html", locals(), context_instance=RequestContext(request))

		return render_to_response("MCFEARun.html",
					{'UpdateLink': link2result, 'jobid': JOBID},
					context_instance=RequestContext(request))
	else:
		return redirect('/login')

def check(request):
	if request.user.is_authenticated():
		# job progress checker. default job ID taken from current view.
		# Standaline view. NO GLOBAL VARIABLE SHOULD BE USED HERE
		FINISH = 0
		show1={}
		show2 = {}
		show3={}

		en_img = ''
		tra_img = ''
		out_csv = ''


	#	field_read = ''
	#	DOS_read = ''
	#	T0_read = ''
	#	probability_read = ''
	#	E_range_read = ''
	#	include_NP_read = ''
	#	NP_energy_read = ''
	#	mean_num_NP_read = ''
	#	dev_read = ''
	#	NP_radius_read = ''
	#	vf_read = ''
	#	ttype_read = ''
	#	FEA_read = ''
	#	rec_t_read = ''
	#	n_read = ''
	
		try:
			JOBID
		except NameError:
			defaultJobID = ''
		else:
			defaultJobID = JOBID
	
		if len(request.POST) != 0: # when there is a actual input
			jobID = request.POST['job_ID']
			defaultJobID = jobID


			WORKDING_DIR = ParentDir+str(jobID)
			ApacheCaseDir = '/var/www/html/nanomine/MCFEA/'+str(jobID)



			show1['Nominal field'] = field
			show1['Shape of density of states function'] = DOS


			if DOS == "gaussian":
				show2['T0'] = T0
			elif DOS == "exponential":
				show2['T0'] = T0
			else:
				show2['deepest energy with 0 as reference'] = probability
				show2['probability'] = E_range
			show2['whether to include nanoparticles'] = include_NP


			if include_NP == "YES":
				show3['NP energy'] = NP_energy
				show3['average size of cluster'] = mean_num_NP
				show3['standard deviation of distribution'] = dev
				show3['Particle radius'] = NP_radius
				show3['Volume fraction'] = vf
				show3['Agglomerates type'] = ttype
				show3['Whether to couple with the finite element'] = FEA
			else:
				show3['Particle radius'] = 2.5
			show3['Data points of transport time to record'] = rec_t
			show3['Repeat time'] = n


	#		INPUT1_FILE = WORKDING_DIR + '/input1_field.word'
	#		if os.path.exists(INPUT1_FILE)	:
	#			f = open(INPUT1_FILE, 'r')
	#			field_read = f.read()
	#			f.close()
	#		INPUT2_FILE = WORKDING_DIR + '/input2_DOS.word'
	#		if os.path.exists(INPUT2_FILE):		
	#			f = open(INPUT2_FILE, 'r')
	#			DOS_read = f.read()
	#			f.close()
	#		INPUT3_FILE = WORKDING_DIR +'/input3_file.word'
	#		if os.path.exists(INPUT3_FILE):
	#			f = open(INPUT3_FILE, 'r')
	#			T0_read = fgets(f)		
	#			probability_read = fgets(f)
	#			E_range_read = fgets(f)
	#			f.close()
	#		INPUT4_FILE = WORKDING_DIR + '/input4.word'
	#		if os.path.exists(INPUT4_FILE):
	#			f = open(INPUT4_FILE, 'r')
	#			include_NP_temp = read()
	#			f.close()
	#			if include_NP_temp == 1:
	#				include_NP_read = "YES"
	#			else:
	#				include_NP_read = "NO"
	#		INPUT5_FILE = WORKDING_DIR + '/input5_file.word'
	#		if os.path.exists(INPUT5_FILE):			
	#			f = open(INPUT5_FILE, 'r')
	#			NP_energy_read = fgets(f)
	#			mean_num_NP_read = fgets(f)
	#			dev_read = fgets(f)
	#			NP_radius_read = fgets(f)
	#			vf_read = fgets(f)
	#			ttype_read = fgets(f)
	#			FEA_temp = fgets(f)
	#			f.close()
	#			if FEA_temp == 1:
	#				FEA_read = "YES"
	#			else:
	#				FEA_read = "NO"
	#		INPUT6_FILE = WORKDING_DIR + '/input6_file.word'
	#		if os.path.exists(INPUT6_FILE):
	#			f = open(INPUT6_FILE, 'r')
	#			rec_t_read = fgets(f)
	#			n_read = fgets(f)
	#			f.close()		


			# Status flags
		        if os.path.exists(WORKDING_DIR + '/job_finish.status'):
		                f = open(WORKDING_DIR + '/job_finish.status', 'r')
		                finish_read = f.read()
		                f.close
		                
		                FINISH = 1

			if FINISH == 1:
				os.system('cp '+WORKDING_DIR+'/*.jpg '+ ApacheCaseDir)
				os.system('cp '+WORKDING_DIR+'/*.csv '+ ApacheCaseDir)
				HTTPROOT= 'http://puma.mech.northwestern.edu/nanomine/MCFEA/'+str(jobID)
				en_img = HTTPROOT + '/energy_hist.jpg'
				tra_img = HTTPROOT + '/travel_distance.jpg'
				out_csv = HTTPROOT + '/output.csv'

		return render_to_response("MCFEACheckProgress.html", 
					  {'defaultID': defaultJobID,
					   'data1': sorted(show1.iteritems()),
					   'data2': sorted(show2.iteritems()),
					   'data3': sorted(show3.iteritems()),
					   'en_img': en_img, 'tra_img': tra_img, 'out_csv': out_csv, 'finish': FINISH},
					  context_instance=RequestContext(request))
	else:
		return redirect('/login')
	
def result(request):
	if request.user.is_authenticated():
		return render_to_response("MCFEAResult.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')

def sample(request):
	if request.user.is_authenticated():
		return render_to_response("MCFEAResultSample.html", locals(),
				context_instance=RequestContext(request))
	else:
		return redirect('/login')



























