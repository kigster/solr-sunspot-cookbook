include_recipe 'ipaddr_extensions'



# start solr service
service node['solr']['service_name'] do
  action 'enable'
end
