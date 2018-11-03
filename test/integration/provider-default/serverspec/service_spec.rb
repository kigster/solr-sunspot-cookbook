require 'spec_helper'

RSpec.describe 'provider::default' do
  describe service('solr') do
    it { should be_running }
  end

  describe 'solr process' do
    let(:pid) { `pgrep java`.chomp }
    let(:pargs) { `pargs #{pid}`.split }
    let(:environment) { `pargs -e #{pid}`.split }

    it 'configures' do
      expect(pargs).to include('-Djetty.port=8985')
    end

    it 'passes through jvm_params' do
      expect(pargs).to include('-Xdebug')
    end

    it 'sets heap min size' do
      expect(pargs).to include('-Xms1g')
    end

    it 'sets heap max size' do
      expect(pargs).to include('-Xmx1g')
    end

    it 'sets JAVA_HOME' do
      expect(environment).to include('JAVA_HOME=/opt/local/java/openjdk7')
    end
  end
end
