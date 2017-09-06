# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('Two_pt_MCR', '0002_auto_20170826_0100'),
    ]

    operations = [
        migrations.AlterField(
            model_name='document',
            name='docfile',
            field=models.FileField(upload_to=b'./Two_pt_MCR/media/documents/%Y/%M/%d25\n/'),
        ),
    ]
