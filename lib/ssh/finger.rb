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

    private

    def fetch
      @raw ||= @ssh.exec!("finger #{@kerberos}@mitdir.mit.edu")
      destroy
    end
  end
end
