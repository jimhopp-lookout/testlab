When /^I get the nodes status with "([^"]*)"$/ do |app_name|
  node_cmd(app_name, %W(status -n vagrant))
end

When /^I up the nodes with "([^"]*)"$/ do |app_name|
  node_cmd(app_name, %W(up -n vagrant))
end

When /^I down the nodes with "([^"]*)"$/ do |app_name|
  node_cmd(app_name, %W(down -n vagrant))
end

When /^I build the nodes with "([^"]*)"$/ do |app_name|
  node_cmd(app_name, %W(build -n vagrant))
end

def node_cmd(app_name, *args)
  testlab_cmd(app_name, [%(node), args].flatten)
end
