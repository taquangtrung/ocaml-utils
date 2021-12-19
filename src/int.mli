(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

type bint = Big_int.big_int

module BInt : sig
  val pr_bint : bint -> string
  val eq : bint -> bint -> bool
  val gt : bint -> bint -> bool
  val ge : bint -> bint -> bool
  val lt : bint -> bint -> bool
  val le : bint -> bint -> bool
  val compare : bint -> bint -> int
  val of_int : int -> bint
  val of_int32 : int32 -> bint
  val of_int64 : int64 -> bint
  val one : bint
  val minus_one : bint
  val zero : bint
  val sub : bint -> bint -> bint
  val add : bint -> bint -> bint
  val neg : bint -> bint
  val mult : bint -> bint -> bint
  val mult_int_bint : int -> bint -> bint
  val div : bint -> bint -> bint
  val pow_int_positive_int : int -> int -> bint
  val compute_lower_bound_two_complement : int -> bint
  val compute_upper_bound_two_complement : int -> bint
  val compute_range_two_complement : int -> bint * bint
end

module EInt : sig
  type eint = (bint * int) list * bint

  val pr_eint : eint -> string
  val one : eint
  val zero : eint
  val of_int : int -> eint
  val of_int64 : int64 -> eint
  val of_bint : bint -> eint
  val to_bint : eint -> bint

  val add_coeffients_exponents
    :  (bint * int) list ->
    (bint * int) list ->
    (bint * int) list

  val add : eint -> eint -> eint
  val neg : eint -> eint
  val sub : eint -> eint -> eint
  val mult_int_eint : int -> eint -> eint
  val mult_bint_eint : bint -> eint -> eint
  val mult : eint -> eint -> eint
  val div : eint -> eint -> eint
  val compute_lower_bound_two_complement : int -> eint
  val compute_upper_bound_two_complement : int -> eint
  val compute_range_two_complement : int -> eint * eint
end

type eint = EInt.eint
