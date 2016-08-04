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
                       url(r'^$', 'Dynamfit.views.home', name='home'),
                       url(r'^DynamfitExampleRun$', 'Dynamfit.views.samplerun', name='samplerun'),
                       url(r'^DynamfitRun$',  'Dynamfit.views.runmodel', name='runmodel'),
                       url(r'^DynamfitExample$', 'Dynamfit.views.sample', name='sample'),
                       url(r'^DynamfitExampleInput$', 'Dynamfit.views.sampleinput', name='sampleinput'),                       
                       )    
