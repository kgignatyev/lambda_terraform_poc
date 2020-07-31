from dateutil.easter import easter
import json
import requests

def main():
    # this should print "1984-04-22"
    result = easter(1984).isoformat()
    res = requests.get('https://api.github.com')
    status_code = res.status_code
    result = "Request status code is [" + str(status_code)+ "] and easter is on " + result
    print(result)
    return json.dumps(result)


def handler(event, context):
    return main()


if __name__ == '__main__':
    main()
