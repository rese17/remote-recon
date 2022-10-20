
import sys
import json


file = sys.argv[1]
content_type =  sys.argv[2]
url = sys.argv[3]

try: content= open(file, "r").readlines()
except FileNotFoundError: exit(1)

js = [] 
for line in content:
  js.append({"url": url, "content-type": content_type, "data": line.strip("\n")})

for i in js: print(json.dumps(i))
