from django.db import models
from django.utils.encoding import smart_unicode
# Create your models here.

class Document(models.Model):
    # find count
    with open('./niblack/RunCount.num', 'r') as f:
        count = f.readlines()

    
    docfile = models.FileField(upload_to='niblack/media/documents/%Y/%m/%d/'+count[0])
    