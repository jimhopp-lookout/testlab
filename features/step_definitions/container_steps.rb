When /^I trigger an export of containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container export -n chef-server,chef-client`)
end

When /^I trigger an import of containers with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} container import -n chef-server --input=chef-server.sc`)
  step %(I run `#{app_name} --repo=#{@repo} container import -n chef-client --input=chef-client.sc`)
end
