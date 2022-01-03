(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

module Result : sig
  exception ResBool of bool
  exception ResInt of int
  exception ResFloat of float
  exception ResString of string

  val return_bool : bool -> 'a
  val return_int : int -> 'a
  val return_float : float -> 'a
  val return_string : string -> 'a

  include module type of struct
    include Core.Result
  end
end
