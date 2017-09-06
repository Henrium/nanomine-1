from django.shortcuts import render_to_response, render, RequestContext, redirect
from django.template import RequestContext, loader
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse
from django.utils.encoding import smart_unicode
from time import gmtime, strftime, localtime

from Two_pt_MCR.models import Document
from Two_pt_MCR.forms import *

import xmltodict
import os
import subprocess
import scipy.io
# Create your views here.

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
		    file = open("/home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles/RunCount.num","r")
                    count = file.readlines()
                    print count[len(count)-1]
		    file.close

		    #os.system('mv ./Two_pt_MCR/media/documents/%Y/%m/%d/%H/Target.jpg ./Two_pt_MCR/media/documents/%Y/%m/%d/'+str(count[len(count)-1])+'/Target.jpg')
		    num_recon = request.POST['num_recon']
		    correlation_choice = request.POST['correlation_choice']
		    # Run MATLAB when file is valid
		    os.system('matlab -nodesktop -nodisplay -nosplash -r "cd /home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles;run_2ptMCR("'+str(num_recon)+'","'+str(correlation_choice)+'");exit"')
		    zip_dir = '/var/www/html/nm/Two_pt_MCR/'+str(count[len(count)-1])
		    os.chdir(zip_dir[:-1])
		    os.system('zip Target_and_Reconstructed_images.zip ./*')
		    os.system('pwd')
                   # os.system('zip ./Target ./*')
                    #if user_email_id:
		    mail_to_user = 'sendmail ' + user_email_id + ' < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt'
		    os.system(mail_to_user)
		    os.system('sendmail back2akshay@gmail.com < /home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt')
                    return render_to_response("Two_pt_MCR_submission_notify.html")
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
