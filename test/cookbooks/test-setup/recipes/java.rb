node.override['java']['java_home'] = '/opt/local/java/openjdk7'
node.override['java']['openjdk_packages'] = ['openjdk7']

include_recipe 'test-setup::_node'
