require 'spec_helper'

RSpec.describe 'provider::default' do
  describe file('/opt/solr') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end

  describe file('/opt/solr-5.4.0') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end

  describe file('/var/solr/solr5') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end

  describe file('/var/log/solr') do
    it { should be_directory }
    it { should be_owned_by('solr') }
  end
end
