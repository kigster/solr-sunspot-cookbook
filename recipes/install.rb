#
# Cookbook Name:: solr
# Recipe:: install
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

include_recipe 'java::default'
include_recipe 'solr::user'

# download and extract solr
helper = Solr::InstallationHelper.new(node, true)

remote_file helper.tarball do
  source node['solr']['source_url']
  mode '0744'
  not_if { ::File.exist?(helper.tarball) }
end

execute 'extract solr archive' do
  command "tar -xzf #{helper.tarball}"
  cwd Chef::Config['file_cache_path']
  not_if { ::File.directory?(helper.cache_directory) }
end

directory node['solr']['solr_home'] do
  owner node['solr']['solr_user']
end

directory "#{helper.example_directory}/solr/data" do
  recursive true
  owner node['solr']['solr_user']
end

directory "#{helper.example_directory}/solr/conf" do
  recursive true
  owner node['solr']['solr_user']
end

directory node['solr']['solr_log_dir'] do
  owner node['solr']['solr_user']
end
