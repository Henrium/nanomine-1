################################################################################
#
# File Name: urls.py
# Application: FEA2D
# Purpose:   
#
# Modified by: Zijiang Yang, June 07, 2016
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'RECON.views.home', name='home'),
                       url(r'^RECONRun$', 'RECON.views.runmodel', name='runmodel'),
                       url(r'^RECONCheck$',  'RECON.views.check', name='check'),
                       url(r'^RECONSample$', 'RECON.views.sample', name='sample'),
                       #url(r'^DynamfitExampleInput$', 'Dynamfit.views.sampleinput', name='sampleinput'),                       
                       )    