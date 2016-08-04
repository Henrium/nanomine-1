################################################################################
#
# File Name: urls.py
# Application: AUTOFIT
# Purpose:   
#
# Modified by: Zijiang Yang, July 20, 2016
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'AUTOFIT.views.home', name='home'),
                       url(r'^AUTOFITRun$', 'AUTOFIT.views.runmodel', name='runmodel'),
                       url(r'^AUTOFITCheck$',  'AUTOFIT.views.check', name='check'),
                       url(r'^AUTOFITSample$', 'AUTOFIT.views.sample', name='sample'),
                       #url(r'^DynamfitExampleInput$', 'Dynamfit.views.sampleinput', name='sampleinput'),                       
                       )    