require 'spec_helper'

RSpec.describe 'recipes::replica' do
  describe service('solr-replica') do
    it { should be_running }
  end

  describe 'replication' do
    it 'should configure replication to the ip attr of the master found in search' do
      start_command = `svcprop -p start/exec solr-replica`.split('\ ')
      expect(start_command).to include('-Dreplication.url=http://2.2.2.2:9985/solr/replication')
    end
  end
end
