################################################################################
#
# File Name: urls.py
# Application: XMLCONV
# Purpose:   
#
# Modified by: Zijiang Yang, Aug. 17, 2016
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'XMLCONV.views.home', name='home'),
                       #url(r'^XMLCONVRun$', 'XMLCONV.views.runmodel', name='runmodel'),                   
                       )    