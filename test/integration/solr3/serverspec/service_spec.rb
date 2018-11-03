require 'spec_helper'

RSpec.describe 'recipes::master' do
  describe service('solr-master') do
    it { should be_running }
  end
end
