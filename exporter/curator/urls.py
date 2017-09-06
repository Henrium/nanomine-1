from django.conf.urls import patterns, url, include

urlpatterns = patterns('',
   url('', include('exporter.curator.json.urls')),
   url('', include('exporter.curator.blob.urls')),
)

