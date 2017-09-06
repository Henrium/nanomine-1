from django.conf.urls import patterns, url

urlpatterns = patterns('',
   url('', 'exporter.curator.blob.models.BLOBExporter', {'name': 'BLOB', 'available_for_all': True}),
)

