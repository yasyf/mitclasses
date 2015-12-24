import sys
from server import Server

if __name__ == '__main__':
  server = Server(int(sys.argv[1]))
  server.start()
