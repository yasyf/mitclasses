class Schedule < ActiveRecord::Base
  has_and_belongs_to_many :mit_classes

  alias_method :classes, :mit_classes

  def conflicts?
    conflicts.present?
  end

  def conflicts
    grouped_classes = classes.includes(:semester, sections: :times).group_by(&:semester)
    grouped_classes.each_with_object({}) do |(semester, semester_classes), hash|
      hash[semester] = semester_classes.combination(2).select { |a, b| a.conflicts? b }
    end
  end
end
