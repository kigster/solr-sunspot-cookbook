require 'spec_helper'

RSpec.describe 'recipes::master' do
  describe file('/opt/solr') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end

  describe file('/opt/solr/master') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end

  describe file('/opt/solr/master/solr-webapp') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end
end
