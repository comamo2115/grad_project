# Generated by Django 4.2.23 on 2025-06-26 06:39

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recommend', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Schedule',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('user_uid', models.CharField(max_length=128)),
                ('date', models.DateField()),
                ('title', models.CharField(max_length=100)),
                ('source', models.CharField(choices=[('manual', '수동 입력'), ('google', '구글 캘린더'), ('apple', '애플 캘린더')], default='manual', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.AlterField(
            model_name='clothingitem',
            name='category',
            field=models.CharField(choices=[('TOPS', '상의'), ('BOTTOMS', '하의'), ('OUTER', '아우터'), ('ONEPIECE', '원피스'), ('ETC', '기타')], max_length=20),
        ),
    ]
