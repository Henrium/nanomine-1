################################################################################
#
# File Name: urls.py
# Application: search
# Purpose:   
#
# Modified by: He Zhao, Aug 17, 2015
# Customized for NanoMine
#
################################################################################

from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       url(r'^$', 'search.views.home', name='home'),
                       url(r'^search_result(?P<titleId>\w{0,50})/$', 'search.views.ShowResult', name='ShowResult'),
                       url(r'^search_property$', 'search.views.SearchProperty', name='SearchProperty')
                        )