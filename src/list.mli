(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

module List : sig
  val not_empty : 'a list -> bool
  val not_mem : 'a list -> 'a -> equal:('a -> 'a -> bool) -> bool
  val is_inter : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> bool
  val not_inter : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> bool
  val is_subset : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> bool
  val not_subset : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> bool
  val exclude : f:('a -> bool) -> 'a list -> 'a list
  val extract_nth : int -> 'a list -> ('a * 'a list) option
  val insert_dedup : 'a list -> 'a -> equal:('a -> 'a -> bool) -> 'a list
  val append_dedup : 'a list -> 'a -> equal:('a -> 'a -> bool) -> 'a list
  val concat_dedup : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> 'a list
  val dedup : 'a list -> equal:('a -> 'a -> bool) -> 'a list
  val diff : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> 'a list
  val diff_dedup : 'a list -> 'a list -> equal:('a -> 'a -> bool) -> 'a list
  val remove : 'a list -> 'a -> equal:('a -> 'a -> bool) -> 'a list
  val sorti : compare:('a -> 'a -> int) -> 'a list -> 'a list
  val sortd : compare:('a -> 'a -> int) -> 'a list -> 'a list

  val insert_sorti_dedup
    :  'a list ->
    'a ->
    compare:('a -> 'a -> int) ->
    'a list

  val concat_sorti_dedup
    :  'a list ->
    'a list ->
    compare:('a -> 'a -> int) ->
    'a list

  val exists_monad : f:('a -> bool option) -> 'a list -> bool option
  val filter_monad : f:('a -> bool option) -> 'a list -> 'a list

  val eval_return_if
    :  default:'a ->
    return:('a -> bool) ->
    (unit -> 'a) list ->
    'a

  module OrderedList : sig
    type 'a t

    val of_list : 'a list -> compare:('a -> 'a -> int) -> 'a t
    val to_list : 'a t -> 'a list
    val insert : 'a t -> 'a -> 'a t
    val concat : 'a t -> 'a list -> 'a t
  end

  include module type of struct
    include Core.List
  end
end
