When /^I get containers status with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container status -n chef-server,chef-client`)
end

When /^I get containers ssh-config with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container ssh-config -n chef-server,chef-client`)
end

When /^I up containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container up -n chef-client`)
end

When /^I down containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container down -n chef-client`)
end

When /^I clone containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container clone -n chef-client`)
end

When /^I build containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container build -n chef-client`)
end

When /^I export containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container export -n chef-server --output=/tmp/chef-server.sc`)
  step %(I run `#{app_name} --repo=#{@repo} container export -n chef-client --output=/tmp/chef-client.sc`)
end

When /^I import containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container import -n chef-server --input=/tmp/chef-server.sc`)
  step %(I run `#{app_name} --repo=#{@repo} container import -n chef-client --input=/tmp/chef-client.sc`)
end
