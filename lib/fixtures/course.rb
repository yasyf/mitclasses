module Fixtures
  class Course
    DESCRIPTIONS = {
      1 => "Civil And Environmental Eng",
      2 => "Mechanical Engineering",
      3 => "Materials Science And Eng.",
      4 => "Architecture",
      5 => "Chemistry",
      6 => "Electrical Eng & Computer Sci",
      7 => "Biology",
      8 => "Physics",
      9 => "Brain And Cognitive Sciences",
      10 => "Chemical Engineering",
      11 => "Urban Studies and Planning",
      12 => "Earth, Atmospheric, and Planetary Sciences",
      14 => "Economics",
      15 => "Management",
      16 => "Aeronautics And Astronautics",
      17 => "Political Science",
      18 => "Mathematics",
      20 => "Biochemical Engineering",
      21 => "Literature",
      22 => "Nuclear Science & Engineering",
      24 => "Philosophy"
    }

    def self.load
      DESCRIPTIONS.each { |i, d| ::Course.where(number: i).first!.update! description: d }
    end
  end
end
