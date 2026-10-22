# TilapiaSize PostgreSQL

PostgreSQL is the persistent database selected for TilapiaSize.

The final schema should be created from the approved system requirements and ERD before production implementation. Current confirmed persistence areas include user accounts and grading results. Additional tables such as batches, image references, and grading configuration should only be finalized when their fields and relationships are approved.

Application code must access PostgreSQL through the backend API. Flutter must not connect directly to the database.
