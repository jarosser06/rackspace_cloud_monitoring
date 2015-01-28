# rackspace_cloud_monitoring-cookbook

The Rackspace Cloud-monitoring cookbook provides resource primitives (LWRPs) for use in recipes.
The goal is to offer resources to configure [Rackspace Cloud-monitoring](http://www.rackspace.co.uk/cloud/monitoring)

## Supported Platforms

* Centos 6.5
* Ubuntu 12.04
* Ubuntu 14.04

## Attributes

<!---
node['rackspace_cloud_monitoring']['cloud_credentials_username']
node['rackspace_cloud_monitoring']['cloud_credentials_api_key']
-->

## Usage

Place a dependency on the rackspace_cloud_monitoring cookbook in your cookbook's metadata.rb
```
depends 'rackspace_cloud_monitoring'
```
Then, in a recipe:

```
rackspace_cloud_monitoring_service 'default' do
  cloud_credentials_username 'my_user'
  cloud_credentials_api_key 'uc60892165188d7i786p833917a3v7613'
  action [:create, :start]
end

rackspace_cloud_monitoring_check 'filesystem' do
  type 'filesystem'
  target '/var'
  alarm true
  action :create
end
```

## Resources

### rackspace_cloud_monitoring_service
The `rackspace_cloud_monitoring_service` resources manages the basic plumbing needed to get a rackspace-monitoring agent instance running with minimal configuration.

The :create action handles package installation. The internal configuration file contains just enough to get the service up and running, then loads extra configuration from a rackspace-monitoring-agent.conf.d directory.

#### Parameters

* `cloud_credentials_username` - Your cloud username 
* `cloud_credentials_api_key` - Your cloud [api-key](http://www.rackspace.com/knowledge_center/article/view-and-reset-your-api-key)
* `package_name` - Rackspace monitoring agent package name (default to `rackspace-monitoring-agent`)
* `package_action` - Which action to run when `:create` default to `install`

#### Actions

* `:create` - Configures everything but the underlying operating system service
* `:delete` - Removes everything
* `:start` - Starts the underlying operating system service
* `:stop` - Stops the underlying operating system service
* `:restart` - Restarts the underlying operating system service
* `:reload` - Reloads the underlying operating system service
* `:disable/:enable` Enables/Disables the underlying operating system service

### rackspace_cloud_monitoring_check
The `rackspace_cloud_monitoring_check` resources creates the agent configuration for a defined type.

The :create action handles package installation. The internal configuration file contains just enough to get the service up and running, then loads extra configuration from a rackspace-monitoring-agent.conf.d directory.

#### Parameters
##### Common to all checks

* `:alarm` - optional - Enable or disable the alarm on a check - Default : false
* `:alarm_criteria` - optional - Criteria used to trigger alarms - Default : agent specific `./libaries/helpers.rb` => `parsed_alarm_criteria`
* `:period` - optional - The period in seconds for a check. The value must be greater than the minimum period set on your account -Default : 90
* `:timeout` - optional - The timeout in seconds for a check. This has to be less than the period - Default : 30
* `:critical` - optional - Threshold for the default alarm criteria - Default : 95
* `:warning` - optional - Threshold for the default alarm criteria - Default : 90
* `:variables` - optional - Additional variables you want to use in the template.`variable_name => 'value'`. It will allow to add attributes to the agent configuration if you need more than the default ones. [Here is an example](https://github.com/rackspace-cookbooks/rackspace_cloud_monitoring/blob/master/test/fixtures/cookbooks/rackspace_cloud_monitoring_check_test/recipes/http.rb#L8-L9) for `remote.http`. If you want to create your own `:template` you can use all the `:variables` with `@variable_name`.

##### Required on some checks (filesystem/disk/network)

* `:target` - required for filesystem/disk/network only -
  * `disk` : The disk to check (eg '/dev/xvda1')
  * `filesystem` : The mount point to check (eg '/var' or 'C:')
  * `network` : The network device to check (eg 'eth0')
* `:target_hostname` - required for http only - Server to request for the HTTP check 
* `:send_warning` - required for network only - Threshold for the default send alarm criteria - Default : 56000
* `:send_critical` - required for network only - Threshold for the default send alarm criteria - Default : 76000
* `:recv_warning` - required for network only - Threshold for the default receive alarm criteria - Default : 56000
* `:recv_critical` - required for network only - Threshold for the default send alarm criteria - Default : 76000

##### Template config

* `:cookbook` - optional - Where to look for the agent yaml template - Default : 'rackspace_cloud_monitoring'
* `:template` - optional - Where to look for the agent yaml template - Default : '`:type`.conf.erb' or `custom_check.conf.erb`
* `:type` - required - Which kind of agent to configure. Supported agents :
  * [memory](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.memory)
  * [cpu](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.cpu)
  * [load](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.load)
  * [filesystem](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.filesystem)
  * [disk](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.disk)
  * [network](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-agent.html#section-ct-agent.network)
  * [http](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types-remote.html#section-ct-remote.http)
  * anything else will load `custom_check.conf.erb` and all the parameters and variables will be available in the template. [Rackspace check types](http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/appendix-check-types.html)

#### Actions
* `:create` - Create an agent configuration
* `:delete` - Removes an agent configuration (will not remove the check)
* `:disable/:enable` Disable/enable the agent check. 


### Examples
#### CPU agent with alarm enabled
```
rackspace_cloud_monitoring_check 'Cpu check' do
  type 'cpu'
  alarm true
  action :create
end
```
#### Create a new agent config from scratch
By example `remote.ping` which is not a supported type

```
rackspace_cloud_monitoring_check 'custom' do
  type 'remote.ping'
  cookbook 'rackspace_cloud_monitoring_check_test'
  template 'user_defined.conf.erb'
  alarm true
  variables 'count' => '10'
  action :create
end
```

Then you can have your own template :

```
type: remote.ping
label: Remote ping check on <%= @target_hostname %>
disabled: <%= @disabled %>
period: <%= @period %>
timeout: <%= @timeout %>
target_hostname: <%= @target_hostname %>
monitoring_zones_poll:
  - mzdfw
  - mzord
  - mziad
details:
  <% @variables.each do |param,value| %>
  <%= param -%>: <%= value %>
  <% end %>
```
#### Create a http agent but add some variables not exposed by the resource as parameters
```
hostname = 'dummyhost.com'
rackspace_cloud_monitoring_check 'http' do
  type 'http'
  target_hostname hostname
  alarm true
  variables 'url' => "http://#{hostname}/healthcheck",
            'body' => 'Status OK'
  action :create
end
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Julien Berard (jujugrrr@gmail.com)
