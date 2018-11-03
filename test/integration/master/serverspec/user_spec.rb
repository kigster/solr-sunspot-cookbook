require 'spec_helper'

RSpec.describe 'recipes::master' do
  describe user('solr') do
    it { should exist }
  end
end
