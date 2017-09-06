# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('Two_pt_MCR', '0004_auto_20170826_0134'),
    ]

    operations = [
        migrations.AlterField(
            model_name='document',
            name='docfile',
            field=models.FileField(upload_to=b'./Two_pt_MCR/media/documents/%Y/%m/%d/%H/Target.jpg'),
        ),
    ]
