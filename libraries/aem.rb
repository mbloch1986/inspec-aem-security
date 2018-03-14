# Copyright 2018 Shine Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative './helper'

# Aem class contains security checks relevant to an AEM instance,
# used by AEM Author and AEM Publish
class Aem < Inspec.resource(1)
  include Capybara::DSL
  name 'aem'

  desc "
    Custom resource for AEM, used by AEM Author and AEM Publish
  "

  def initialize(component)
    conf = read_config[component]
    @client = init_aem_client(conf)

    @params = {}
  end

  # should change default password for AEM admin account
  # https://helpx.adobe.com/experience-manager/6-3/sites/administering/using/security-checklist.html
  def has_non_default_admin_password
    @conf['username'] = 'admin'
    @conf['password'] = 'admin'
    aem = init_aem_client(conf).aem

    begin
      aem.get_agents(aem_role)
      has_non_default_admin_password = false
    rescue RubyAem::Error => error
      has_non_default_admin_password = true if error.result.response.status_code.eql? 401
      raise error
    end
    has_non_default_admin_password
  end
end