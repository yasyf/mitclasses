import requests
import numpy as np

class Schedule(object):
  HOST = 'http://localhost:3000'
  ENDPOINT = '/api/v1/schedules'

  def __init__(self, feature_vector):
    self.feature_vector = np.array(feature_vector[:-1])
    self.label = feature_vector[-1]

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
      array = np.array(raw['schedules'])
      return array[:,:-1], array[:,-1]
