from django.db import models
from django.utils.encoding import smart_unicode

class FEAInput(models.Model):
        Volume_Fraction = models.CharField(max_length=120, null=True, blank=False)
        Interphase_Thickness = models.CharField(max_length=120, null=True, blank=True)
        email = models.EmailField()

def __unicode__(self):
		return smart_unicode(self.email)

#class EnterEmail(models.Model):
#    	email = models.EmailField()
#        def __unicode__(self):
#		return smart_unicode(self.email)
#
#class EnergyCompute(models.Model):
#	#code
#	Short_Brush_Dieletric_Constant = models.CharField(max_length=120, null=True, blank=False)
#	Short_Brush_Refrative_Index = models.CharField(max_length=120, null=True, blank=False)
#	Volumn_Fraction = models.CharField(max_length=120, null=True, blank=False, value='2.6')
#	Functional_Group_Dielectric_Constant = models.CharField(max_length=120, null=True, blank=False)
#	Functional_Group_Refrative_Index = models.CharField(max_length=120, null=True, blank=False)
#	Volumn_Fraction= models.CharField(max_length=120, null=True, blank=False)
#	Number_of_Grafted_Chains_per_Particle = models.CharField(max_length=120, null=True, blank=False)
#	Short_Brush_Dieletric_Constant = models.CharField(max_length=120, null=True, blank=False)
	