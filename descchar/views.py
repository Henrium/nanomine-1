from django.shortcuts import render_to_response, render, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect, HttpResponse
from django.core.urlresolvers import reverse

from descchar.models import Document
from descchar.forms import DocumentForm

import xmltodict
import os
import scipy.io
# Create your views here.

def home(request):
	if request.user.is_authenticated():
	    # Handle file upload
	    if request.method == 'POST':
		print ('!!!!! METHOD CORRECT!!!!!')
		form = DocumentForm(request.POST, request.FILES)
		if form.is_valid():
		    newdoc = Document(docfile = request.FILES['docfile'])
		    newdoc.save()
		    print ('form valid')
		    # Run MATLAB when file is valid
		    os.system('matlab -nodesktop -nodisplay -nojvm -nosplash -logfile descchar_run.log -r "cd descchar/mfiles;run_descchar;exit"')
		    os.system('mv ./descchar/media/documents/jpg/image.jpg /var/www/html/nm/image.jpg')
		    os.system('cp ./descchar/mfiles/char_result/ch_result.mat /var/www/html/nm/ch_result.mat')
		    
		    # Redirect to the document list after POST
		    return HttpResponseRedirect(reverse('descchar.views.home'))
	    else:
		print 'FORM NOT VALID'
		form = DocumentForm() # A empty, unbound form

	    # Load documents for the list page
	    documents = Document.objects.all()
	      
	    # Render list page with the documents and the form
	    return render(request,
		'descchar.html', {'documents': documents, 'form': form},
		context_instance=RequestContext(request)
	    )
	else:
		return redirect('/login')
            
def check(request):  
	if request.user.is_authenticated():     
	    # Load selected descriptors from char result
	    if os.path.isfile('./descchar/mfiles/char_result/ch_result.mat'):
		mat = scipy.io.loadmat('./descchar/mfiles/char_result/ch_result.mat')
		n = int(round(mat['R_n'],0))
		rc = round(mat['P_awrc'][0][0],2)
		ncd = round(mat['P_ncd'][0][0],2)
		ar = round(mat['P_awar'][0][0],2)
		rnds = round(mat['P_rnds'][0][0],2)
		eccen = round(mat['P_eccen'][0][0],2)
		ornang = round(mat['P_ornang'][0][0],2)
		filename = mat['name'][0]
	    else:
		n =''
		rc = ''
		ncd = ''
		ar = ''
		rnds = ''
		eccen = ''
		ornang = ''
		filename = ''        
	    return render_to_response('descchar_view.html',
		                    {'name' : filename, 'n':n,'ar':ar,'rc':rc,'ncd':ncd,
		                        'rnds':rnds,'eccen':eccen,'ornang':ornang},
		                    context_instance=RequestContext(request)
		                      )
	else:
		return redirect('/login')
