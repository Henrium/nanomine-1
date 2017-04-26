from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       #url(r'^$', views.index, name='index'),
                       url(r'^$', 'descchar.views.home', name='home'),
                       url(r'^descchar_view$', 'descchar.views.check', name='check'),                       
                       )