# comments!

rackspace_cloud_monitoring_check 'agent.filesystem' do
  type 'agent.filesystem'
  target '/var'
  alarm true
  action :create
end
