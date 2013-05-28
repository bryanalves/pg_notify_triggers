#!/usr/bin/env ruby
require 'thor'
require 'pg'

class PGNotify < Thor
  desc "list <connstring>", "Lists all tables with the trigger installed for the database in <connstring>"
  def list(connstring)
    puts _list(connstring).to_a
  end

  desc "add <connstring> <tablename>", "Adds the trigger for <table> on the database in <connstring>"
  def add(connstring, tablename)
    conn = PGconn.open(connstring)
    conn.exec("SELECT add_notify_trigger_to_table('#{tablename}')")
  end

  desc "remove <connstring> <tablename>", "Removes the trigger for <table> on the database in <connstring>"
  def remove(connstring, tablename)
    conn = PGconn.open(connstring)
    conn.exec("SELECT remove_notify_trigger_from_table('#{tablename}')")
  end

  desc "clear <connstring", "Removes the trigger for all tables on the database in <connstring>"
  def clear(connstring)
    tables_to_remove = _list(connstring)
    tables_to_remove.each { |t| remove(connstring, t) }
  end

  private

  def _list(connstring)
    sql = "
      SELECT relname
      FROM pg_trigger JOIN pg_class ON tgrelid = pg_class.oid
      WHERE tgname = 'notify_trigger_event'
    "
    conn = PGconn.open(connstring)
    res = conn.exec(sql)
    res.map do |r|
      r["relname"]
    end
  end
end

PGNotify.start
