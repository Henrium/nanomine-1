from django import forms

class DocumentForm(forms.Form):
    docfile = forms.FileField(
        label='Select file'
    )
    
class NiblackAdjustForm(forms.Form):
    adjust = forms.CharField(label='Enter Pixel Size to Adjust:', max_length=100)    