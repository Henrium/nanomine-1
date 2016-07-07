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
                       #url(r'^DynamfitUpload$', 'Dynamfit.views.upload', name='upload'),
                       url(r'^DynamfitRun$',  'Dynamfit.views.runmodel', name='runmodel'),
                        # url(r'^DielectricFEA2DResultSample$', 'FEA2D.views.sample', name='resultSample'),
                        # url(r'^DielectricFEA2DCheckProgress$', 'FEA2D.views.check', name='check'),                       
                       )    
