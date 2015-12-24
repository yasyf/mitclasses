import sys
from server import Server

if __name__ == '__main__':
  server = Server(int(sys.argv[1]), int(sys.argv[2]))
  try:
    server.start()
  except StopIteration:
    pass
  finally:
    server.close()
