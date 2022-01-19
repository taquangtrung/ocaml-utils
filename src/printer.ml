(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

(* Printer module *)

open Core
open Outils__String
module FM = CamlinternalFormat
module FB = CamlinternalFormatBasics

let no_print = ref false

(*******************************************************************
 ** String printing functions
 *******************************************************************)

(*---------------------------
 * Basic printing functions
 *--------------------------*)

let pr_bool : bool -> string = string_of_bool
let pr_float : float -> string = string_of_float
let pr_int : int -> string = string_of_int
let pr_int64 : int64 -> string = Int64.to_string
let pr_str : string -> string = fun s -> s

(*------------------
 * Print to string
 *-----------------*)

(** print option *)
let pr_option ~(f : 'a -> string) (x : 'a option) =
  match x with
  | Some v -> "Some(" ^ f v ^ ")"
  | None -> "None"
;;

let pr_bool_option (x : bool option) = pr_option ~f:pr_bool x

(** print a list to string *)
let pr_list
    ?(sep = ", ")
    ?(obrace = "[")
    ?(cbrace = "]")
    ?(indent = "")
    ?(extra = "")
    ~(f : 'a -> string)
    (xs : 'a list)
  =
  let xs = List.map ~f xs in
  let extra =
    if String.equal obrace ""
    then extra
    else if String.is_substring sep ~substring:"\n"
    then
      if String.is_empty (String.strip_newline obrace)
      then extra
      else String.mk_indent 2 ^ extra
    else extra in
  let content =
    match xs with
    | [] -> ""
    | [ x ] -> x
    | x :: nxs ->
      let xs = x :: List.map ~f:(fun u -> indent ^ extra ^ u) nxs in
      String.concat ~sep xs in
  let obrace, cbrace =
    if (not (String.is_substring content ~substring:"\n"))
       || String.is_empty (String.strip_newline obrace)
    then obrace, cbrace
    else indent ^ obrace ^ " ", " " ^ cbrace in
  obrace ^ content ^ cbrace
;;

let pr_list_square = pr_list ~obrace:"[" ~cbrace:"]"
let pr_list_curly = pr_list ~obrace:"{" ~cbrace:"}"
let pr_list_paren = pr_list ~obrace:"(" ~cbrace:")"
let pr_list_plain = pr_list ~obrace:"" ~cbrace:""

(** print a list of items to string in itemized autoformat *)
let pr_items
    ?(bullet = "-")
    ?(obrace = "")
    ?(cbrace = "")
    ?(sep = "\n")
    ?(extra = "")
    ~(f : 'a -> string)
    (xs : 'a list)
  =
  let xs = List.map ~f xs in
  if List.is_empty xs
  then "[]"
  else (
    let pr_item s = bullet ^ " " ^ s in
    "\n" ^ pr_list ~sep ~obrace ~cbrace ~extra ~f:pr_item xs)
;;

let pr_args ~(f : 'a -> string) (args : 'a list) : string =
  pr_list ~sep:", " ~obrace:"" ~cbrace:"" ~f args
;;

let pr_pair ~(f1 : 'a -> string) ~(f2 : 'b -> string) (p : 'a * 'b) : string =
  let x, y = p in
  "(" ^ f1 x ^ ", " ^ f2 y ^ ")"
;;

let sprintf = Printf.sprintf

let beautiful_concat ?(column = 80) ~(sep : string) (strs : string list) =
  let rec concat strs current_line res =
    match strs with
    | [] ->
      if String.is_empty current_line
      then res
      else if String.is_empty res
      then current_line
      else String.strip res ^ "\n" ^ current_line
    | str :: nstrs ->
      let new_line =
        if List.is_empty nstrs
        then current_line ^ str
        else current_line ^ str ^ sep in
      if String.length new_line <= column
      then concat nstrs new_line res
      else (
        let res =
          if String.is_empty res
          then current_line
          else String.strip res ^ "\n" ^ current_line in
        if List.is_empty nstrs
        then concat nstrs str res
        else concat nstrs (str ^ sep) res) in
  concat strs "" ""
;;

let beautiful_format_on_char ~(sep : char) ?(column = 80) (str : string) =
  let strs = String.split ~on:sep str in
  beautiful_concat ~sep:(Char.to_string sep) ~column strs
;;

let format_message
    ?(mtype = "")
    ?(header = false)
    ?(ruler = `None)
    ?(prefix = "")
    ?(indent = 0)
    ?(autoformat = true)
    (msg : string)
    : string
  =
  let indicator, indent =
    if String.is_empty mtype
    then "", indent
    else "[" ^ mtype ^ "] ", indent + 2 in
  if header
  then (
    let msg = if String.is_empty msg then msg else "\n\n" ^ msg ^ "\n" in
    "\n" ^ String.make 68 '*' ^ "\n" ^ indicator ^ prefix ^ msg)
  else (
    match ruler with
    | `Long -> "\n" ^ String.make 68 '*' ^ "\n" ^ indicator ^ prefix ^ msg
    | `Medium -> "\n" ^ String.make 36 '=' ^ "\n" ^ indicator ^ prefix ^ msg
    | `Short -> "\n" ^ String.make 21 '-' ^ "\n" ^ indicator ^ prefix ^ msg
    | `None ->
      if not autoformat
      then msg
      else if String.is_prefix ~prefix:"\n" msg
              || (String.length prefix > 1
                 && String.is_suffix ~suffix:"\n" prefix)
      then (
        let indent = String.count_indent prefix + indent in
        indicator ^ prefix ^ String.indent ~skipfirst:true indent msg)
      else if String.length prefix > 12 && String.is_infix ~infix:"\n" msg
      then
        indicator ^ prefix ^ "\n" ^ String.indent ~skipfirst:false indent msg
      else indicator ^ String.indent ~skipfirst:true indent (prefix ^ msg))
;;

(*******************************************************************
 ** Stdout printing functions
 *******************************************************************)

(** core printing function *)
let print_core
    ?(mtype = "info")
    ?(header = false)
    ?(ruler = `None)
    ?(prefix = "")
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    ?(autoformat = true)
    (msg : string)
    : unit
  =
  if ((not !no_print) && enable) || always
  then (
    let msg =
      format_message ~mtype ~header ~ruler ~prefix ~indent ~autoformat msg
    in
    print_endline msg)
  else ()
;;

(** print a message *)
let print
    ?(mtype = "info")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    ?(autoformat = true)
    (msg : string)
    : unit
  =
  print_core ~header ~ruler ~indent ~always ~enable ~mtype ~autoformat msg
;;

(** print a message and a newline character *)
let println
    ?(mtype = "info")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    ?(autoformat = true)
    (msg : string)
    : unit
  =
  let msg = msg ^ "\n" in
  print_core ~header ~ruler ~indent ~always ~enable ~mtype ~autoformat msg
;;

(** print a message using a printer *)
let printp
    ?(mtype = "info")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    ?(autoformat = true)
    (prefix : string)
    (f : 'a -> string)
    (v : 'a)
  =
  let msg = f v in
  print_core ~header ~ruler ~indent ~prefix ~always ~enable ~mtype ~autoformat
    msg
;;

(** Print message use format template similar to printf. *)
let printf
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    ?(autoformat = true)
    (fmt : ('a, unit, string, string, string, unit) format6)
    : 'a
  =
  let kprintf k (FB.Format (fmt, _)) =
    let print_msg acc =
      let buf = Buffer.create 64 in
      let _ = FM.strput_acc buf acc in
      let msg = Buffer.contents buf in
      print ~mtype ~header ~ruler ~indent ~always ~enable ~autoformat msg in
    FM.make_printf (fun acc -> print_msg acc; k ()) FM.End_of_acc fmt in
  kprintf (fun s -> s) fmt
;;
