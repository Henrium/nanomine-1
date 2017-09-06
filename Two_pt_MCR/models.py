from django.db import models
from django.utils.encoding import smart_unicode

# Create your models here.

class Document(models.Model):
        file = open("/home/NANOMINE/Develop/mdcs/Two_pt_MCR/mfiles/RunCount.num","r")
	count = file.readlines()
	print count[len(count)-1]
	file.close
                        
	docfile = models.FileField(upload_to='./Two_pt_MCR/media/documents/%Y/%m/%d/')

