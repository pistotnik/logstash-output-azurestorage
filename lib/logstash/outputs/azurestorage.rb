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
    client = Azure::Storage::Client.create(:storage_account_name => @storage_account_name, :storage_access_key => @storage_access_key)
    client.ca_file = File.join(File.dirname(__FILE__), "../../../assets/cacert.pem")
    tables = client.table_client
    tables.create_table(@table_name)
  end

  public
  def receive(event)
    puts event
  end
end