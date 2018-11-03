include_recipe 'test-setup::java'
include_recipe 'test-setup::_node'

solr 'solr' do
  version '5.4.0'
  solr_home '/var/solr/solr-master'
  port 8985
  heap_size '512m'
  java_home '/opt/local/java/openjdk7'
  notifies :enable, 'solr[solr]'
end

solr_core 'master awesome_data' do
  core_name 'awesome_data'
  version '5.4.0'
  solr_home '/var/solr/solr-master'
  port 8985
  confdir 'basic_configs'

  config_template 'solrconfig.xml' do
    source 'solr5/solrconfig.xml.erb'
    cookbook 'solr'
  end
end

solr 'solr-replica' do
  version '5.4.0'
  solr_home '/var/solr/solr-replica'
  port 8986
  heap_size '512m'
  java_home '/opt/local/java/openjdk7'
  notifies :enable, 'solr[solr-replica]'
end

solr_core 'replica awesome_data' do
  core_name 'awesome_data'
  version '5.4.0'
  solr_home '/var/solr/solr-replica'
  port 8986
  confdir 'basic_configs'

  config_template 'solrconfig.xml' do
    source 'solr5/solrconfig_replica.xml.erb'
    cookbook 'solr'
    variables 'master' => 'localhost:8985',
      'core' => 'awesome_data'
  end
end
