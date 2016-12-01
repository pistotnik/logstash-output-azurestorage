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
    puts event
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