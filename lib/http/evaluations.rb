module HTTP
  class Evaluations < Authenticated
    OVERALL_PROMPT = 'Overall rating of subject'
    RESPONSE_PROMPT = 'Response rate'
    METRICS = {
      "expectations were clearly defined" => "expectations_clear",
      "expectations were made clear" => "expectations_clear",
      "learning objectives were met" => "learning_objectives_met",
      "Assignments contributed to my learning" => "assigments_useful",
      "Grading thus far has been fair" => "grading_fair",
      "The pace of the class" => "pace",
      "Average hours you spent per week on this subject in the classroom" => "classroom_hours",
      "Average hours you spent per week on this subject outside of the classroom" => "home_hours",
      "Lab hours" => "classroom_hours",
      "Prep hours" => "home_hours",
      "Average hours you spent per week on this subject, both in and outside the classroom" => 'hours'
    }

    domain 'edu-apps.mit.edu'

    def evaluation(mit_class)
      get '/ose-rpt/subjectEvaluationSearch.htm'
      set 'termId', mit_class.semester.last
      set 'subjectCode', mit_class.number
      set 'instructorName', mit_class.instructor
      submit

      click_link { |l| l.href.include?('subjectEvaluationReport.htm') }
      extract_evaluations
    end

    private

    def extract_evaluations
      METRICS.each_with_object({}).each do |(description, key), hash|
        match = search("a:contains('#{description}')").first.try(:parent)
        match ||= search("td:contains('#{description}')").first
        hash[key] = match.next.next.text.to_f if match.present?
      end.tap do |hash|
        hash['percent_response'] = search("strong:contains('#{RESPONSE_PROMPT}')").
                                    first.next.text.strip.split.first.to_f
        hash['rating'] = search("strong:contains('#{OVERALL_PROMPT}')").
                          first.next.text.strip.split.first.to_f
      end
    end
  end
end
