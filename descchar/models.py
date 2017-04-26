from django.db import models
from django.utils.encoding import smart_unicode
# Create your models here.
                
class Document(models.Model):
    
    # update count
    f = open('./descchar/RunCount.num', 'r+')
    count = f.readlines()

    # docfile = models.FileField(upload_to='/home/NANOMINE/nmdata/descchar/documents/%Y/%m/%d')
    docfile = models.FileField(upload_to='./descchar/media/documents/%Y/%m/%d/'+count[0])