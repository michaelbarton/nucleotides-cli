#!/usr/bin/env ruby

require 'inifile'
require 'fog'

def get_credentials
  cred_file = File.join(ENV['HOME'], '.aws', 'credentials')
  if not File.exists?(cred_file)
    STDERR.puts "No credential file found at: #{cred_file}"
    exit 1
  end
  credentials =  Hash[IniFile.load(cred_file)['default'].map{|(k,v)| [k.to_sym,v]}]
  credentials.delete(:aws_region)
  credentials.merge!({region: 'us-west-1', provider: 'AWS'})
end

def list_all_files(bucket)
  s3 = Fog::Storage.new(get_credentials)
  files = s3.directories.
    get(bucket).
    files.
    map(&:key)
end

def delete_all_files(path)
  _, _, bucket, path = path.split('/', 4)
  s3 = Fog::Storage.new(get_credentials)
  files = list_all_files(bucket).select{|f| f.include?(path) && f != path}
  s3.delete_multiple_objects(bucket, files) unless files.empty?
end

