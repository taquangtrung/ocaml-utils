(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

val no_print : bool ref
val pr_bool : bool -> string
val pr_float : float -> string
val pr_int : int -> string
val pr_int64 : int64 -> string
val pr_str : string -> string
val pr_option : f:('a -> string) -> 'a option -> string
val pr_bool_option : bool option -> string

val pr_list
  :  ?sep:string ->
  ?obrace:string ->
  ?cbrace:string ->
  ?indent:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_list_square
  :  ?sep:string ->
  ?indent:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_list_curly
  :  ?sep:string ->
  ?indent:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_list_paren
  :  ?sep:string ->
  ?indent:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_list_plain
  :  ?sep:string ->
  ?indent:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_items
  :  ?bullet:string ->
  ?obrace:string ->
  ?cbrace:string ->
  ?sep:string ->
  ?extra:string ->
  f:('a -> string) ->
  'a list ->
  string

val pr_args : f:('a -> string) -> 'a list -> string
val pr_pair : f1:('a -> string) -> f2:('b -> string) -> 'a * 'b -> string

(*** Formatting strings *)

val beautiful_concat : ?column:int -> sep:string -> string list -> string
val beautiful_format_on_char : sep:char -> ?column:int -> string -> string

(*** Printing ***)

val print
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ?autoformat:bool ->
  string ->
  unit

val println
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ?autoformat:bool ->
  string ->
  unit

val hprint
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ?autoformat:bool ->
  string ->
  ('a -> string) ->
  'a ->
  unit

val printf
  :  ?mtype:string ->
  ?header:bool ->
  ?ruler:[< `Long | `Medium | `None | `Short > `None ] ->
  ?indent:int ->
  ?always:bool ->
  ?enable:bool ->
  ?autoformat:bool ->
  ('a, unit, string, string, string, unit) format6 ->
  'a

(*** Wrapping OCaml printing functions ***)
val sprintf : ('a, unit, string) format -> 'a
