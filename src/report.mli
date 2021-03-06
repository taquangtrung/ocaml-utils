(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

(*** Reporting warning  ***)

val hide_warning_message : bool ref
val warning : string -> unit
val warningp : string -> ('a -> string) -> 'a -> unit

(** Report warning using format template similar to [printf] *)
val warningf
  :  ('a, out_channel, unit, unit, unit, unit) CamlinternalFormatBasics.format6 ->
  'a

(*** Reporting errors ***)

val hide_error_log : bool ref
val error : ?log:string -> string -> 't
val errorp : ?log:string -> string -> ('a -> string) -> 'a -> 't

(** Report error using format template similar to [printf] *)
val errorf
  :  ?log:string ->
  ('a, out_channel, unit, unit, unit, unit) CamlinternalFormatBasics.format6 ->
  'a
