from django.db import models
from django.db import connection

# Create your models here.

class User1(models.Model):
    fname = models.CharField(max_length=50)
    lname = models.CharField(max_length=50)
    bdate =models.DateField(auto_now=True)
    sex = models.CharField(max_length=1)
    email = models.EmailField(primary_key=True, max_length=254)

# class Company(models.Model):
#     cname = models.CharField(max_length=50)
#     noe = models.DecimalField()
#     crn = models.CharField(max_length=20, primary_key=True)
#     email = models.models.models.ForeignKey("Employer", verbose_name=_(""), on_delete=models.CASCADE)
#     country = models.CharField(max_length=20)
#     city = models.CharField(max_length=20)
#     com_address = models.CharField(max_length=50)

# class Employer(models.Model):
#     position = models.models.CharField(_(""), max_length=20)
#     email = models.models.ForeignKey(User, verbose_name=_(""), on_delete=models.CASCADE)
#     crn = models.models.ForeignKey(Company, verbose_name=_(""), on_delete=models.CASCADE)

# class Applicant(models.Model):
#     email = models.ForeignKey(User, verbose_name=_(""), on_delete=models.CASCADE)
#     country = models.CharField(max_length=20)
#     city = models.CharField(max_length=20)
#     com_address = models.CharField(max_length=50)
#     req_salary = models.BigIntegerField(_(""))

# class Job_ad(models.Model):
#     jdate = models.DateTimeField(_(""), auto_now=True, auto_now_add=True)
#     title = models.CharField(_(""), max_length=50)
#     visibility = models.BooleanField(_(""))
#     jstate = models.CharField(_(""), max_length=10)
#     email = models.ForeignKey(Employer, verbose_name=_(""), on_delete=models.CASCADE)
#     country = models.CharField(max_length=20)
#     city = models.CharField(max_length=20)
#     com_address = models.CharField(max_length=50)
#     job_description = models.TextField(_(""))
    
# class post(models.Model):
#     ptext = models.TextField(_(""))
#     pstate = models.CharField(_(""), max_length=10)
#     pdate = models.DateTimeField(_(""), auto_now=True, auto_now_add=True)
#     email = models.ForeignKey(User, verbose_name=_(""), on_delete=models.CASCADE)

# class Expreience(models.Model):
#     email = models.ForeignKey(Applicant, verbose_name=_(""), on_delete=models.CASCADE)
#     title = models.CharField(_(""), max_length=50) 
#     details = models.TextField(_(""))
#     company = models.CharField(_(""), max_length=20,primary_key=True)
#     salary = models.BigIntegerField(_(""))
#     startdate = models.DateField(_(""), auto_now=False, auto_now_add=False)
#     enddate = models.DateField(_(""), auto_now=False, auto_now_add=False)

def qurey1():
    with connection.cursor() as cursor:
        cursor.execute("select * from job_ad")
        res = cursor.fetchone()
    return res