(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

module Sys : sig
  val track_runtime : f:(unit -> 'a) -> 'a * float
  val print_runtime : msg:string -> f:(unit -> 'a) -> 'a
  val record_runtime : f:(unit -> 'a) -> float ref -> 'a
  val is_os_unix : unit -> bool
  val remove_dir : string -> unit
  val remove_file : string -> unit
  val make_dir : string -> unit

  include module type of struct
    include Core.Sys
  end
end
