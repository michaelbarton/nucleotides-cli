require 'ncle/push_event'

RSpec.describe NCLE::PushEvent do

  describe "#parse_s3_path" do

    let(:required) do
      {benchmark_id:        :a,
       benchmark_type_code: :b,
       status_code:          :c,
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
end
