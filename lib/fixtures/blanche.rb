module Fixtures
  class Blanche
    LISTS = %w(
      list-of-lists-of-lists
      asa-list-of-lists
      asa-w20
      cluedump-announce
      debate
      cr-committee
      deecs-all
      finboard-groups
      hkn-eligibles-fa15
      hkn-eligibles-fa14
      hkn-eligibles-fa13
      hkn-eligibles-fa12
      gordonelp-gel1-2015-16
      mit_textbooks
      techx-all
      tesseract-hunters
      techx-interest-14
      sipb-list-of-lists
      ieee-members
      web-dev
      sbc-chat
      cfh
      friends-of-israel
      free-food
      mcg-members
      blacks-exec
      free-food-reuse
      studyabroad-info-old
      free-money
      free-fossils
      mitbeef
      ksa-general
      aaa-lists
      asians
      asa-all
      csc-active
      swe-exec
    ) \
    + (1..20).map { |i| "swe-course#{i}" } \
    + (0..6).map { |i| "maseeh#{i}" }

    def self.load
      SSH::Blanche.new(LISTS, auto_destroy: true).search do |kerberos|
        Student.where(kerberos: kerberos).first_or_create!
      end
    end
  end
end
