require 'ncle/s3'

RSpec.describe NCLE::S3 do

  describe "#parse_s3_path" do

    it "should correctly parse an s3 path" do
      expect(described_class.parse_s3_path("s3://bucket/basedir/file.txt")).to \
        eq(['bucket', 'basedir/file.txt'])
    end

  end

end
