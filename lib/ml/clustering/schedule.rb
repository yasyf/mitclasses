module Ml
  module Clustering
    class Schedule
      def initialize(schedules)
        @schedules = schedules
        build_feature_vectors
        set_clusterer
      end

      def suggestions(schedule_semester)
        cluster = eval(schedule_semester)

        all_classes = schedule_semester.schedule.classes
        all_class_set = Set.new all_classes.map(&:number)
        all_class_set |= all_classes.flat_map(&:equivalents)

        Enumerator.new do |yielder|
          cluster.each do |id|
            next if id == schedule_semester.id
            ::Schedule.parse(id).classes.each do |c|
              next if all_class_set.include?(c.number)
              next if schedule_semester.conflicts? c
              # TODO: only look at previous classes in schedule for requisites
              next unless c.prereqs.blank? || c.prereqs.satisfied?(all_classes)
              next unless c.coreqs.blank? || c.coreqs.satisfied?(all_classes)

              all_class_set.add c.number
              yielder.yield c
            end
          end
        end
      end

      def destroy
        @clusterer.destroy
      end

      private

      def eval(schedule_semester)
        @clusterer.eval schedule_semester.feature_vector
      end

      def build_feature_vectors
        @feature_vectors = @schedules.flat_map(&:feature_vectors)
      end

      def set_clusterer
        @clusterer = Ml::Clustering::Clusterer.new(@feature_vectors.first.size - 1)
        @clusterer.build(@feature_vectors)
      end
    end
  end
end
