require 'tempfile'
require 'ncle/push_event'
require 'xz'

RSpec.describe NCLE::PushEvent do

  def create_tmp_file
    path = Tempfile.new(Time.now.to_i.to_s).path
    File.open(path, "w"){|f| f.puts "data"}
    path
  end

  def create_tmp_xz_file
    require 'xz'
    path = create_tmp_file
    xz   = path + ".xz"
    XZ.compress_file(path, xz)
    xz
  end

  describe "#parse_s3_path" do

    let(:required) do
      {benchmark_id:        :a,
       benchmark_type_code: :b,
       status_code:         :c,
       event_type_code:     :d}
    end

    it "should select correct params when passed minimal set" do
      expect(described_class.generate_post_params(required)).to \
             eq(required)
    end

    it "should select correct params when given additional parameters" do
      params = required.merge({key: :value})
      expect(described_class.generate_post_params(params)).to \
             eq(required)
    end

    it "should select correct params when given file parameters" do
      file_params = [
        {log_file_s3_url: :url,    log_file_digest: :digest},
        {event_file_s3_url: :url,  event_file_digest: :digest},
        {cgroup_file_s3_url: :url, cgroup_file_digest: :digest}]

      file_params.each do |params|
        expect(described_class.generate_post_params(params)).to \
          eq(params)
      end
    end

  end

  describe "#xz_compressed?" do

      it "should return true when the file is zx compressed" do
        path = create_tmp_xz_file
        expect(NCLE::PushEvent.xz_compressed?(path)).to eq(true)
      end

      it "should return false when the file is not xz compressed" do
        path = create_tmp_file
        expect(NCLE::PushEvent.xz_compressed?(path)).to eq(false)
      end

  end

  describe "#files_valid?" do

    it "should return ok the log-file does exist" do
      opts = {log_file: create_tmp_file}
      status, _ = NCLE::PushEvent.files_valid?(opts)
      expect(status).to eq(:ok)
    end

    [:event, :cgroup].each do |file|
      it "should return an error when the #{file.to_s} is not zx compressed" do
        path = create_tmp_file
        opts = {"#{file}_file".to_sym => path}
        status, msg = NCLE::PushEvent.files_valid?(opts)
        expect(status).to eq(:error)
        expect(msg).to eq("The #{file} file should be xz compressed: #{path}")
      end

      it "should return ok when the #{file.to_s} is zx compressed" do
        opts = {"#{file}_file".to_sym => create_tmp_xz_file}
        status, _ = NCLE::PushEvent.files_valid?(opts)
        expect(status).to eq(:ok)
      end
    end

    [:log, :event, :cgroup].each do |file|
      it "should return error when the #{file.to_s}-file does not exist" do
        opts = {"#{file}_file".to_sym => "no-file"}
        status, msg = NCLE::PushEvent.files_valid?(opts)
        expect(status).to eq(:error)
        expect(msg).to eq("The #{file.to_s} file does not exist: no-file")
      end
    end

  end
end
