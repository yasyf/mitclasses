import requests
import numpy as np

class Base(object):
  HOST = 'http://localhost:3000/api/v1'
  DATA_TYPE = 'float64'
  LABEL_TYPE = 'string'

  def __init__(self, feature_vector):
    self.feature_vector = np.array(feature_vector[:-1], dtype=self.DATA_TYPE)
    self.label = np.array([feature_vector[-1]])

  @classmethod
  def name(cls):
    return cls.__name__.lower()

  @classmethod
  def endpoint(cls):
    return '{}s'.format(cls.name())

  @classmethod
  def fetch(cls, identifier):
    raw = requests.get('/'.join([cls.HOST, cls.endpoint(), identifier])).json()
    return cls(raw[cls.name()])

  @classmethod
  def fetch_all(cls, wrap=True, endpoint=None):
    raw = requests.get('/'.join([cls.HOST, endpoint or cls.endpoint()])).json()
    if wrap:
      return map(cls, raw[cls.endpoint()])
    else:
      return cls.parse_raw(raw[cls.endpoint()])

  @classmethod
  def parse_raw(cls, items):
    array = np.array(items)
    return array[:,:-1].astype(cls.DATA_TYPE), array[:,-1].reshape(-1, 1).astype(cls.LABEL_TYPE)

  @classmethod
  def empty_vector(cls, num_features):
    return np.empty((0, num_features), dtype=cls.DATA_TYPE)

  @staticmethod
  def empty_label():
    return np.empty((0, 1))
