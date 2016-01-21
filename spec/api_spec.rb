require 'nucleotides/api'

RSpec.describe Nucleotides::API do

  let(:api) do
    described_class.new(ENV['DOCKER_HOST'])
  end

  describe "#task" do

    it "should fetch the expected task data" do
      expect(api.task(1)).to include('task_type')
    end

  end

end
