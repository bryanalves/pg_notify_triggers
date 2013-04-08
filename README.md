pg\_notify\_triggers
==================

This is a trigger system that allows clients to get notified of changes to postgres tables in (near) realtime.

Requirements
============

* Postgresql 9.2

Installation
============

    psql databasename < install.sql
    echo "SELECT add_notify_trigger_to_table('TABLENAME') | psql databasename

Removing notifications for a table
==================================

    echo "SELECT remove_notify_trigger_to_table('TABLENAME') | psql databasename

Use cases
=========

* Realtime updating of external indexes, such as Elastic Search.
* Monitoring of action-driven tables (ie. send an internal email for every new user)
* Reporting and paper trail of updates.
* Realtime pushes to reporting databases
* Realtime ETL
