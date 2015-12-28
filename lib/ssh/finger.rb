module SSH
  class Finger < Remote
    def initialize(kerberos)
      @kerberos = kerberos
      super
      fetch
    end

    def year
      if match = HTTP::Finger::YEAR_REGEX.match(@raw)
        match[1].to_i
      end
    end

    def name
      if match = HTTP::Finger::NAME_REGEX.match(@raw)
        match[1].split(', ').reverse.join(' ')
      end
    end

    def department
      if match = HTTP::Finger::DEPT_REGEX.match(@raw)
        match[1]
      end
    end

    private

    def fetch
      @raw ||= @ssh.exec!("finger #{@kerberos}@mitdir.mit.edu")
      destroy
    end
  end
end
