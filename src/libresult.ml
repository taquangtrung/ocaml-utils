(********************************************************************
 * This file is part of the ocaml-extcore, a collection of extra
 * useful OCaml functions and libraries, implemented on top of Core.
 *
 * Author: Ta Quang Trung.
 ********************************************************************)

open Core

(*******************************************************************
 * Extending library Result with new functionalities
 *******************************************************************)

module Result = struct
  (*** Exceptions to store results ***)

  exception ResBool of bool
  exception ResInt of int
  exception ResFloat of float
  exception ResString of string

  (*** Functions to raise results ***)

  let return_bool b = raise (ResBool b)
  let return_int i = raise (ResInt i)
  let return_float f = raise (ResFloat f)
  let return_string s = raise (ResString s)

  (*** Original Result module ***)

  include Result
end
