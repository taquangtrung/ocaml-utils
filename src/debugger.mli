(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

val mode_debug : bool ref
val mode_deep_debug : bool ref
val no_debug : bool ref
val mode_interactive : bool ref
val saved_mode_debug : bool ref
val saved_mode_deep_debug : bool ref
val regex_debug_function : string ref
val mode_debug_function : bool ref
val regex_debug_working_function : string ref
val mode_debug_working_function : bool ref
val is_debug_mode : unit -> bool
val is_interactive_mode : unit -> bool
val enable_mode_debug : unit -> unit
val disable_mode_debug : unit -> unit
val enable_mode_deep_debug : unit -> unit
val save_mode_debug : unit -> unit
val restore_mode_debug : unit -> unit

(*** shallow debugging ***)

val debug
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  string ->
  unit

val hdebug
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  string ->
  ('a -> string) ->
  'a ->
  unit

val debugf
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ('a, unit, string, string, string, unit) format6 ->
  'a

(*** deep debugging ***)

val ddebug
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  string ->
  unit

val hddebug
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  string ->
  ('a -> string) ->
  'a ->
  unit

val ddebugf
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ('a, unit, string, string, string, unit) format6 ->
  'a

(*** interactive debugging ***)

val display_choices : string -> ('a -> string) -> 'a list -> string
val ask_decision : string -> string list -> Base.string
val nask_decision : 'a -> 'b -> unit
