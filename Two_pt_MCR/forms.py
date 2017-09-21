from django import forms

Correlation_fns = (
		  (1,('2 Point Autocorrelation')),
		  (2,('2 Point Lineal Path Correlation')),
		  (3,('2 Point Cluster Correlation')),
		  (4,('2 Point Surface Correlation')),)
Input_types = (
	      (1,('Single JPEG image')),
	      (3,('Single Image in .mat format')),
	      (2,('ZIP File containing multiple JPEG images')),)

class DocumentForm(forms.Form):
	docfile = forms.FileField(
		label ='Select File'
	)
	email_id = forms.EmailField(
		 label='Enter Email address to receive Job ID:',required=False
	)
	num_recon = forms.IntegerField(
		 label='Enter number of reconstruction',required=False,initial=1,min_value=1
	)
	correlation_choice = forms.ChoiceField(
		label='Select Correlation',choices=Correlation_fns,required=False,initial=''
	)
	Characterize_input_type = forms.ChoiceField(
		label='Select Input Option',choices=Input_types,required=False,initial=''
	)

