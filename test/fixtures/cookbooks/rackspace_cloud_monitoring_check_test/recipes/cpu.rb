# comments!

rackspace_cloud_monitoring_check 'agent.cpu' do
  type 'agent.cpu'
  alarm true
  action :create
end
