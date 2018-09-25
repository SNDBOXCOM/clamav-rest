import requests
import demjson
import sys

input_file = sys.argv[1]

files = {"file": open(input_file, "rb")}

response = requests.post("http://localhost:9000/scan", files=files)
d = demjson.decode(response.text)

print("status: %s, name: %s" % (d['Status'], d['Description']))