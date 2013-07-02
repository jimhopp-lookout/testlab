When /^I get nodes status with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} node status -n vagrant`)
end
