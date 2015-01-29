require_relative 'spec_helper'

describe 'rackspace_cloud_monitoring_check_test::* on Ubuntu 14.04' do
  before do
    stub_resources
  end

  UBUNTU1404_CHECK_OPTS = {
    log_level: LOG_LEVEL,
    platform: 'ubuntu',
    version: '14.04',
    step_into: ['rackspace_cloud_monitoring_service_test', 'rackspace_cloud_monitoring_check']
  }

  context 'Any check' do
    context 'rackspace_cloud_monitoring_check built from parameters' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.network'
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
          node.set['rackspace_cloud_monitoring_check_test']['alarm_criteria']['recv'] = 'custom_recv_criteria'
          node.set['rackspace_cloud_monitoring_check_test']['alarm_criteria']['send'] = 'custom_send_criteria'
          node.set['rackspace_cloud_monitoring_check_test']['period'] = 666
          node.set['rackspace_cloud_monitoring_check_test']['timeout'] = 555
          node.set['rackspace_cloud_monitoring_check_test']['critical'] = 444
          node.set['rackspace_cloud_monitoring_check_test']['warning'] = 333
          node.set['rackspace_cloud_monitoring_check_test']['target'] = 'dummy_eth'
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it 'configure my agent with all me resources parameters' do
        params = [
          'type: agent.network',
          'disabled: false',
          'period: 666',
          'timeout: 555',
          'target: dummy_eth',
          'alarm-network-receive',
          'custom_recv_criteria',
          'custom_send_criteria'
        ]
        params.each do |param|
          expect(chef_run).to render_file('/etc/rackspace-monitoring-agent.conf.d/agent.network.yaml').with_content(param)
        end
      end
    end
  end

  context 'CPU check' do
    context 'rackspace_cloud_monitoring_check for cpu' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::cpu')
      end
      it_behaves_like 'agent config', 'agent.cpu'
    end
  end
  context 'HTTP check' do
    context 'rackspace_cloud_monitoring_check for http' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::http')
      end
      it_behaves_like 'agent config', 'remote.http'
    end
  end
  context 'Load check' do
    context 'rackspace_cloud_monitoring_check for load' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::load')
      end
      it_behaves_like 'agent config', 'agent.load'
    end
  end
  context 'Memory check' do
    context 'rackspace_cloud_monitoring_check for memory' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::memory')
      end
      it_behaves_like 'agent config', 'agent.memory'
    end
  end

  context 'Network check' do
    context 'rackspace_cloud_monitoring_check' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::network')
      end
      it_behaves_like 'agent config', 'agent.network'
    end
    context 'rackspace_cloud_monitoring_check with missing mandatory attribute' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.network'
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it_behaves_like 'raise error about missing parameters'
    end
    context 'rackspace_cloud_monitoring_check with custom alarm thresholds' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.network'
          node.set['rackspace_cloud_monitoring_check_test']['target'] = 'dummy_target'
          node.set['rackspace_cloud_monitoring_check_test']['send_warning'] = 9999
          node.set['rackspace_cloud_monitoring_check_test']['send_critical'] = 8888
          node.set['rackspace_cloud_monitoring_check_test']['recv_warning'] = 7777
          node.set['rackspace_cloud_monitoring_check_test']['recv_critical'] = 6666
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it 'configures the agent.yaml with the corrects thresholds' do
        agent_config = '/etc/rackspace-monitoring-agent.conf.d/agent.network.yaml'
        expect(chef_run).to render_file(agent_config).with_content('transmit rate on dummy_target is above your warning threshold of 9999')
        expect(chef_run).to render_file(agent_config).with_content('transmit rate on dummy_target is above your critical threshold of 8888')
        expect(chef_run).to render_file(agent_config).with_content('receive rate on dummy_target is above your warning threshold of 7777')
        expect(chef_run).to render_file(agent_config).with_content('receive rate on dummy_target is above your critical threshold of 6666')
      end
    end
  end

  context 'Disk check' do
    context 'rackspace_cloud_monitoring_check for disk' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::disk')
      end
      it_behaves_like 'agent config', 'agent.disk'
    end
    context 'rackspace_cloud_monitoring_check for disk with missing mandatory attribute' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.disk'
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it_behaves_like 'raise error about missing parameters'
    end
  end

  context 'Filesystem check' do
    context 'rackspace_cloud_monitoring_check for filesystem' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::filesystem')
      end
      it_behaves_like 'agent config', 'agent.filesystem'
    end
    context 'rackspace_cloud_monitoring_check with missing mandatory attribute' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.filesystem'
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it_behaves_like 'raise error about missing parameters'
    end
    context 'rackspace_cloud_monitoring_check with custom target' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.filesystem'
          node.set['rackspace_cloud_monitoring_check_test']['target'] = 'dummy_target'
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it 'configures the agent.yaml with the correct target' do
        expect(chef_run).to render_file('/etc/rackspace-monitoring-agent.conf.d/agent.filesystem.yaml').with_content('target: dummy_target')
      end
    end
  end

  context 'Plugin check' do
    context 'rackspace_cloud_monitoring_check' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::plugin')
      end
      it_behaves_like 'agent config', 'agent.plugin'
    end
    context 'rackspace_cloud_monitoring_check with missing mandatory attribute' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.plugin'
          node.set['rackspace_cloud_monitoring_check_test']['alarm'] = true
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it_behaves_like 'raise error about missing parameters'
    end
    context 'rackspace_cloud_monitoring_check with plugin_url and args' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.plugin'
          node.set['rackspace_cloud_monitoring_check_test']['plugin_url'] = 'http://www.dummyhot.com/dummyplugin.py'
          node.set['rackspace_cloud_monitoring_check_test']['plugin_args'] = ['--dummyargs']
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it 'downloads the plugin(with a filename based on the url)' do
        expect(chef_run).to create_remote_file('/usr/lib/rackspace-monitoring-agent/plugins/dummyplugin.py')
      end
      it 'configures the agent.yaml with the correct plugin' do
        expect(chef_run).to render_file('/etc/rackspace-monitoring-agent.conf.d/agent.plugin.yaml').with_content('file: dummyplugin.py')
      end
      it 'configures the agent.yaml and passes the args' do
        expect(chef_run).to render_file('/etc/rackspace-monitoring-agent.conf.d/agent.plugin.yaml').with_content('args: ["--dummyargs"]')
      end
    end
    context 'rackspace_cloud_monitoring_check with plugin_url and plugin_filename' do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(UBUNTU1404_CHECK_OPTS) do |node|
          node_resources(node)
          node.set['rackspace_cloud_monitoring_check_test']['type'] = 'agent.plugin'
          node.set['rackspace_cloud_monitoring_check_test']['plugin_url'] = 'http://www.dummyhot.com/dummyplugin.py'
          node.set['rackspace_cloud_monitoring_check_test']['plugin_filename'] = 'dummy_filename.py'
        end.converge('rackspace_cloud_monitoring_service_test::default', 'rackspace_cloud_monitoring_check_test::default')
      end
      it 'configures the agent.yaml and set the plugin_filename according to :plugin_filename' do
        expect(chef_run).to render_file('/etc/rackspace-monitoring-agent.conf.d/agent.plugin.yaml').with_content('file: dummy_filename.py')
      end
      it 'downloads the plugin(with a filename based on :plugin_filename)' do
        expect(chef_run).to create_remote_file('/usr/lib/rackspace-monitoring-agent/plugins/dummy_filename.py')
      end
    end
  end

end
