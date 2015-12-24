import requests
import numpy as np

class Schedule(object):
  HOST = 'http://localhost:3000'
  ENDPOINT = '/api/v1/schedules'
  DATA_TYPE = 'float32'

  def __init__(self, feature_vector):
    self.feature_vector = np.array(feature_vector[:-1], dtype=self.DATA_TYPE)
    self.label = np.array([feature_vector[-1]])

  @classmethod
  def fetch(cls, identifier):
    raw = requests.get('/'.join([cls.HOST, cls.ENDPOINT, identifier])).json()
    return cls(raw['schedule'])

  @classmethod
  def fetch_all(cls, wrap=True):
    raw = requests.get('/'.join([cls.HOST, cls.ENDPOINT])).json()
    if wrap:
      return map(cls, raw['schedules'])
    else:
      return cls.parse_raw(raw)

  @classmethod
  def parse_raw(cls, raw):
    array = np.array(raw['schedules'])
    return array[:,:-1].astype(cls.DATA_TYPE), array[:,-1].reshape(-1, 1)

  @classmethod
  def empty_vector(cls, num_features):
    return np.empty((0, num_features), dtype=cls.DATA_TYPE)

  @staticmethod
  def empty_label():
    return np.empty((0, 1))
