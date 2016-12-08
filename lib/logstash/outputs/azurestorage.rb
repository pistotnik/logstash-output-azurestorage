# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'
require 'azure/storage'

class LogStash::Outputs::Azurestorage < LogStash::Outputs::Base
  config_name "azurestorage"

  config :storage_account_name, :validate => :string
  config :storage_access_key, :validate => :string
  config :table_name, :validate => :string

  public
  def register
    @azure_service = LogStash::Outputs::AzureStorageClient.new(@table_name)
    @azure_service.init()
  end

  public
  def receive(event)
    entity = { PartitionKey: Date.today.strftime("%m%d%Y"),
               RowKey: DateTime.now.strftime('%Q'),
               EventId: event.sprintf("%{event_id}"),
               Level: event.sprintf("%{level}"),
               Pid: event.sprintf("%{process_id}"),
               Tid: event.sprintf("%{thread_id}"),
               ProviderGuid: event.sprintf("%{provider_guid}"),
               ProviderName: event.sprintf("%{source_name}"),
               Channel: event.sprintf("%{log_name}"),
               RawXml: event.sprintf("%{xml}"),
               Description: event.sprintf("%{message}"),
               Role: "",
               RoleInstance: "",
               DeploymentId: "",
               EventTickCount: ""
    }
    @azure_service.insert_entity(entity)
    event
  end
end