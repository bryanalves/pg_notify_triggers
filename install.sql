CREATE OR REPLACE FUNCTION notify_trigger() RETURNS trigger AS
$$
DECLARE
  message text := '{"undefined": True}';
  result record;
BEGIN
  IF TG_OP = 'INSERT' THEN
    message := '{"table": "' || TG_TABLE_NAME || '",
      "operation": "insert",
      "event_time": "' || CURRENT_TIMESTAMP || '",
      "new_data": ' || row_to_json(NEW) || '}';

  ELSIF TG_OP = 'UPDATE' THEN
    message := '{"table": "' || TG_TABLE_NAME || '",
      "operation": "update",
      "event_time": "' || CURRENT_TIMESTAMP || '",
      "old_data":' || row_to_json(OLD) || ',
      "new_data": ' || row_to_json(NEW) || '}';

  ELSIF TG_OP = 'DELETE' THEN
    message := '{"table": "' || TG_TABLE_NAME || '",
      "operation": "delete",
      "event_time": "' || CURRENT_TIMESTAMP || '",
      "old_data": ' || row_to_json(OLD) || '}';
  END IF;

  PERFORM pg_notify(TG_TABLE_NAME::text, message);

  RETURN NULL;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION add_notify_trigger_to_table(table_name text) RETURNS VOID AS
$$
BEGIN
  EXECUTE 'DROP TRIGGER IF EXISTS notify_trigger_event ON ' || table_name::regclass;

  EXECUTE '
    CREATE TRIGGER notify_trigger_event
      AFTER INSERT OR UPDATE OR DELETE
      ON ' || table_name::regclass || '
      FOR EACH ROW
      EXECUTE PROCEDURE notify_trigger()
  ';

END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION remove_notify_trigger_from_table(table_name text) RETURNS VOID AS
$$
BEGIN
  EXECUTE 'DROP TRIGGER IF EXISTS notify_trigger_event ON ' || table_name::regclass;
END;
$$ language plpgsql;

