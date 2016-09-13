from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from .forms import *

import os, random, getpass
from Dynamfit.models import Document
from Dynamfit.forms import DocumentForm
from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np

import os.path


# Create your views here.

ParentDir = '/home/NANOMINE/ONR/DynamFit_web/'


#def upload(request):
#	# Handle file upload
#	global WorkingDir, timestamp, datafile, weight, std, NumEle, mtd
 #       timestamp = strftime("%Y%m%d%H%M%S", gmtime())
#
 #       if len(request.POST) != 0: # when there is actual inputs
#		datafile = request.POST.get('datafile')
#		weight = request.POST['weight']
#		std = request.POST['std']
#		NumEle = request.POST['NumEle']
#		mtd = request.POST['mtd']
#		print datafile
#		print weight
#		print std
#		print NumEle
#		print mtd

	
#		return render_to_response("Dynamfit_new.html",locals(),context_instance=RequestContext(request))

#	return HttpResponseRedirect(reverse('Dynamfit.views.runmodel'))

def home(request):
	# Handle file upload
	if request.user.is_authenticated():
		global WorkingDir, timestamp, datafile, weight, std, NumEle, mtd, link2result, ApacheCaseDir
		timestamp = strftime("%Y%m%d%H%M%S", gmtime())
	

		if request.method == 'POST':

			# run model to nuhup
			f = open('./Dynamfit/RunCount.num', 'r+')
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
	
			f = open('./Dynamfit/workingdir.str', 'w+')
			f.write(WorkingDir)
			f.close()

			# Copy source code to working dir
			# os.system('cp /home/NANOMINE/ONR/Dynamfit_web/a.out '+WorkingDir)
			# os.system('cp /home/NANOMINE/ONR/Dynamfit_web/start.py '+WorkingDir)
			os.system('cp /home/NANOMINE/ONR/DynamFit_web/code/* '+WorkingDir)
			os.system('cp ./Dynamfit/workingdir.str '+WorkingDir)

			# Create new HTML in apache path to display modeling process
			ApacheCaseDir = '/var/www/html/nanomine/Dynamfit/'+timestamp+'_'+str(int(count[0]))	
	
			# Link of Apache page
			link2result = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/'+timestamp+'_'+str(int(count[0]))
			if not os.path.exists(ApacheCaseDir):
				os.makedirs(ApacheCaseDir)
				print '----------------Created user case Apache folder'
				# os.system('cp '+WorkingDir+'/*.word '+ ApacheCaseDir)





			form = DocumentForm(request.POST, request.FILES)
			if form.is_valid():
				newdoc = Document(docfile = request.FILES['docfile'])
				newdoc.save()


				datafile = request.POST.get('datafile')
				weight = request.POST['weight']
				std = request.POST['std']
				NumEle = request.POST['NumEle']
				mtd = request.POST['mtd']


				cpfile = 'mv ./Dynamfit/media/'+datafile+'.X_T '+ WorkingDir		
				os.system(cpfile)
	
				# run model
				call_start = "python start.py %s %s %s %s %s" %(datafile, weight, std, NumEle, mtd)
				toPath = 'cd '+WorkingDir+';'
				os.system(toPath + call_start)
				#time.sleep(3)
				call_plot = 'nohup matlab -nosplash -nodisplay -nodesktop -r "cd '+WorkingDir
				call_plot2= "; myfun_plot('"+datafile+".X_T', '"+datafile+".XPR', '"+str(NumEle)+"'"
				call_plot3= ');exit" > ./a.log &'
				print '\n'
				print call_plot+call_plot2+call_plot3
				os.system(toPath + call_plot+call_plot2+call_plot3)

				time.sleep(40)
				os.system('cp '+WorkingDir+'/E.jpg '+ ApacheCaseDir)
				os.system('cp '+WorkingDir+'/EE.jpg '+ ApacheCaseDir)
				os.system('cp '+WorkingDir+'/*.XFF '+ ApacheCaseDir)
				os.system('cp '+WorkingDir+'/*.XPR '+ ApacheCaseDir)
				os.system('cp '+WorkingDir+'/*.XTF '+ ApacheCaseDir)




		    	return HttpResponseRedirect(reverse('Dynamfit.views.home'))

		else:
			print 'FORM NOT VALID'
			form = DocumentForm() # A empty, unbound form

		# Load documents for the list page
		documents = Document.objects.all()

		# Render list page with the documents and the form
		return render(request,'Dynamfit_new.html', {'form': form},
			context_instance=RequestContext(request))
	else:
		return redirect('/login')

def runmodel(request):
	if request.user.is_authenticated():
		#time.sleep(5)
		#os.system('cp '+WorkingDir+'/E.jpg '+ ApacheCaseDir)
		#os.system('cp '+WorkingDir+'/EE.jpg '+ ApacheCaseDir)
		Eprime = link2result + '/' + 'E.jpg'
		EEprime = link2result + '/' + 'EE.jpg'
		XFF = link2result + '/' + datafile + '.XFF'
		XPR = link2result + '/' + datafile + '.XPR'
		XTF = link2result + '/' + datafile + '.XTF'
	
		return render_to_response("DynamfitRun.html", 
					{'E_link': Eprime, 'EE_link': EEprime, 'XFF_link': XFF, 'XPR_link': XPR, 'XTF_link': XTF},
					context_instance=RequestContext(request))
	else:
		return redirect('/login')

def sample(request):
		if request.user.is_authenticated():
				return render_to_response("DynamfitExample.html", locals(),
				        context_instance=RequestContext(request))
		else:
			return redirect('/login')

def sampleinput(request):
	if request.user.is_authenticated():
		global examplelink2result
		if request.method == 'POST':
			# Link of Apache page
			examplelink2result = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/'

			if len(request.POST) != 0:
				exampleweight = request.POST['weight']
				examplestd = request.POST['std']
				exampleNumEle = request.POST['NumEle']
				examplemtd = request.POST['mtd']
	
				# run model
				call_start = "python start.py EXAMPLE %s %s %s %s" %(exampleweight, examplestd, exampleNumEle, examplemtd)
				toPath = 'cd /home/NANOMINE/Develop/mdcs/Dynamfit/example;'
				os.system(toPath + call_start)
				#time.sleep(3)
				call_plot = 'nohup matlab -nosplash -nodisplay -nodesktop -r "cd /home/NANOMINE/Develop/mdcs/Dynamfit/example'
				call_plot2= "; myfun_plot('EXAMPLE.XPR', '"+str(exampleNumEle)+"'"
				call_plot3= ');exit" > ./a.log &'
				print '\n'
				print call_plot+call_plot2+call_plot3
				os.system(toPath + call_plot+call_plot2+call_plot3)

				time.sleep(15)
				if os.path.isfile("/var/www/html/nanomine/Dynamfit/exampleE.jpg"):
					os.system('rm /var/www/html/nanomine/Dynamfit/exampleE.jpg')
				if os.path.isfile("/var/www/html/nanomine/Dynamfit/exampleEE.jpg"):
					os.system('rm /var/www/html/nanomine/Dynamfit/exampleEE.jpg')
				os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleE.jpg /var/www/html/nanomine/Dynamfit')
				os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleEE.jpg /var/www/html/nanomine/Dynamfit')
				os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XPR /var/www/html/nanomine/Dynamfit')
				os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XFF /var/www/html/nanomine/Dynamfit')
				os.system('cp /home/NANOMINE/Develop/mdcs/Dynamfit/example/EXAMPLE.XTF /var/www/html/nanomine/Dynamfit')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XFF')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XPR')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/*.XTF')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleE.jpg')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/exampleEE.jpg')
				#os.system('rm /home/NANOMINE/Develop/mdcs/Dynamfit/example/a.log')
				

				#os.system('cp '+WorkingDir+'/*.XFF '+ ApacheCaseDir)
				#os.system('cp '+WorkingDir+'/*.XPR '+ ApacheCaseDir)
				#os.system('cp '+WorkingDir+'/*.XTF '+ ApacheCaseDir)




		    	return HttpResponseRedirect(reverse('Dynamfit.views.sampleinput'))

		else:
			print 'NOT VALID'

		# Render list page with the documents and the form
		return render_to_response('DynamfitExampleInput.html', locals(),
			context_instance=RequestContext(request))
	else:
		return redirect('/login')
	
def samplerun(request):
	if request.user.is_authenticated():
		Eprime = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/exampleE.jpg'
		EEprime = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/exampleEE.jpg'
		XPR_link = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XPR'
		XFF_link = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XFF'
		XTF_link = 'http://nanomine.northwestern.edu/nanomine/Dynamfit/EXAMPLE.XTF'
				
		return render_to_response("DynamfitExampleRun.html", 
					{'E_link': Eprime, 'EE_link': EEprime, 'XPR_link': XPR_link, 'XFF_link': XFF_link, 'XTF_link': XTF_link},
					context_instance=RequestContext(request))
	else:
		return redirect('/login')
