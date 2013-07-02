When /^I get help for "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} help`)
end

When /^I get status for "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} status`)
end

When /^I trigger a lab build with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} build`)
end

When /^I trigger a lab destroy with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} destroy`)
end
