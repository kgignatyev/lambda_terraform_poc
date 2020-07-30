from dateutil.easter import easter
import json


def main():
    # this should print "1984-04-22"
    result = easter(1984).isoformat()
    print(result)
    return json.dumps(result)


def handler(event, context):
    return main()


if __name__ == '__main__':
    main()
