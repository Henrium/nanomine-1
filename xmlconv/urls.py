from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'xmlconv.views.home', name='home'),
                       #url(r'^XMLCONVRun$', 'XMLCONV.views.runmodel', name='runmodel'),                   
                       )    