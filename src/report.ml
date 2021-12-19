(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

open Core
open Extcore__String
module FM = CamlinternalFormat
module FB = CamlinternalFormatBasics

(*******************************************************************
 ** Warning printing
 *******************************************************************)

let hide_warning_message = ref false

(** Print a warning message *)
let warning (msg : string) : unit =
  let msg = "[warning] " ^ msg in
  if not !hide_warning_message then prerr_endline msg
;;

(** High-order print a warning message *)
let warningh (prefix : string) (f : 'a -> string) (x : 'a) : unit =
  let msg = prefix ^ f x in
  warning msg
;;

(** Print a warning message using output format template similar to printf. *)
let warningf (fmt : ('a, Out_channel.t, unit, unit, unit, unit) format6) : 'a =
  let _ = print_string "[warning] " in
  let kwprintf k o (FB.Format (fmt, _)) =
    FM.make_printf (fun acc -> FM.output_acc o acc; k o) FM.End_of_acc fmt
  in
  kwprintf ignore stdout fmt
;;

(*******************************************************************
 ** Error printing
 *******************************************************************)

let hide_error_log = ref false

let print_error_log (log : string) : unit =
  if (not !hide_error_log) && String.not_empty log
  then print_endline ("\n[Error log]\n" ^ String.indent 2 log)
  else ()
;;

(** Report an error message and exit the program. *)
let error ?(log = "") (msg : string) : 't =
  let _ = print_endline ("ERROR: " ^ msg) in
  let _ = print_error_log log in
  exit 1
;;

(** High-order report an error message and exit the program. *)
let errorh ?(log = "") (prefix : string) (f : 'a -> string) (x : 'a) : 't =
  let msg = prefix ^ f x in
  error ~log msg
;;

(** Report error using output format template similar to printf,
    and exit the program. *)
let errorf
    ?(log = "")
    (fmt : ('a, Out_channel.t, unit, unit, unit, unit) format6)
    : 'a
  =
  let _ = print_string "ERROR: " in
  let keprintf k o (FB.Format (fmt, _)) =
    let print_error_and_exit o acc =
      let _ = FM.output_acc o acc in
      let _ = print_error_log log in
      ignore (exit 1) in
    FM.make_printf
      (fun acc -> print_error_and_exit o acc; k o)
      FM.End_of_acc fmt in
  keprintf ignore stdout fmt
;;
