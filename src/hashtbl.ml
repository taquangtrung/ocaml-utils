(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

open Core

(*******************************************************************
 * Extending Hashtbl with new functionalities
 *******************************************************************)

module Hashtbl = struct
  let find_or_compute (tbl : ('a, 'b) Hashtbl.t) ~(key : 'a) ~(f : unit -> 'b)
      : 'b
    =
    match Hashtbl.find tbl key with
    | Some data -> data
    | None ->
      let data = f () in
      let _ = Hashtbl.set tbl ~key ~data in
      data
  ;;

  let find_default (tbl : ('a, 'b) Hashtbl.t) (key : 'a) ~(default : 'b) : 'b =
    match Hashtbl.find tbl key with
    | None -> default
    | Some v -> v
  ;;

  (*--------------------------------------
   * Include the existing Hashtbl library
   *-------------------------------------*)

  include Hashtbl
end
