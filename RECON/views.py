from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass
from RECON.models import Document
from RECON.forms import DocumentForm
from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np

import os.path


# Create your views here.

ParentDir = '/home/NANOMINE/ONR/RECON_web/'

def home(request):
	# Handle file upload
	if request.user.is_authenticated():
		global timestamp, datafile, ttype, color, sphere, cutL, VF, recon_length, scale, visualize_fine_recon, visualize_coarse_recon
		timestamp = strftime("%Y%m%d%H%M%S", gmtime())
	

		if request.method == 'POST':

			form = DocumentForm(request.POST, request.FILES)
			if form.is_valid():
				newdoc = Document(docfile = request.FILES['docfile'])
				newdoc.save()

				datafile = request.POST.get('datafile') # let user input filename with extension
				ttype = request.POST['type']
				color = request.POST['color']
				sphere = request.POST['sphere']
				cutL = request.POST['cutL']
				VF = request.POST['VF']
				recon_length = request.POST['recon_length']
				scale = request.POST['scale']
				visualize_fine_recon = request.POST['visualize_fine_recon']
				visualize_coarse_recon = request.POST['visualize_coarse_recon']

				
	
		    	return HttpResponseRedirect(reverse('RECON.views.home'))

		else:
			print 'FORM NOT VALID'
			form = DocumentForm() # A empty, unbound form

		# Load documents for the list page
		documents = Document.objects.all()

		# Render list page with the documents and the form
		return render(request,'RECON.html', {'form': form},
			context_instance=RequestContext(request))
	else:
		return redirect('/login')
	
def runmodel(request):
	if request.user.is_authenticated():
		global JOBID, filename, WorkingDir, link2result, ApacheCaseDir
		
		
		# run model to nuhup
		f = open('./RECON/RunCount.num', 'r+')
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
			
		f = open('./RECON/workingdir.str', 'w+')
		f.write(WorkingDir)
		f.close()
		
		f = open(WorkingDir+'/type.word', 'w+')
		f.write(ttype)
		f.close()

		f = open(WorkingDir+'/fine.word', 'w+')
		f.write(visualize_fine_recon)
		f.close()
		
		f = open(WorkingDir+'/coarse.word', 'w+')
		f.write(visualize_coarse_recon)
		f.close()	


		# Copy source code to working dir
		os.system('cp /home/NANOMINE/ONR/RECON_web/code/* '+WorkingDir)
		os.system('cp ./RECON/workingdir.str '+WorkingDir)


		# Create new HTML in apache path to display modeling process
		ApacheCaseDir = '/var/www/html/nanomine/RECON/'+timestamp+'_'+str(int(count[0]))	

		# Link of Apache page
		link2result = 'http://nanomine.northwestern.edu/nanomine/RECON/'+timestamp+'_'+str(int(count[0]))
		if not os.path.exists(ApacheCaseDir):
			os.makedirs(ApacheCaseDir)
			print '----------------Created user case Apache folder'
			# os.system('cp '+WorkingDir+'/*.word '+ ApacheCaseDir)		
	
		
		cpfile = 'mv ./RECON/media/'+datafile+' '+ WorkingDir
		print cpfile
		os.system(cpfile)
				
				
		JOBID = timestamp+'_'+str(int(count[0]))
		filename = datafile.rsplit('.',1)[0]
		f = open(WorkingDir+'/filename.word', 'w+')
		f.write(filename)
		f.close()	
		toPath = 'cd '+WorkingDir+';'
		call_plot = 'nohup matlab -nosplash -nodisplay -nodesktop -r "cd '+WorkingDir
		call_plot2= "; MAIN('"+filename+"', '"+str(ttype)+"', '"+str(color)+"', '"+str(sphere)+"', '"+str(cutL)+"', '"\
		+str(VF)+"', '"+str(recon_length)+"', '"+str(scale)+"', '"+str(visualize_fine_recon)+"', '"+str(visualize_coarse_recon)+"'"
		call_plot3= ');exit" > ./a.log &'
		print '\n'
		print call_plot+call_plot2+call_plot3
		os.system(toPath + call_plot+call_plot2+call_plot3)
		
		return render_to_response("RECONRun.html", {'jobid':JOBID, 'TYPE': ttype, 'FINE':visualize_fine_recon, 'COARSE': visualize_coarse_recon},
								  context_instance=RequestContext(request))
	else:
		return redirect('/login')
	
def check(request):
	if request.user.is_authenticated():
		FINISH = 0
		out1 = ''
		out2 = ''
		out3 = ''
		out4 = ''
		out5 = ''
		out6 = ''
		out7 = ''
		out8 = ''
		#plot1 = ''
		#plot2 = ''
		TYPE = ''
		#FINE = ''
		#COARSE = ''
		
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
			
			f = open(WORKDING_DIR+'/type.word', 'r')
			TYPE = int(f.read())
			f.close()
			
			#f = open(WORKDING_DIR+'/fine.word', 'r')
			#FINE = int(f.read())
			#f.close()
			
			#f = open(WORKDING_DIR+'/coarse.word', 'r')
			#COARSE = int(f.read())
			#f.close()
			
			f = open(WORKDING_DIR+'/filename.word', 'r')
			FILE = f.read()
			f.close()
			
			ApacheCaseDir = '/var/www/html/nanomine/RECON/'+str(jobID)
			
			#if visualize_fine_recon ==0 and visualize_coarse_recon == 0 and os.path.exists(WORKDING_DIR+'/'+FILE+'_results/'+FILE+'_3D_recon_3D_geometry.mat'): # the last file code generated, in 95 is this, in 149 should be plots
			#	FINISH = 1
			#if visualize_fine_recon ==1 and visualize_coarse_recon == 0 and os.path.exists(WORKDING_DIR+'/'+FILE+'_results/'+FILE+'_visualize_fine_recon.jpg'):
			#	FINISH = 1
			#if visualize_fine_recon ==0 and visualize_coarse_recon == 1 and os.path.exists(WORKDING_DIR+'/'+FILE+'_results/'+FILE+'_visualize_coarse_recon.jpg'):
			#	FINISH = 1
			#if visualize_fine_recon ==1 and visualize_coarse_recon == 1 and os.path.exists(WORKDING_DIR+'/'+FILE+'_results/'+FILE+'_visualize_fine_recon.jpg'):
			#	FINISH = 1
			if os.path.exists(WORKDING_DIR+'/'+FILE+'_results/'+FILE+'_3D_recon_3D_geometry.mat'): # the last file code generated, in 95 is this, in 149 should be plots
				FINISH = 1;			
			
				
			if FINISH == 1:		
				# still have visualize_fine_recon and/or visualize_coarse_recon figure do not plot and save because of 95's problem, need to add later
				cpcp = 'cp '+WORKDING_DIR+'/'+FILE+'_results/* '+ApacheCaseDir
				print cpcp
				os.system(cpcp)
				HTTPROOT = 'http://nanomine.northwestern.edu/nanomine/RECON/'+str(jobID)
				out1 = HTTPROOT+'/'+FILE+'_3D_recon.mat'
				out2 = HTTPROOT+'/'+FILE+'_3D_recon_3D_geometry.mat'
				out3 = HTTPROOT+'/'+FILE+'_3D_recon_3D_orinatation.mat'
				if TYPE == 1:	
					out4 = HTTPROOT+'/'+FILE+'_3D_recon_center_list.mat'
				else:
					out4 = ''
				out5 = HTTPROOT+'/'+FILE+'_GB_double_filter.tif'
				out6 = HTTPROOT+'/'+FILE+'_GB_double_filter_2D_results.mat'
				out7 = HTTPROOT+'/'+FILE+'_GB_double_filter_3D_results.mat'
				out8 = HTTPROOT+'/'+FILE+'_coarsen_recon.mat'
				#if FINE == 1:
				#	plot1 = HTTPROOT+'/'+FILE+'_visualize_fine_recon.jpg'
				#if COARSE == 1:
				#	plot2 = HTTPROOT+'/'+FILE+'_visualize_coarse_recon.jpg'
#		return render_to_response("RECONCheck.html",
#								  {'defaultID': defaultJobID,
#								   'out1':out1, 'out2':out2, 'out3':out3, 'out4':out4, 'out5':out5, 'out6':out6, 'out7':out7,
#								   'out8':out8, 'plot1':plot1, 'plot2':plot2,
#								   'finish':FINISH, 'type':TYPE, 'fine':FINE, 'coarse':COARSE},
#								  context_instance=RequestContext(request))
		return render_to_response("RECONCheck.html",
								  {'defaultID': defaultJobID,
								   'out1':out1, 'out2':out2, 'out3':out3, 'out4':out4, 'out5':out5, 'out6':out6, 'out7':out7,
								   'out8':out8, 'finish':FINISH, 'type':TYPE},
								  context_instance=RequestContext(request))
				
	else:
		return redirect('/login')
		
def result(request):
	if request.user.is_authenticated():
		return render_to_response("RECONResult.html", locals(), context_instance=RequestContext(request))
	else:
		return redirect('/login')

def sample(request):
	if request.user.is_authenticated():
		return render_to_response("RECONSample.html", locals(),
				context_instance=RequestContext(request))
	else:
		return redirect('/login')	
	


