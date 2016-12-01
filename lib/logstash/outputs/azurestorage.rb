# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "azure/storage"

# An azurestorage output that does nothing.
class LogStash::Outputs::Azurestorage < LogStash::Outputs::Base
  config_name "azurestorage"

  public
  def register
  end # def register

  public
  def receive(event)
    puts event
  end # def event
end # class LogStash::Outputs::Azurestorage
