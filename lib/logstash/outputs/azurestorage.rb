# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "azure/storage"

class LogStash::Outputs::Azurestorage < LogStash::Outputs::Base
  config_name "azurestorage"

  config :storage_account_name, :validate => :string
  config :storage_access_key, :validate => :string
  config :table_name, :validate => :string

  public
  def register
    setup_azure_storage_connection()
    create_table_if_not_exists(@table_name)
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
    tables = Azure::Storage::Table::TableService.new
    tables.insert_entity(@table_name, entity)
  end

  private
  def create_table_if_not_exists(table_name)
    tables = Azure::Storage::Table::TableService.new
    begin
      tables.create_table(@table_name)
    rescue

    end
  end

  def setup_azure_storage_connection()
    Azure::Storage.setup(:storage_account_name => @storage_account_name, :storage_access_key => @storage_access_key)
    Azure::Storage.client.ca_file = File.join(File.dirname(__FILE__), "../../../assets/cacert.pem")
  end
end