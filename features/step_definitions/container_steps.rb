When /^I get the containers status with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(status -n test-server))
end

When /^I get the containers ssh-config with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(ssh-config -n test-server))
end

When /^I up the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(up -n test-server))
end

When /^I down the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(down -n test-server))
end

When /^I clone the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(clone -n test-server))
end

When /^I build the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(build -n test-server))
end

When /^I export the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(export -n test-server --output=/tmp/test-server.sc))
end

When /^I import the containers with "([^"]*)"$/ do |app_name|
  container_cmd(app_name, %W(import -n test-server --input=/tmp/test-server.sc))
end

def container_cmd(app_name, *args)
  testlab_cmd(app_name, [%(container), args].flatten)
end
