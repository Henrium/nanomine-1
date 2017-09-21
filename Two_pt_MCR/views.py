from django.shortcuts import render_to_response, render, RequestContext, redirect
from django.template import RequestContext, loader
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from django.utils.encoding import smart_unicode
from time import gmtime, strftime, localtime

from django.template import Context
from contextlib import contextmanager


from Two_pt_MCR.models import Document
from Two_pt_MCR.forms import *

import xmltodict
import os
import subprocess
import scipy.io
# Create your views here.

def Reconstruction_Choice(request):
        if request.user.is_authenticated():
                return render_to_response('MCR_Reconstruction_Choice.html')
        else:
                return('/login')


def submit_image(request):
	if request.user.is_authenticated():
	    # Handle file upload
	    if request.method == 'POST':
		form = DocumentForm(request.POST, request.FILES)
		if form.is_valid():
		    newdoc = Document(docfile = request.FILES['docfile'])
		    newdoc.save()
		    work_dir = '/home/NANOMINE/Develop/mdcs'
		    os.chdir(work_dir)
		    os.system('pwd')
		    user_email_id = request.POST['email_id']
		    if not user_email_id:
			 return HttpResponse('<h3>Please provide an email address to receive Job ID!</h3>') #if no email id was provided, report error

		    user_name = None
                    user_name = request.user.username
		    num_recon = request.POST['num_recon']
		    correlation_choice = request.POST['correlation_choice']
		    # Run MATLAB when file is valid
		    os.system('matlab -nodesktop -nodisplay -nosplash -r "cd /home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles;run_2ptMCR('"'+str(user_name)+'"',"'+str(num_recon)+'","'+str(correlation_choice)+'");exit"')
		    file = open("/home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles/RunCount.num","r")
                    count = file.readlines()
                    print count[len(count)-1]
                    file.close
                    #if user_email_id:
		    mail_to_user = 'sendmail ' + user_email_id + ' < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt'
		    os.system(mail_to_user)
		    os.system('sendmail back2akshay@gmail.com < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt')
                    return render_to_response("Two_pt_MCR_submission_notify.html")
		else:
                    return HttpResponse('<h3>Please upload an image Xiaolin!</h3>') # if no image was uploaded, report error

	    else:
		form = DocumentForm() # A empty, unbound form

	    # Load documents for the list page
	        documents = Document.objects.all()
	    # Render list page with the documents and the form
	        return render_to_response(
		'Two_pt_MCR_submit_image.html',
		{'documents': documents, 'form': form},
		context_instance=RequestContext(request)
	        )
	else:
		return redirect('/login')

def landing(request):
	if request.user.is_authenticated():
		return render_to_response(('Two_pt_MCR_landing.html'))
	else:
		return redirect('/login')

def checkResult(request):
	if request.user.is_authenticated():
		return render_to_response('Two_pt_MCR_Check_Result.html')
	else:
		return redirect('/login')

def viewResult(request):
	if request.user.is_authenticated():
		return render_to_response('Two_pt_MCR_view_result.html')
	else:
		return('/login')

def submission_notify(request):
	if request.user.is_authenticated():
		return render_to_response('Two_pt_MCR_submission_notify.html')
	else:
		return('/login')

def Characterize_Choice(request):
	if request.user.is_authenticated():
		return render_to_response('MCR_Characterize_Choice.html')
	else:
		return('/login')

def Characterize_Check_Result(request):
	if request.user.is_authenticated():
                return render_to_response('MCR_Characterize_Check_Result.html')
        else:
                return('/login')

def Characterize_view_result(request):
	if request.user.is_authenticated():
                return render_to_response('MCR_Characterize_view_result.html')
        else:
                return('/login')


def Characterize(request):
	if request.user.is_authenticated():
	  if request.method == "POST":
		form = DocumentForm(request.POST, request.FILES)
		if form.is_valid():
		    newdoc = Document(docfile = request.FILES['docfile'])
		    newdoc.save()

		    user_email_id = request.POST['email_id']
		    if not user_email_id:  # if no email provided, report error
			return HttpResponse('<h3>Please provide an email address to receive Job ID!</h3>')
		    work_dir = '/home/NANOMINE/Develop/mdcs'
		    os.chdir(work_dir)
		    os.system('pwd')
		    input_type = request.POST['Characterize_input_type']
		    correlation_choice = request.POST['correlation_choice']
		    user_name = None
		    user_name = request.user.get_username()
		    print (user_name)
		    # Run MATLAB when file is valid
		    os.system('matlab -nodesktop -nodisplay -nosplash -r "cd /home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles;Characterize("'+user_name+'","'+str(input_type)+'","'+str(correlation_choice)+'");exit"')
		    file = open("/home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles/RunCount.num","r")
                    count = file.readlines()
                    print count[len(count)-1]
                    file.close
            	    
		    mail_to_user = 'sendmail ' + user_email_id + ' < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt'
		    os.system(mail_to_user)
		    os.system('sendmail back2akshay@gmail.com < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt')
                    return render_to_response("MCR_Characterize_Check_Result.html")
		else:
		    return HttpResponse('<h3>Please upload an image Xiaolin!</h3>') # if no image was uploaded, report error
	  else:
		form = DocumentForm()
		documents = Document.objects.all()
		return render_to_response('Two_pt_MCR_Characterize.html',{'documents': documents, 'form': form},context_instance=RequestContext(request))
	else:
		return('/login')

def Correlation_Fundamentals(request):
	if request.user.is_authenticated():
		return render_to_response('MCR_Correlation_Fundamentals.html')
	else:
		return('/login')

def SDF(request):
	if request.user.is_authenticated():
                return render_to_response('SDF.html')
        else:
                return('/login')
