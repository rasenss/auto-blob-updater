from requests import get
from datetime import datetime as dt
import yaml

with open('ginkgo.yml', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/ginkgo.yml").content)
fw = yaml.safe_load(open('ginkgo.yml').read())
stable_date = dt.strptime(fw[1]["date"], "%Y-%m-%d")
weekly_date = dt.strptime(fw[2]["date"], "%Y-%m-%d")
if stable_date > weekly_date:
    URL="https://bigota.d.miui.com/"
    version=fw[1]["versions"]["miui"]
    with open('/tmp/version','wb') as load:
        load.write(str.encode(version))
    URL+=version
    URL+="/"
    file=fw[1]["filename"]
    file=file[10:]
    URL+=file
    print("Fetching Stable ROM......")
else:
    URL="https://bigota.d.miui.com/"
    version=fw[2]["versions"]["miui"]
    with open('/tmp/version','wb') as load:
        load.write(str.encode(version))
    URL+=version
    URL+="/"
    file=fw[2]["filename"]
    file=file[10:]
    URL+=file
    print("Fetching Weekly ROM......")
with open('rom.zip', 'wb') as load:
    load.write(get(URL).content)
