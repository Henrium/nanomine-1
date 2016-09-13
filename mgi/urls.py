################################################################################
#
# File Name: urls.py
# Application: mgi
# Purpose:   
#
# Author: Sharief Youssef
#         sharief.youssef@nist.gov
#
#         Guillaume SOUSA AMARAL
#         guillaume.sousa@nist.gov
#
# Sponsor: National Institute of Standards and Technology (NIST)
#
################################################################################

from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

urlpatterns = patterns('',
    url(r'^$', 'mgi.views.home', name='home'),
    url(r'^admin/', include('admin_mdcs.urls')),
    url(r'^curate/', include('curate.urls')),
    url(r'^explore/', include('explore.urls')),
    url(r'^compose/', include('compose.urls')),
    
    # naonomine
    url(r'^FEA2D/', include('FEA2D.urls')),
    url(r'^MCFEA/', include('MCFEA.urls')),
    url(r'^descchar/', 'descchar.views.home',name='descchar'),
    url(r'^descchar_view$', 'descchar.views.check', name='descchar-check'),
    url(r'^niblack/', 'niblack.views.home',name='niblack'),
    url(r'^niblack_view$', 'niblack.views.check', name='niblack-check'),    
    url(r'^stats_tool/', 'mgi.views.stats_tool', name='stats_tool'),
    url(r'^simulate_tool/', 'mgi.views.simulate_tool', name='simulate_tool'),
    #url(r'^dynamfit/', include('Dynamfit.urls')),
    url(r'^dynamfit/', 'Dynamfit.views.home', name='dynamfit'),
    url(r'^DynamfitRun$', 'Dynamfit.views.runmodel', name='dynamfit_runmodel'),
    url(r'^DynamfitExample$', 'Dynamfit.views.sample', name='dynamfit_sample'),
    url(r'^DynamfitExampleInput$', 'Dynamfit.views.sampleinput', name='dynamfit_sampleinput'),
    url(r'^DynamfitExampleRun$', 'Dynamfit.views.samplerun', name='dynamfit_samplerun'),
    #url(r'^AUTOFIT/', include('AUTOFIT.urls')),
    url(r'^AUTOFIT/', 'AUTOFIT.views.home', name='AUTOFIT'),
    url(r'^AUTOFITRun$', 'AUTOFIT.views.runmodel', name='AUTOFIT_runmodel'),
    url(r'^AUTOFITCheck$', 'AUTOFIT.views.check', name='AUTOFIT_check'),
    url(r'^AUTOFITSample$', 'AUTOFIT.views.sample', name='AUTOFIT.sample'),
    url(r'^RECON/', 'RECON.views.home', name='RECON'),
    url(r'^RECONRun$', 'RECON.views.runmodel', name='RECON_runmodel'),
    url(r'^RECONCheck$', 'RECON.views.check', name='RECON_check'),
    url(r'^RECONSample$', 'RECON.views.sample', name='RECON_sample'),
    url(r'^XMLCONV/', 'XMLCONV.views.home', name='XMLCONV'),
    # search
    url(r'^search/', 'search.views.index', name='search'),
    url(r'^notify/', 'mgi.views.notify', name='notify'),
    ###    
    
    url(r'^rest/', include('api.urls')),
    url(r'^modules/', include('modules.urls')),
    url(r'^docs/api', include('rest_framework_swagger.urls')),
    url(r'^all-options', 'mgi.views.all_options', name='all-options'),
    url(r'^browse-all', 'mgi.views.browse_all', name='browse-all'),
    url(r'^login', 'django.contrib.auth.views.login',{'template_name': 'login.html'}),
    url(r'^request-new-account', 'mgi.views.request_new_account', name='request-new-account'),   
    url(r'^logout', 'mgi.views.logout_view', name='logout'),
    url(r'^my-profile$', 'mgi.views.my_profile', name='my-profile'),
    url(r'^my-profile/edit', 'mgi.views.my_profile_edit', name='my-profile-edit'),
    url(r'^my-profile/change-password', 'mgi.views.my_profile_change_password', name='my-profile-change-password'),
    url(r'^my-profile/my-forms', 'mgi.views.my_profile_my_forms', name='my-profile-my-forms'),
    url(r'^my-profile/resources$', 'mgi.views.my_profile_resources', name='my-profile-resources'),
    url(r'^help', 'mgi.views.help', name='help'),
    url(r'^contact', 'mgi.views.contact', name='contact'),
    url(r'^privacy-policy', 'mgi.views.privacy_policy', name='privacy-policy'),
    url(r'^terms-of-use', 'mgi.views.terms_of_use', name='terms-of-use'),
    url(r'^o/', include('oauth2_provider.urls', namespace='oauth2_provider')),
    url(r'^dashboard$', 'mgi.views.dashboard', name='dashboard'),
)+static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)


urlpatterns += staticfiles_urlpatterns()



