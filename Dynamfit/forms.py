from django import forms
from .models import *

class DocumentForm(forms.Form):
    docfile = forms.FileField(
        label='Select file'
    )
