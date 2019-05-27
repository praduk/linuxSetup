#!guicmd.py

from socket import *
from datetime import *
import pickle
import thread
import time
piUnits=["pi0", "pi1", "pi2", "praduSpectre", "blueideal"]

def dumpToPi(pi,x):
    try:
       sock = socket(AF_INET, SOCK_DGRAM)
       sock.sendto(x,(gethostbyname(pi+".local"),54321))
    except:
        print('Cannot connect to ' + pi)
def broadcast(data):
    x = pickle.dumps(data)
    for pi in piUnits:
        thread.start_new_thread(dumpToPi,(pi,x))

broadcast(("timer",datetime.now()+timedelta(seconds=60)))
time.sleep(0.25)
