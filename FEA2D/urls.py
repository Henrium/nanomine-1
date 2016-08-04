################################################################################
#
# File Name: urls.py
# Application: FEA2D
# Purpose:   
#
# Modified by: He Zhao, Aug 17, 2015
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url

#from FEA2D import views

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'FEA2D.views.home', name='home'),
                        url(r'^DielectricFEA2DValidateInput$', 'FEA2D.views.validate', name='validate'),
                        url(r'^DielectricFEA2DRun$',  'FEA2D.views.runmodel', name='runmodel'),
                        url(r'^DielectricFEA2DResultSample$', 'FEA2D.views.sample', name='resultSample'),
                        url(r'^DielectricFEA2DCheckProgress$', 'FEA2D.views.check', name='check'),                       
			#url(r'^DielectricFEA2DWait$', 'FEA2D.views.wait', name='wait'),
                       )
