(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

module Math : sig
  val max_ints : int list -> int
  val min_ints : int list -> int
  val gcd : int -> int -> int
  val gcd_ints : int list -> int
  val lcm : int -> int -> int
  val lcm_ints : int list -> int
  val gen_combinations : int -> 'a list -> 'a list list
  val gen_permutations : 'a list -> 'a list list
  val gen_combinations_with_repetition : int -> 'a list -> 'a list list
  val gen_permutations_with_repetition : int -> 'a list -> 'a list list
  val gen_cartesian : 'a list list -> 'a list list
  val gen_all_subsets : 'a list -> 'a list list
end
