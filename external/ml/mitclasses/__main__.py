import sys, os, inflection, models, manual
from server import Server
from learning.clusterer import Clusterer
from learning.classifier import Classifier

def main_loop():
  socket_fd, num_features, learning_type, model = sys.argv[1:5]

  learner_klass = {'cluster': Clusterer, 'classify': Classifier}[learning_type]
  parser = getattr(getattr(models, inflection.underscore(model)), model)
  learner = learner_klass.empty(*map(int, num_features.split(',')))
  server = Server(int(socket_fd), learner, parser.parse_raw)
  backend = {'cluster': server.minibatch_kmeans_backend, 'classify': server.svc_backend}[learning_type]

  try:
    server.start(backend)
  except StopIteration:
    pass
  finally:
    server.close()


if __name__ == '__main__':
  if os.getenv('MODE') == 'clustering':
    manual.manual_clustering()
  elif os.getenv('MODE') == 'classification':
    manual.manual_classification()
  else:
    main_loop()
