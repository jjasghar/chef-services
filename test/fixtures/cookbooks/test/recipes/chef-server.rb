chef_ingredient "chef-server" do
  config <<-EOS
api_fqdn "#{node['chef_server']['fqdn']}"

oc_id['applications'] = {
  "supermarket"=>{"redirect_uri"=>"https://supermarket.services.com/auth/chef_oauth2/callback"}
}
EOS
  action :upgrade
  version :latest
  accept_license true
  package_source node['chef-server']['package_source']
end

ingredient_config "chef-server" do
  notifies :reconfigure, "chef_ingredient[chef-server]", :immediately
end

%w(manage push-jobs-server).each do |addon|
  chef_ingredient addon do
    accept_license true
  end

  ingredient_config addon do
    notifies :reconfigure, "chef_ingredient[#{addon}]", :immediately
  end
end

chef_server_user 'delivery' do
  firstname 'Delivery'
  lastname 'User'
  email 'delivery@services.com'
  password 'delivery'
  private_key_path '/tmp/delivery.pem'
  action :create
end

chef_server_org 'delivery' do
  org_long_name 'Delivery Organization'
  org_private_key_path '/tmp/delivery-validator.pem'
  action :create
end

chef_server_org 'delivery' do
  admins %w{ delivery }
  action :add_admin
end