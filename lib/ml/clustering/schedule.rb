module Ml
  module Clustering
    class Schedule
      NUM_CLUSTERS = 4

      def initialize(schedules)
        @schedules = schedules
        build_data_set
        set_clusterer
      end

      def suggestions(schedule_semester)
        cluster = @clusterer.clusters[eval(schedule_semester)]

        all_classes = schedule_semester.schedule.classes
        all_class_set = Set.new all_classes.map(&:number)
        all_class_set |= all_classes.flat_map(&:equivalents)

        Enumerator.new do |yielder|
          cluster.data_items.sort_by { |i| distance(i, schedule_semester) }.each do |item|
            next if item.last == schedule_semester.id
            ::Schedule.parse(item.last).classes.each do |c|
              next if all_class_set.include?(c.number)
              next if schedule_semester.conflicts? c
              # TODO: only look at previous classes in schedule for requisites
              next unless c.prereqs.blank? || c.prereqs.satisfied?(all_classes)
              next unless c.coreqs.blank? || c.coreqs.satisfied?(all_classes)
              yielder.yield c
            end
          end
        end
      end

      private

      def distance(item, schedule_semester)
        @clusterer.distance item, schedule_semester.feature_vector
      end

      def eval(schedule_semester)
        @clusterer.eval schedule_semester.feature_vector
      end

      def build_data_set
        data_items = @schedules.flat_map(&:feature_vectors)
        @data_set = Ai4r::Data::DataSet.new data_items: data_items
      end

      def set_clusterer(num_clusters = nil)
        @clusterer = Ai4r::Clusterers::BisectingKMeans.new.build(@data_set, NUM_CLUSTERS)
      end
    end
  end
end
