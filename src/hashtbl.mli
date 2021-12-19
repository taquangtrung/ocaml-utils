(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

module Hashtbl : sig
  val find_or_compute
    :  ('a, 'b) Base.Hashtbl.t ->
    key:'a ->
    f:(unit -> 'b) ->
    'b

  val find_default : ('a, 'b) Base.Hashtbl.t -> 'a -> default:'b -> 'b

  include module type of struct
    include Core.Hashtbl
  end
end
