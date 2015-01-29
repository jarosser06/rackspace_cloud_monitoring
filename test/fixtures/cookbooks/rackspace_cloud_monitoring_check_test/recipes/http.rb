# comments!

hostname = 'dummyhost.com'
rackspace_cloud_monitoring_check 'remote.http' do
  type 'remote.http'
  target_hostname hostname
  alarm true
  variables 'url' => "http://#{hostname}/healthcheck",
            'body' => 'Status OK'
  action :create
end
