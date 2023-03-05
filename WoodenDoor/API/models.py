from django.db import models
from django.db import connection

# Create your models here.

class User(models.Model):
    fname = models.CharField(max_length=50)
    lname = models.CharField(max_length=50)
    bdate =models.DateField(auto_now=True)
    sex = models.CharField(max_length=1)
    email = models.EmailField(_("email key"), max_length=254, null=False)
    
def qurey1():
    with connection.cursor() as cursor:
        cursor.execute("select * from user_feild")
        res = cursor.fetchone()
    return res