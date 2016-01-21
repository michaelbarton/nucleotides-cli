require 'tempfile'
require 'digest'
require 'nucleotides/s3'

RSpec.describe Nucleotides::S3 do

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

  describe "#get_file" do

    it "should fetch a file from s3" do
      dst = File.join(Dir.mktmpdir, "file")
      src = 's3://nucleotides-testing/short-read-assembler/reference.fa'
      described_class.get_file(src, dst)
      expect(File).to exist(dst)
      expect(File).to_not be_zero(dst)
    end

  end

end
