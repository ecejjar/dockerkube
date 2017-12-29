#!/usr/bin/python
import sys
import os
import subprocess

def write_stdout(s):
    # only eventlistener protocol messages may be sent to stdout
    sys.stdout.write(s)
    sys.stdout.flush()

def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()

def main():
    while 1:
        # transition from ACKNOWLEDGED to READY
        write_stdout('READY\n')

         # read header line
        line = sys.stdin.readline()

        # read event payload
        headers = dict([ x.split(':') for x in line.split() ])
        data = sys.stdin.read(int(headers['len']))
        body = dict([ x.split(':') for x in data.split() ])

        try:
            if body['processname'] == 'dockerd':
                write_stderr('Starting minikube...\n')
                subprocess.check_call([
                    "/usr/local/bin/minikube", "start", "--vm-driver=none",
                    "--kubernetes-version=v%s" % os.environ['KUBERNETES_VERSION']
                ], stdout=sys.stderr.fileno())

            # transition from READY to ACKNOWLEDGED
            write_stdout('RESULT 2\nOK')
        except subprocess.CalledProcessError as e:
            write_stderr(e)
            write_stdout('RESULT 4\nFAIL')

if __name__ == '__main__':
    main()
