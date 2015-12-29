from base import Base

class MitClass(Base):
  DATA_TYPE = 'object'
  LABEL_TYPE = 'bool'
  FEEDBACK_ENDPOINT = 'classes/feedback'

  @classmethod
  def name(cls):
    return 'class'

  @classmethod
  def endpoint(cls):
    return 'classes'

  @classmethod
  def fetch_preprocess_vectors(cls):
    return cls.fetch_all(wrap=False)[0]

  @classmethod
  def fetch_feedback(cls):
    return cls.fetch_all(wrap=False, endpoint=cls.FEEDBACK_ENDPOINT)
