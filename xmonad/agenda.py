#!/usr/bin/python3

from __future__ import print_function

from dateutil import parser
import datetime
import os.path
import pathlib
import pickle
from math import trunc
import pytz

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

ROOT_DIR = str(pathlib.Path(__file__).parent.resolve())
CREDS_FILE = ROOT_DIR + "/credentials.json"
CACHE_FILE = str(os.path.expanduser("~/.agenda"))
TOKEN_FILE = ROOT_DIR + "/.agenda_token"

def get_event_list():
    event_list = list()
    now = datetime.datetime.now()
    if os.path.exists(CACHE_FILE) and \
        (now - datetime.datetime.fromtimestamp(
                os.path.getmtime(CACHE_FILE))).total_seconds() < 3600:
        with open(CACHE_FILE, "rb") as f:
            event_list = pickle.load(f)
    else:
        creds = None
        # The file token.json stores the user's access and refresh tokens, and is
        # created automatically when the authorization flow completes for the first
        # time.
        if os.path.exists(TOKEN_FILE):
            creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
        # If there are no (valid) credentials available, let the user log in.
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    CREDS_FILE, SCOPES)
                creds = flow.run_local_server(port=0,
                    authorization_prompt_message="",
                    success_message="")
            # Save the credentials for the next run
            with open(TOKEN_FILE, 'w') as token:
                token.write(creds.to_json())

        try:
            service = build('calendar', 'v3', credentials=creds)

            # Call the Calendar API
            now = datetime.datetime.utcnow().isoformat() + 'Z'  # 'Z' indicates UTC time
            events_result = service.events().list(calendarId='primary', timeMin=now,
                                                  maxResults=12, singleEvents=True,
                                                  orderBy='startTime').execute()
            events = events_result.get('items', [])
            if not events:
                print('No upcoming events found.')
                return event_list

            event_list = []
            # Prints the start and name of the next 10 events
            for event in events:
                start = event['start'].get('dateTime', event['start'].get('date'))
                end = event['end'].get('dateTime', event['end'].get('date'))
                event_list.append((parser.parse(start),
                                  parser.parse(end),
                                  event['summary']))
            with open(CACHE_FILE, "wb") as f:
                pickle.dump(event_list, f, protocol=pickle.HIGHEST_PROTOCOL)
        except HttpError as error:
            print('An error occurred: %s' % error)

    return event_list

def pprinttd(td):
    h = td.seconds//3600
    mins = (td.seconds/60) % 60
    m = trunc(mins)
    s = trunc((mins-m)*60)

    return str(h).rjust(2,'0') + ":" + str(m).rjust(2,'0') + ":" + str(s).rjust(2,'0')

if __name__ == '__main__':
    event_list = get_event_list()
    now = datetime.datetime.utcnow().replace(tzinfo=pytz.utc)
    current_event = None
    current_event_duration = 999999999
    next_event = None
    next_event_duration = 0
    for e in event_list:
        if e[0] < now and e[1] > now and (e[1]-e[0]).total_seconds() < current_event_duration:
            current_event = e
            current_event_duration = (e[1]-e[0]).total_seconds()
        elif e[0] > now and ((next_event is None) or (next_event[0]>e[0] or ((next_event[0]==e[0]) and next_event_duration > (e[1]-e[0]).total_seconds()))):
            next_event = e
            next_event_duration = (e[1]-e[0]).total_seconds()
    output = ""
    if current_event is not None:
        output += current_event[2] + " | " + pprinttd(current_event[1]-now)
    output += " | "
    if next_event is not None:
        output += pprinttd(next_event[0]-now) + " | " + next_event[2]
    print(output)

