# comments!

rackspace_cloud_monitoring_check 'agent.disk' do
  type 'agent.disk'
  target '/dev/xda1'
  alarm true
  action :create
  alarm_criteria 'fake_criteria'
end
