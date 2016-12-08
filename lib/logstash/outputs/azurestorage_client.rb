require 'logstash/outputs/base'
require 'logstash/namespace'
require 'azure/storage'

class LogStash::Outputs::AzureStorageClient
  def initialize(table_name)
    @table_name = table_name
  end

  def init
    setup_azure_storage_connection()
    create_table_if_not_exists(@table_name)
  end

  def insert_entity(entity_values)
    tables = Azure::Storage::Table::TableService.new
    tables.insert_entity(@table_name, entity_values)
  end

  private
  def create_table_if_not_exists(table_name)
    tables = Azure::Storage::Table::TableService.new
    begin
      tables.create_table(table_name)
    rescue

    end
  end

  def setup_azure_storage_connection
    Azure::Storage.setup(:storage_account_name => @storage_account_name, :storage_access_key => @storage_access_key)
    Azure::Storage.client.ca_file = File.join(File.dirname(__FILE__), "../../../assets/cacert.pem")
  end
end