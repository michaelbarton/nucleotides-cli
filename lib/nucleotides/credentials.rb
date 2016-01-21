require 'inifile'

module Nucleotides
  module Credentials
    class << self

      CREDS = {
        'secret_key' => {env: 'AWS_SECRET_KEY', file: 'aws_secret_access_key'},
        'access_key' => {env: 'AWS_ACCESS_KEY', file: 'aws_access_key_id'},
        'region'     => {env: 'AWS_REGION',     file: 'aws_region'}
      }

      def credential(name)
        if cred = ENV[CREDS[name][:env]]
          return cred.strip
        end

        cred_file = File.join(ENV['HOME'], '.aws', 'credentials')
        if not File.exists?(cred_file)
          raise ArgumentError, "No environment variable set or credential file found for: #{name}"
        end

        if cred = IniFile.load(cred_file)['default'][CREDS[name][:file]]
          return cred.strip
        else
          raise ArgumentError, "No credential file entry found for: #{CREDS[name][:file]}"
        end
      end

    end
  end
end
