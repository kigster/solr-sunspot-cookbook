include_recipe 'test-setup::java'
include_recipe 'test-setup::_node'

solr 'solr' do
  version '5.4.0'
  solr_home '/var/solr/solr5'
  port 8985
  heap_size '1g'
  java_home '/opt/local/java/openjdk7'
  jvm_params '-Xdebug'
  notifies :enable, 'solr[solr]'
end

solr_core 'awesome_data' do
  version '5.4.0'
  solr_home '/var/solr/solr5'
  port 8985
  confdir 'basic_configs'
end
