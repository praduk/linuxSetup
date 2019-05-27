#!/usr/bin/env python3

import sys
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
        print("ERROR")
def broadcast(data):
    x = pickle.dumps(data)
    for pi in piUnits:
        thread.start_new_thread(dumpToPi,(pi,x))
    time.sleep(0.5)

if len(sys.argv)<2:
    exit(1)
cmd = sys.argv[1]
if cmd=="timer":
    if len(sys.argv)<3:
        exit(1)
    broadcast( ("timer", datetime.now()+timedelta(int(sys.argv[2])) ) )
elif cmd=="stoptimer":
    broadcast( ("stoptimer",) )
elif cmd=="alarm":
    broadcast( ("alarm",True) )
elif cmd=="alarmoff":
    broadcast( ("alarm",False) )
elif cmd=="light":
    dumpToPi(gethostname(), pickle.dumps(("light", " ".join(sys.argv[2:]))))
    time.sleep(0.5)
elif cmd=="lightraw":
    broadcast( ("lightraw"," ".join(sys.argv[2:]) ) )
