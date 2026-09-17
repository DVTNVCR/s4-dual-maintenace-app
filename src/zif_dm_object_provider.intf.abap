INTERFACE zif_dm_object_provider
  PUBLIC.

  TYPES:
    BEGIN OF ty_object,
      transport_id TYPE c LENGTH 20,
      pgmid        TYPE c LENGTH 4,
      object_type  TYPE c LENGTH 4,
      object_name  TYPE c LENGTH 120,
      tabkey       TYPE c LENGTH 120,
      evidence_uri TYPE c LENGTH 255,
    END OF ty_object,
    tt_object TYPE STANDARD TABLE OF ty_object WITH EMPTY KEY.

  METHODS get_objects
    RETURNING
      VALUE(rt_objects) TYPE tt_object.
ENDINTERFACE.
