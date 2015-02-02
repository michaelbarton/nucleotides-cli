require 'tempfile'
require 'digest'
require 'ncle/s3'

RSpec.describe NCLE::S3 do

  describe "#parse_s3_path" do

    it "should correctly parse an s3 path" do
      expect(described_class.parse_s3_path("s3://bucket/basedir/file.txt")).to \
        eq(['bucket', 'basedir/file.txt'])
    end

  end

  describe "#generate_file_path" do

    it "should correctly generate an s3 path" do
      content = "ncle"
      file = Tempfile.new('ncle')
      File.open(file.path, 'w') {|f| f.puts content }
      digest = Digest::SHA2.new(256).file(file.path).hexdigest

      expect(described_class.generate_file_path("s3://bucket/", file.path)).to \
        match(/s3:\/\/bucket\/#{digest}-\d+/)
    end

  end
end
