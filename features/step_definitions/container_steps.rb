When /^I get the containers status with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(status -n chef-server,chef-client))
end

When /^I get the containers ssh-config with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(ssh-config -n chef-server,chef-client))
end

When /^I up the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(up -n chef-client))
end

When /^I down the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(down -n chef-client))
end

When /^I clone the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(clone -n chef-client))
end

When /^I build the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(build -n chef-client))
end

When /^I export the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(export -n chef-server --output=/tmp/chef-server.sc))
  container_cmd(app_name, %W(export -n chef-client --output=/tmp/chef-client.sc))
end

When /^I import the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(import -n chef-server --input=/tmp/chef-server.sc))
  container_cmd(app_name, %W(import -n chef-client --input=/tmp/chef-client.sc))
end

def container_cmd(app_name, *args)
  testlab_cmd(app_name, [%(container), args].flatten)
end
