require 'spec_helper'

RSpec.describe 'provider::default' do
  describe user('solr') do
    it { should exist }
  end
end
