# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations


class Migration(migrations.Migration):

    dependencies = [
        ('admin_mdcs', '0003_auto_20160804_0349'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Subscription',
        ),
    ]
