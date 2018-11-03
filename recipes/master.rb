#
# Cookbook Name:: solr
# Recipe:: master
#
# Copyright 2013, Wanelo, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

node.set['solr']['service_name'] = 'solr-master'

include_recipe 'solr::user'
include_recipe 'solr::install'
include_recipe 'solr::install_newrelic'

user = node['solr']['solr_user']
helper = Solr::InstallationHelper.new(node, true)
solr_home = helper.solr_home

# configure solr
execute 'copy example solr home into master' do
  command "rsync -a #{helper.example_directory}/ #{solr_home}/ " \
          "&& chown -R #{user}:root #{solr_home}/"
  not_if { ::File.directory?(solr_home) }
end

template helper.log_config do
  source helper.log_config_source
  owner user
  mode '0644'
  variables 'logname' => node['solr']['service_name']
  notifies :restart, "service[#{node['solr']['service_name']}]"
end

template helper.solr_config do
  source helper.solr_config_source
  mode '0600'
  variables(
    role: 'master',
    config: node['solr']['config'],
    master: node['solr']['master'],
    auto_commit: helper.auto_commit_enabled?
  )
  only_if { helper.use_cookbook_config? }
end

# create/import smf manifest
include_recipe 'solr::solr_service'
