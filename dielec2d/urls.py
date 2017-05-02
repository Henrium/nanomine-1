from django.conf.urls import patterns, url

urlpatterns = patterns('',
                       url(r'^$', 'dielec2d.views.home', name='home'),
                        url(r'^DielectricFEA2DValidateInput$', 'dielec2d.views.validate', name='validate'),
                        url(r'^DielectricFEA2DRun$',  'dielec2d.views.runmodel', name='runmodel'),
                        url(r'^dielec2d_ResultSample$', 'dielec2d.views.sample', name='resultSample'),
                        url(r'^dielec2d_CheckProgress$', 'dielec2d.views.check', name='check'), )