from django.shortcuts import render, render_to_response, RequestContext, redirect
from django.template import RequestContext
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse

import os, random, getpass

from time import gmtime, strftime
from operator import itemgetter

import time, math
import numpy as np
import random

str_OpenPort = '~/comsol52/bin/comsol server -port 2036 &'
		                
# MATLAB commands to add path and connect to port
str_PATH = "addpath('/home/NANOMINE/comsol52/mli','/home/NANOMINE/comsol52/mli/startup');"
str_PathPort = str_PATH + "mphstart(2036);"

str_matlab_run_model ='nohup matlab -nodesktop -nosplash -nodisplay -r "cd /home/NANOMINE/Desktop/Zijiang_backup/yixing_doe_v1/FEA50DOE;'+ str_PathPort +' comsol_conf();exit" > ./a.log &'        
print 'Run MATLAB shell command:'
print str_matlab_run_model