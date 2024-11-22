#!/usr/bin/python3

"""
This script automates a project I had to do.
I was supposed to visit https://www.worldometers.info/world-population/
and write down data from the site MANUALLY.
Instead, I wrote a script to do it for me.
You can run it like this: `./population_data.py >> data.txt` in a Unix shell.

Requirements: python3, requests-html and optionally notify-send
"""

from datetime import datetime
import subprocess
import time
from requests_html import HTMLSession

# No main function, its just a shell script
time.sleep(10)
try:
    # Its a mess
    formatted_date = datetime.now().strftime("%Y-%m-%d-%H-%M")
    session = HTMLSession()

    url = "https://www.worldometers.info/world-population/"
    response = session.get(url)

    response.html.render(sleep=3)

    population_element = response.html.find("div.maincounter-number span", first=True)
    current_population = population_element.text if population_element else 'Not found'

    births_today_element = response.html.find("span.rts-counter[rel='births_today']", first=True)
    deaths_today_element = response.html.find("span.rts-counter[rel='dth1s_today']", first=True)

    current_births = births_today_element.text if births_today_element else 'Not found'
    current_deaths = deaths_today_element.text if deaths_today_element else 'Not found'

    print(f"[{formatted_date}] WP: {current_population}")
    print(f"[{formatted_date}] BT: {current_births}")
    print(f"[{formatted_date}] DT: {current_deaths}")

    success_command = "notify-send -u normal 'Webscraper executed successfully.'"
    subprocess.run(success_command, shell=True)

except Exception as e:
    command_base = "notify-send -u critical "
    error_command = command_base + f'"Webscraper failed to execute due to an error: {e}"'
    subprocess.run(error_command, shell=True)
