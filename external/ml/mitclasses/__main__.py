from models import schedule
from clustering import clusterer
from sklearn.cluster import KMeans, AffinityPropagation

feature_vectors, labels = schedule.Schedule.fetch_all(wrap=False)
clusterer = clusterer.Clusterer(feature_vectors, labels)
clusterer.backend = AffinityPropagation()
# clusterer.backend = KMeans(n_clusters=clusterer.num_clusters)

clusterer.fit()

print labels[0]
print clusterer.predict(feature_vectors[0])
