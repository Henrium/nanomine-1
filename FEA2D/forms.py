from django import forms
from .models import *

class FEAInputForm(forms.ModelForm):
	class Meta:
		model = FEAInput


#class EmailForm(forms.Form):
#	class Meta:
#		model = EnterEmail
		
POLYMER_CHOICES = (
    #('OrSelect', 'Choose Polymer'),
    ('', 'Choose Polymer'),    
    ('epoxy', '1.Epoxy'),
)

PARTICLE_CHOICES = (
    #('OrSelect', 'Choose Particle'),
    ('', 'Choose Particle'),    
    ('SiO2', '1.Silica nanoparticles'),
)

GRAFT_CHOICES = (
    #('OrSelect', 'Choose Particle Surface Treatment'),
    ('', 'Choose Particle Surface Treatment'),

    ('bare', '0.No surface treatment'),
    ('monoPGMA', '1.monomodal PGMA'),
    ('ferroPGMA', '2.bimodal PGMA-ferrocene'),
    ('terthiophenePGMA', '3.bimodal PGMA-terthiophene'),
    ('monothiophenePGMA', '4.bimodal PGMA-monothiophene'),
    ('anthraenePGMA', '5.bimodal PGMA-anthraene'),
)

class MaterialsForm(forms.Form):
	polymer = forms.ChoiceField(required=True,widget=forms.Select, choices=POLYMER_CHOICES)
	particle = forms.ChoiceField(required=True,widget=forms.Select, choices=PARTICLE_CHOICES)
	graft = forms.ChoiceField(required=True,widget=forms.Select, choices=GRAFT_CHOICES)
#class ParticleForm(forms.Form):
#	particle = forms.ChoiceField(required=False,widget=forms.Select, choices=PARTICLE_CHOICES)
#	
#class GraftForm(forms.Form):
#
	