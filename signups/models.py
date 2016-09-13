from django.db import models
from django.utils.encoding import smart_unicode

# Create your models here.
class SignUp(models.Model):
    email = models.EmailField(max_length=254, null=False, blank=False)#, unique=True)
    full_name = models.CharField(max_length=120, null=True, blank=True)
    is_active = models.BooleanField(default=False)
    timestamp = models.DateTimeField(auto_now_add=True, auto_now=False)
    updated= models.DateTimeField(auto_now_add=False, auto_now=True)
    
    def __unicode__(self):
        return smart_unicode(self.email)