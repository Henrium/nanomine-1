# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import datetime


class Migration(migrations.Migration):

    dependencies = [
        ('admin_mdcs', '0002_subscription_is_active'),
    ]

    operations = [
        migrations.AddField(
            model_name='subscription',
            name='full_name',
            field=models.CharField(max_length=120, null=True, blank=True),
            preserve_default=True,
        ),
        migrations.AddField(
            model_name='subscription',
            name='timestamp',
            field=models.DateTimeField(default=datetime.date(2016, 8, 4), auto_now_add=True),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='subscription',
            name='updated',
            field=models.DateTimeField(default=datetime.date(2016, 8, 4), auto_now=True),
            preserve_default=False,
        ),
    ]
