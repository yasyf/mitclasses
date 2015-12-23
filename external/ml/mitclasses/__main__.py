from models import schedule
from clustering import clusterer
from sklearn.cluster import AffinityPropagation

feature_vectors, labels = schedule.Schedule.fetch_all(wrap=False)
clusterer = clusterer.Clusterer(feature_vectors, labels)
clusterer.backend = AffinityPropagation()

clusterer.fit()
print labels[0], clusterer.predict(feature_vectors[0])
