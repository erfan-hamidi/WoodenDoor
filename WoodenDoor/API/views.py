from django.shortcuts import render
#from API.models import *
from . import models
from django.http import HttpResponse
# Create your views here.
from django.core.serializers import serialize
import json

def index(req):
    res = models.qurey1()
    print(res)
    r = json.dumps(res)
    print(r)
    return HttpResponse(r)

def starting(req):
    return render(req, "API/index.html",{
        "job_ads" : [("sus","sd")]
    })