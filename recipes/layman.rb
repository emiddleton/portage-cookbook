directory '/var/lib/layman' do
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file "/var/lib/layman/make.conf" do
  action :create_if_missing
  source 'make.conf'
  cookbook 'portage'
  owner 'root'
  group 'root'
  mode '0644'
end

make_conf "layman" do
  force_regen true
  sources %w(/var/lib/layman/make.conf)
end

l = package "app-portage/layman" do
  action :nothing
end
l.run_action(:install)

e = execute "layman -S" do
  action :nothing
end
e.run_action(:run)
