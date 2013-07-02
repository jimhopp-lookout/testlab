When /^I get help for "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(help))
end

When /^I get the status with "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(status))
end

When /^I build the lab with "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(build))
end

When /^I up the lab with "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(up))
end

When /^I down the lab with "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(down))
end

When /^I destroy the lab with "([^"]*)"$/ do |app_name|
  testlab_cmd(app_name, %W(destroy))
end

def testlab_cmd(app_name, *args)
  args = args.join(' ')
  step %(I run `#{app_name} --repo=#{TEST_REPO} #{args}`)
end
