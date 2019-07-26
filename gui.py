#!/usr/bin/env python3

import tkinter as tk
from tkinter import font as tkFont
import threading
import datetime

import pickle
import datetime
import suntime
import lifxlan
import colorsys
import socket
import _thread as thread
import threading
from queue import Queue
import subprocess
from time import sleep
from time import time

piUnits=["pi0", "pi1", "pi2", "praduSpectre", "blueideal"]

#UDP TCP-Server
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
sock.bind(("", 54321)) 
def dumpToPi(pi,x):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
        s.sendto(x,(socket.gethostbyname(pi+".local"),54321))
    except:
        pass
def broadcast(data):
    x = pickle.dumps(data)
    for pi in piUnits:
        if not pi==socket.gethostname():
            thread.start_new_thread(dumpToPi,(pi,x))

def send(data, socket):
    f = socket.makefile()
    pickle.dump(data, f)
    f.close()

def receive(socket):
    f = socket.makefile()
    data = pickle.load(f)
    f.close()
    return data

def tdhms(td):
    return td.seconds//3600, (td.seconds//60)%60, (td.seconds)%60
def tdtkcolor(td):
    x = td.seconds//60
    #x = td.seconds
    if x < 1:
        return ("yellow", "black") #00FFFF
    if x < 5:
        return ("red","white") #FFFF00
    if x < 10:
        return ("darkred","white") #FF0000
    if x < 20:
        return ("green", "white") #00FF00
    return ("blue","white")
    #if x < 30
    #    return "blue" #0000FF
    #return "dodgerblue"

sun = suntime.Sun(32.2226,360-110.9747)
def needLightsOn():
    sunrise = sun.get_local_sunrise_time() + datetime.timedelta(minutes=10)
    if (t.hour==sunrise.hour and t.minute<sunrise.minute) or t.hour<sunrise.hour:
        return True
    sunset  = sun.get_local_sunset_time() - datetime.timedelta(minutes=10)
    if (t.hour==sunset.hour and t.minute>sunset.minute) or t.hour>sunset.hour:
        return True
    return False
def wantOutsideLightsOn():
    t = datetime.datetime.now()
    if (t.hour==5 and t.minute<30) or t.hour<5:
        return False
    if (t.hour==22 and t.minute>15) or t.hour>22:
        return False
    sunrise = sun.get_local_sunrise_time() + datetime.timedelta(minutes=10)
    if (t.hour==sunrise.hour and t.minute<sunrise.minute) or t.hour<sunrise.hour:
        return True
    sunset  = sun.get_local_sunset_time() - datetime.timedelta(minutes=10)
    if (t.hour==sunset.hour and t.minute>sunset.minute) or t.hour>sunset.hour:
        return True
    return False

class LightManager():
    def __init__(self):
        self.lm=lifxlan.LifxLAN(1E3)
        haveLights=False
        while not haveLights:
            try:
                self.lights=dict()
                lightList = self.lm.get_lights()
                #for iter in range(0,4):
                #    lightList = list( set(lightList) | set(self.lm.get_lights()) )
                haveLights=True
            except:
                pass

        for light in lightList:
            self.lights[light.get_label()]=light
        names=self.lights.keys()
        names = sorted(names)
        print('Found Lights : ' + str(names) )
        #Make Outside Light Group
        self.outsideLights = list()
        for lightName in names:
            if lightName.startswith('Outside'):
                self.outsideLights.append(lightName)
        # If Off, power on but dim
        #for light in lightList:
        #    if not light.get_power():
        #        self.power([light.get_label()],True)
        #        self.setColor([light.get_label()],0,0,0,0)

    def getGroup(self,names):
        g = lifxlan.Group([])
        for name in names:
            if name in self.lights:
                g.add_device(self.lights[name])
        return g
    def power(self,names,flag,duration=0,rapid=True):
        group = self.getGroup(names)
        group.set_power(flag,duration,rapid)
    def togglePower(self,names,duration=0,rapid=True):
        group = self.getGroup(names)
        devlist = group.get_device_list()
        if len(devlist)>0:
            flag = not group.get_device_list()[0].get_power()
            group.set_power(flag,duration,rapid)
    def setColor(self,names,r,g,b,k,duration_s=0,rapid=True):
        #Convert Color and Duration
        (h,s,v) = colorsys.rgb_to_hsv(r,g,b)
        h = round(h*65535)
        s = round(s*65535)
        v = round(v*65535)
        k = round((9000-2500)*k+2500)
        color = [ h, s, v, k ]
        duration_ms = round(duration_s*1000)

        group = self.getGroup(names)
        group.set_color(color,duration_ms,rapid)
        sleep(0.001*duration_ms)
    def blinkColor(self,names,r,g,b,k,N=1,duration_s=1):
        #Convert Blink Color
        (h,s,v) = colorsys.rgb_to_hsv(r,g,b)
        h = round(h*65535)
        s = round(s*65535)
        v = round(v*65535)
        k = round((9000-2500)*k+2500)
        colorb = [ h, s, v, k ]

        #Other Setup
        cycle_ms = round(500*duration_s/N)
        group = self.getGroup(names)
        color0 = group.get_device_list()[0].get_color()

        #Blink Color
        for i in range(round(N)):
            group.set_color(colorb,cycle_ms,True)
            sleep(0.001*cycle_ms)
            group.set_color(color0,cycle_ms,True)
            sleep(0.001*cycle_ms)
        #Make sure Final Color is Good
        group.set_color(color0,0,True)
    def blinkToColor(self,names,r,g,b,k,N=1,duration_s=1):
        #Convert Blink Color
        (h,s,v) = colorsys.rgb_to_hsv(r,g,b)
        h = round(h*65535)
        s = round(s*65535)
        v = round(v*65535)
        k = round((9000-2500)*k+2500)
        colorb = [ h, s, v, k ]

        #Other Setup
        cycle_ms = round(500*duration_s/(N+0.5))
        group = self.getGroup(names)
        color0 = group.get_device_list()[0].get_color()

        #Blink Color
        group.set_color(colorb,cycle_ms,True)
        sleep(0.001*cycle_ms)
        for i in range(round(N)):
            group.set_color(color0,cycle_ms,True)
            sleep(0.001*cycle_ms)
            group.set_color(colorb,cycle_ms,True)
            sleep(0.001*cycle_ms)
        #Make sure Final Color is Good
        group.set_color(colorb,0,True)
    def parse(self,cmd):
        if len(cmd)==0 or (cmd[0]!='#' and cmd[0]!='!'):
            return
        checkHost=(cmd[0]!='!')
        cmd=cmd[1:]

        if checkHost:
            (hostname, cmd) = cmd.split(' ',1)
            if hostname!=socket.gethostname():
                return

        names = []
        while len(cmd)>0:
            (action, cmd) = cmd.split(' ',1)
            if action=='color':
                (r, g, b, k, d) = cmd.split(' ',5)
                r=float(r)
                g=float(g)
                b=float(b)
                k=float(k)
                d=float(d)
                self.setColor(names,r,g,b,k,d)
                break
            if action=='blink':
                (r, g, b, k, N, d) = cmd.split(' ',6)
                r=float(r)
                g=float(g)
                b=float(b)
                k=float(k)
                N=int(N)
                d=float(d)
                self.blinkColor(names,r,g,b,k,N,d)
                break
            if action=='blinkto' or action=='blinkTo':
                (r, g, b, k, N, d) = cmd.split(' ',6)
                r=float(r)
                g=float(g)
                b=float(b)
                k=float(k)
                N=int(N)
                d=float(d)
                self.blinkToColor(names,r,g,b,k,N,d)
                break
            if action=='power':
                state = cmd.strip()
                if state=='on' or state=='On' or state=='ON':
                    self.power(names,True)
                else:
                    self.power(names,False)
                break
            else:
                names.append(action)
    def setOutsideLights(self):
        if wantOutsideLightsOn():
            self.power(self.outsideLights,True)
        else:
            self.power(self.outsideLights,False)


lm = LightManager()
lm.setOutsideLights()
#lm.setColor(['Light0', 'Light1'],0,0,0,0)
#sleep(2)
#lm.setColor(['Light0'],1,1,1,0)
#lm.power(['Light0'],False)
#sleep(0.5)
#lm.power(['Light0'],True)
#sleep(2)
#lm.blinkColor(['Light0'],0,1,0,0,2,5.0)
#lm.power(['Light0'],False)
#sleep(1.0)

root=tk.Tk()
def mousex():
    return root.winfo_pointerx()-root.winfo_rootx()
def mousey():
    return root.winfo_pointery()-root.winfo_rooty()
float_font = tkFont.nametofont("TkDefaultFont")
fixed_font = tkFont.nametofont("TkFixedFont")
fixed_font.configure(size=16)


INFO_FONT=float_font.copy()
FINFO_FONT=fixed_font.copy()
FTRACK_FONT=fixed_font.copy()
FTRACK_FONT.configure(size=30)
DATE_FONT=float_font.copy()
DATE_FONT.configure(size=24)
TIME_FONT=float_font.copy()
TIME_FONT.configure(size=72)
FTIME_FONT=fixed_font.copy()
FTIME_FONT.configure(size=72)
LARG_FONT=float_font.copy()
LARG_FONT.configure(size=20)
FLARG_FONT=fixed_font.copy()
FLARG_FONT.configure(size=20)

def animate_frame(frame):
    if hasattr(frame,'animate'):
        frame.animate()
    for child in frame.children.values():
        animate_frame(child)

class Marquee(tk.Canvas):
    def __init__(self, parent, textin=" ", margin=0, borderwidth=0, relief='flat', updates=1, bg='black', fg='white', font=float_font):
        tk.Canvas.__init__(self, parent, borderwidth=borderwidth, relief=relief, bg=bg)
        self.count=0
        self.updates=updates

        # start by drawing the text off screen, then asking the canvas
        # how much space we need. Use that to compute the initial size
        # of the canvas.
        self.fg = fg
        self.bg = bg
        self.font = font
        self.config(background=self.bg)
        self.text = self.create_text(9000, -9000, text=textin, anchor="w", tags=("text",), fill=self.fg, font=self.font)
        (x0, y0, x1, y1) = self.bbox("text")
        width = (x1 - x0) + (2*margin) + (2*borderwidth)
        height = (y1 - y0) + (2*margin) + (2*borderwidth)
        self.configure(width=width, height=height)

        self.coords("text",0,int(self.winfo_height()/2))
        self.prevtext = textin

        # start the animation
        self.animating = True
        self.animate()


    def update_text(self, new_text):
        if self.prevtext == new_text:
            return
        self.prevtext = new_text
        self.delete(self.text)
        self.config(background=self.bg)
        self.text = self.create_text(0, int(self.winfo_height()/2), text=new_text, anchor="w", tags=("text",),fill=self.fg, font=self.font)
        if not self.animating:
            self.animating = True
            #self.animate()

    def animate(self):
        if not self.animating:
            return
        self.animating=False
        (x0, y0, x1, y1) = self.bbox("text")
        textWidth = x1-x0
        if textWidth<self.winfo_width():
            self.move("text", int((self.winfo_width()-textWidth)/2), 0)
            return
        self.animating=True
        y_mean = int(self.winfo_height()/2)
        self.count = self.count+1
        if self.count < 2:
            return
        self.count = 0
        if x1>self.winfo_width():
            self.move("text", -self.winfo_width(), 0)
        else:
            self.coords("text", 0, y_mean)

        # do again in a few milliseconds


class TimePage(tk.Frame):
    def __init__(self,parent):
        tk.Frame.__init__(self,parent)
        self.parent = parent
        #self.pack(fill=tk.BOTH, expand=True)

        #Timer
        self.timer = None

        #Date-Time and String
        self.prev_t = None
        self.next_t = None
        self.prev_s = ""
        self.prev_s = ""

        #self.prev=tk.Frame(self,bg="red")
        #self.prev.time = tk.Label(self.prev, anchor=tk.W, text="HHMMSS", font=FLARG_FONT, bg="red", fg="white")
        #self.prev.time.pack(side=tk.LEFT)
        ##self.prev.info = tk.Label(self.prev, anchor=tk.W, text="Going to go to school", font=LARG_FONT,bg="red", fg="white")
        ##self.prev.info.pack(side=tk.LEFT,expand=True)
        #self.prev.info = Marquee(self.prev,text="Going to go to school for a long time", font=FLARG_FONT)
        #self.prev.info.pack(side=tk.LEFT,expand=True)
        #self.prev.pack(fill=tk.X)


        self.next = lambda:0
        #self.prev.info = tk.Label(self, anchor=tk.W, text="Going to go to school", font=LARG_FONT,bg="red", fg="white")
        self.next.info = Marquee(self,textin="Time to next activity", font=FLARG_FONT)
        self.next.info.pack(fill=tk.X)
        self.next.time = tk.Label(self, text="HH:MM:SS", font=FTRACK_FONT, bg="blue", fg="white")
        self.next.time.pack(fill=tk.X)

        self.date = tk.Label(self, text="MON DD YYYY", font=DATE_FONT)
        self.date.pack(fill=tk.X)
        self.time = tk.Label(self, text="HH:MM:SS", font=FTIME_FONT)
        self.time.pack(fill=tk.BOTH,expand=True)


        #self.next = tk.Label(self, text="Next", font=LARG_FONT, bg="blue", fg="white")
        #self.next.pack(fill=tk.X)

        self.prev = lambda:0
        #self.prev.info = tk.Label(self, anchor=tk.W, text="Going to go to school", font=LARG_FONT,bg="red", fg="white")
        self.prev.time = tk.Label(self, text="HH:MM:SS", font=FTRACK_FONT, bg="red", fg="white")
        self.prev.time.pack(fill=tk.X)
        self.prev.info = Marquee(self,textin="Time in current activity", font=FLARG_FONT)
        self.prev.info.pack(fill=tk.X)


    def setActivity(self,time,string):
        t = datetime.datetime.now()
        if time < t:
            self.prev_t = time
            self.prev_s = string
        else:
            self.next_t = time
            self.next_s = string
    def setTimer(self,newTime):
        self.timer = newTime
    def stopTimer(self):
        self.timer = None

    def animate(self):
        t = datetime.datetime.now()
        if (self.timer is not None) and self.timer>t:
            self.date["text"]="TIMER"
            self.time["text"]="{:02d}:{:02d}:{:02d}".format(*tdhms(self.timer-t))
        else:
            self.date["text"]=t.strftime("%a, %b %d, %Y")
            self.time["text"]=t.strftime("%H:%M:%S")
            if (self.timer is not None):
                self.timer = None
                self.parent.alarmPage.setOffAlarm()

        # Preprocessing and Reminders
        if self.next_t is not None:
            if t > self.next_t:
                self.prev_t = self.next_t
                self.prev_s = self.next_s
                self.next_t = None

        # Display
        if self.prev_t is not None:
            tdiff = t - self.prev_t
            self.prev.time["text"] = "{:02d}:{:02d}:{:02d}".format(*tdhms(tdiff))
            (self.prev.time["bg"],self.prev.time["fg"]) = tdtkcolor(tdiff)
            self.prev.info.update_text(self.prev_s)
        else:
            self.prev.time["text"] = "--:--:--"
            self.prev.time["bg"] = "gray"
            self.prev.time["fg"] = "lightgray"
            self.prev.info.update_text(" ")
        if self.next_t is not None:
            tdiff = self.next_t - t
            self.next.time["text"] = "{:02d}:{:02d}:{:02d}".format(*tdhms(tdiff))
            (self.next.time["bg"],self.next.time["fg"]) = tdtkcolor(tdiff)
            self.next.info.update_text(self.next_s)
        else:
            self.next.time["text"] = "--:--:--"
            self.next.time["bg"] = "gray"
            self.next.time["fg"] = "lightgray"
            self.next.info.update_text(" ")
    def click(self):
        (x,y) = (mousex(),mousey())
        #if x > self.winfo_width()/2:
        hn = socket.gethostname()
        if hn=='pi0':
                if y <= self.winfo_height()/2:
                    lm.togglePower(['Light0'])
                else:
                    lm.togglePower(['Light1'])
        if hn=='pi1':
            if y <= self.winfo_height()/2:
                lm.togglePower(['Light2', 'Light3', 'Light4'])
            else:
                lm.togglePower(['Light1'])
        if hn=='pi2':
            if y <= self.winfo_height()/2:
                lm.togglePower(['Light5'])
            else:
                lm.togglePower(['Light1'])


class InfoPage(tk.Frame):
    def __init__(self,parent):
        tk.Frame.__init__(self,parent)
        self.parent = parent
        #self.pack(fill=tk.BOTH, expand=True)
class AlarmPage(tk.Frame):
    def __init__(self,parent):
        tk.Frame.__init__(self,parent)
        self.parent = parent
        #self.pack(fill=tk.BOTH, expand=True)
        self.t = datetime.datetime.now()
        self.text = tk.Label(self, text="HH:MM:SS", font=FTIME_FONT)
        self.text.pack(fill=tk.X, expand=True)
        self.active=False
        self.p = None
    def setOffAlarm(self):
        self.active=True
        self.t = datetime.datetime.now()
        self.parent.show_frame(self)
    def stopAlarm(self,event=None):
        self.active=False
        self.parent.show_frame(self.parent.timePage)
        if (self.p is not None) and (self.p.poll() is None):
            self.p.terminate()
    def animate(self):
        if not self.active:
            return
        t = datetime.datetime.now()
        if (t-self.t).total_seconds() > 600:
            self.stopAlarm()
            return
        if (self.p is None) or (self.p.poll() is not None):
            self.p = subprocess.Popen(["/usr/bin/aplay","-q","-N","/data/music/melody.wav"])
        self.text["text"] = "{:02d}:{:02d}:{:02d}".format(*tdhms(t-self.t))
        if self["bg"] == "darkblue":
            self["bg"] = "red"
            self.text["fg"] = "#22FF22"
            self.text["bg"] = "darkblue"
        elif self["bg"]=="green":
            self["bg"] = "darkblue"
            #self.text["fg"] = "#FF2222"
            #self.text["bg"] = "darkgreen"
            self.text["fg"] = "darkred"
            self.text["bg"] = "green"
        else:
            self["bg"] = "green"
            self.text["fg"] = "darkblue"
            self.text["bg"] = "red"
            #self.text["fg"] = "#2222FF"
            #self.text["bg"] = "darkred"

class NotifyPage(tk.Frame):
    def __init__(self,parent):
        tk.Frame.__init__(self,parent)
        self.parent = parent

        #Timer
        self.tNotify = None
        self.p = None

        #self.prev.info = tk.Label(self, anchor=tk.W, text="Going to go to school", font=LARG_FONT,bg="red", fg="white")
        self.title = tk.Label(self, text="Title", font=FTRACK_FONT, bg="darkblue", fg="white", anchor='w')
        self.title.pack(fill=tk.X)
        self.info = tk.Message(self, text="Notification Text", anchor='nw', font=FLARG_FONT, bg="darkgreen", fg="white", width=self.parent.width)
        self.info.pack(fill=tk.BOTH,expand=True)
    def notify(self,title,msg):
        if not self.parent.animated_frame == self.parent.timePage:
            return
        self.tNotify = datetime.datetime.now()
        self.title["text"] = title
        self.info["text"] = msg
        self.info["width"] = width=self.parent.width
        self.parent.show_frame(self)
        if (self.p is None) or (self.p.poll() is not None):
            self.p = subprocess.Popen(["/usr/bin/aplay","-q","-N","/data/music/fingersnap.wav"])
    def animate(self):
        if not self.parent.animated_frame == self:
            self.tNotify = None
        if (self.tNotify is not None) and (datetime.datetime.now()-self.tNotify).total_seconds()>10:
            self.tNotify = None
            self.parent.show_frame(self.parent.timePage)

class FullScreenApp(tk.Frame):
    dimensions="{0}x{1}+0+0"

    def __init__(self, master, **kwargs):
        tk.Frame.__init__(self,master)
        self.queue=Queue()
        self.master=master
        #self.height = 2*320
        #self.width = 2*480
        self.width=master.winfo_screenwidth()
        self.height=master.winfo_screenheight()

        if self.width>=640:
            self.height = 2*320
            self.width = 2*480

        master.geometry(self.dimensions.format(self.width, self.height))

        self.pack(side="top",fill=tk.BOTH,expand=True)
        self.grid_rowconfigure(0,weight=1)
        self.grid_columnconfigure(0,weight=1)

        self.timePage = TimePage(self)
        self.timePage.grid(row=0,column=0,sticky="nsew")
        self.alarmPage = AlarmPage(self)
        self.alarmPage.grid(row=0,column=0,sticky="nsew")
        self.notifyPage = NotifyPage(self)
        self.notifyPage.grid(row=0,column=0,sticky="nsew")

        self.show_frame(self.timePage)
        #self.show_frame(self.notifyPage)
        #self.show_frame(self.alarmPage)
        self.animate()

    def show_frame(self,frame):
        self.active_frame = frame
        frame.tkraise()

    def exit(self):
        self.master.quit()

    def animate(self):
        self.animated_frame = self.active_frame
        waitCount = 1000-int(round(time()%1*1000))
        if waitCount<500:
            waitCount = waitCount + 1000
        self.after( waitCount, self.animate )
        for child in self.children.values():
            if hasattr(child, 'animate'):
                animate_frame(child)
        try:
            while True:
                (f,args)=queue.get()
                f(*args)
        except:
            pass
        self.update_idletasks()
        t=datetime.datetime.now()
        if (t.minute%10)==0:
            lm.setOutsideLights()

        #b = tk.Button(self.master, text="Press me!", command=lambda: self.pressed())
        #b.place(relx=0.5, rely=0.5, anchor=tk.CENTER)
        #def pressed(self):
        #def print("clicked!")
    def click(self,event):
        if self.animated_frame == self.timePage:
            self.timePage.click()
        if self.animated_frame == self.alarmPage:
            self.alarmPage.stopAlarm()
            broadcast(("alarm",False))

#root.wm_attributes('-fullscreen','true')
root.option_add("*Font",float_font)
app=FullScreenApp(root)
#app.timePage.setActivity(datetime.datetime.now()-datetime.timedelta(minutes=1), "Test Previous Activity")
#app.timePage.setActivity(datetime.datetime.now()+datetime.timedelta(seconds=25), "Test Next Activity")
#app.alarmPage.setOffAlarm()
root.tk_setPalette(background="black", foreground="white")
root.bind('<Button-1>',app.click)

#Start TCP-Server
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) 
sock.bind(("", 54321)) 
def socketThread(sock,root,app,lm,q):
    while True:
        data, addr = sock.recvfrom(1024)
        data = pickle.loads(data)
        cmd = data[0]
        if cmd=="activity":
            t = data[1]
            s = data[2]
            app.timePage.setActivity(t,s)
        elif cmd=="alarm":
            if data[1]:
                app.alarmPage.setOffAlarm()
            else:
                app.alarmPage.stopAlarm()
        elif cmd=="light":
            print(str(data[1]))
            lm.parse('!' + data[1])
        elif cmd=="toggle":
            lm.togglePower(data[1],duration=0,rapid=True)
        elif cmd=="lightraw":
            lm.parse('#' + data[1])
        elif cmd=="timer":
            app.timePage.setTimer(data[1])
        elif cmd=="notify":
            app.notifyPage.notify(data[1],data[2])
        elif cmd=="stoptimer":
            app.timePage.stopTimer()
thread.start_new_thread(socketThread, (sock,root,app,lm,app.queue))

root.mainloop()
