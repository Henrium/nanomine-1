from django import forms

Correlation_fns = (
		  (1,('2 Point Autocorrelation')),
		  (2,('2 Point Lineal Path Correlation')),
		  (3,('2 Point Cluster Correlation')),
		  (4,('2 Point Surface Correlation')),)

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

#class Email_address(forms.Form):
#	email_id = forms.CharField(label='Enter Email address to receive Job ID:',max_length=200)

