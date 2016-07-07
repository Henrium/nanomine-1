from django.db import models
from django.utils.encoding import smart_unicode

# Create your models here.
class Document(models.Model):
    docfile = models.FileField(upload_to='./Dynamfit/media')
