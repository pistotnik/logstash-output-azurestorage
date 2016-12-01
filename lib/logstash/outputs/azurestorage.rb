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
               message: event.sprintf("%{message}"),
               host: event.sprintf("%{host}"),
               Logfile: event.sprintf("%{Logfile}"),
               message: event.sprintf("%{message}"),
               Category: event.sprintf("%{Category}"),
               ComputerName: event.sprintf("%{ComputerName}"),
               EventIdentifier: event.sprintf("%{EventIdentifier}"),
               EventType: event.sprintf("%{EventType}"),
               RecordNumber: event.sprintf("%{RecordNumber}"),
               SourceName: event.sprintf("%{SourceName}"),
               TimeGenerated: event.sprintf("%{TimeGenerated}"),
               TimeWritten: event.sprintf("%{TimeWritten}"),
               Type: event.sprintf("%{Type}"),
               InsertionStrings: event.sprintf("%{InsertionStrings}") }
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