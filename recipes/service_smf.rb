include_recipe 'smf'

include_recipe 'ipaddr_extensions'

helper = Solr::ServiceHelper.new(node)
path = [node['solr']['smf_path'], node['paths']['bin_path']].compact.join(':')

# create/import smf manifest
smf node['solr']['service_name'] do
  user node['solr']['solr_user']
  start_command helper.start_command
  start_timeout 300
  stop_timeout 60
  environment 'PATH' => path,
              'LC_ALL' => 'en_US.UTF-8',
              'LANG' => 'en_US.UTF-8'
  working_directory helper.working_directory
end

# start solr service
service node['solr']['service_name'] do
  action 'enable'
end
