################################################################################
#
# File Name: urls.py
# Application: MCFEA
# Purpose:   
#
# Modified by: He Zhao, June 1, 2016
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url


urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'MCFEA.views.home', name='home'),
                       url(r'^MCFEAValidateInput$', 'MCFEA.views.validate', name='validate'),
                       url(r'^MCFEARun$',  'MCFEA.views.runmodel', name='runmodel'),
                       url(r'^MCFEAResultSample$', 'MCFEA.views.sample', name='resultSample'),
                       url(r'^MCFEACheckProgress$', 'MCFEA.views.check', name='check'),                       
                       )
