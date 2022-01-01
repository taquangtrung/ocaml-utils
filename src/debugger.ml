(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

(* Printer module *)
open Core
open Extcore__String
module FM = CamlinternalFormat
module FB = CamlinternalFormatBasics

(*------------------
 * debugging flags
 *-----------------*)

let mode_debug = ref false
let mode_deep_debug = ref false
let no_debug = ref false

(*-------------------
 * Interactive mode
 *------------------*)

let mode_interactive = ref false

(*----------------
 * Saving states
 *---------------*)

let saved_mode_debug = ref false
let saved_mode_deep_debug = ref false

(*----------------------
 * Debugging functions
 *---------------------*)

let regex_debug_function = ref ""
let mode_debug_function = ref false

(*------------------------------
 * Debugging working functions
 *-----------------------------*)

let regex_debug_working_function = ref ""
let mode_debug_working_function = ref false

(*******************************************************************
 ** Utility functions
 *******************************************************************)

let is_debug_mode () = !mode_debug || !mode_deep_debug
let is_interactive_mode () = !mode_interactive
let enable_mode_debug () = mode_debug := true
let disable_mode_debug () = mode_debug := false

let enable_mode_deep_debug () =
  mode_debug := true;
  mode_deep_debug := true
;;

let save_mode_debug () : unit =
  saved_mode_debug := !mode_debug;
  saved_mode_deep_debug := !mode_deep_debug
;;

let restore_mode_debug () : unit =
  mode_debug := !saved_mode_debug;
  mode_deep_debug := !saved_mode_deep_debug
;;

(*******************************************************************
 ** Debugging functions
 *******************************************************************)

(*----------------------
 * first-order printer
 *---------------------*)

(** core mode_debug function *)
let debug_core
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(prefix = "")
    ?(indent = 0)
    ?(enable = true)
    (print_msg : unit -> string)
  =
  if enable
  then (
    let msg = print_msg () in
    let str_msg_type =
      if String.is_empty mtype then "" else "[" ^ mtype ^ "] " in
    let msg =
      if header
      then (
        let prefix = String.suffix_if_not_empty prefix ~suffix:"\n" in
        "\n" ^ String.make 68 '*' ^ "\n" ^ str_msg_type ^ prefix ^ msg)
      else (
        match ruler with
        | `Long ->
          let ruler = String.make 68 '*' ^ "\n" in
          "\n" ^ ruler ^ "\n" ^ str_msg_type ^ prefix ^ msg
        | `Medium ->
          let ruler = String.make 36 '*' in
          "\n" ^ ruler ^ "\n" ^ str_msg_type ^ prefix ^ msg
        | `Short ->
          let ruler = String.make 21 '-' in
          "\n" ^ ruler ^ "\n" ^ str_msg_type ^ prefix ^ msg
        | `None ->
          let msg = if String.not_empty mtype then msg else msg in
          if String.is_prefix ~prefix:"\n" msg
             || (String.length prefix > 1
                && String.is_suffix ~suffix:"\n" prefix)
          then (
            let indent = String.count_indent prefix + 2 + indent in
            str_msg_type ^ prefix ^ String.indent indent msg)
          else if String.length prefix > 12 && String.is_infix ~infix:"\n" msg
          then (
            let indent = String.count_indent prefix + 2 + indent in
            str_msg_type ^ prefix ^ "\n" ^ String.indent indent msg)
          else
            String.indent indent
              (String.align_line (str_msg_type ^ prefix) msg)) in
    print_endline msg)
  else ()
;;

(*** simple debugging printers ***)

(** print a message *)
let debug
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    (msg : string)
    : unit
  =
  let enable =
    enable && (not !no_debug) && (!mode_debug || !mode_deep_debug || always)
  in
  let prefix =
    if not (Core.phys_equal ruler `None)
    then ""
    else if String.not_empty mtype
    then ""
    else "\n" in
  debug_core ~header ~ruler ~indent ~enable ~prefix (fun () -> msg)
;;

(** high-order print a mode_debug message *)
let hdebug
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    (msg : string)
    (pr : 'a -> string)
    (data : 'a)
  =
  let enable =
    enable && (not !no_debug) && (!mode_debug || !mode_deep_debug || always)
  in
  let printer () = pr data in
  debug_core ~header ~ruler ~indent ~enable ~prefix:msg ~mtype printer
;;

(** Print debug message use format template similar to printf. *)
let debugf
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    (fmt : ('a, unit, string, string, string, unit) format6)
    : 'a
  =
  let kdprintf k (FB.Format (fmt, _)) =
    let print_msg acc =
      let buf = Buffer.create 64 in
      let _ = FM.strput_acc buf acc in
      let msg = Buffer.contents buf in
      (* let _ = FM.output_acc o acc in *)
      (* ignore (exit 1) in *)
      debug ~mtype ~header ~ruler ~indent ~always ~enable msg in
    FM.make_printf (fun acc -> print_msg acc; k ()) FM.End_of_acc fmt in
  kdprintf (fun s -> s) fmt
;;

(*** deep debugging printers ***)

(** print a deep mode_debug message *)
let ddebug
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    (msg : string)
    : unit
  =
  let enable = enable && (not !no_debug) && (!mode_deep_debug || always) in
  let printer () = msg in
  debug_core ~header ~ruler ~indent ~enable ~prefix:msg ~mtype printer
;;

(** high-order print a deep mode_debug message *)
let hddebug
    ?(mtype = "debug")
    ?(header = false)
    ?(ruler = `None)
    ?(indent = 0)
    ?(always = false)
    ?(enable = true)
    (msg : string)
    (pr : 'a -> string)
    (data : 'a)
  =
  let enable = enable && (not !no_debug) && (!mode_deep_debug || always) in
  let printer () = pr data in
  debug_core ~header ~ruler ~indent ~enable ~mtype ~prefix:msg printer
;;

(*** disable debugging printers ***)

let ndebug _ = ()
let nhdebug _ _ _ = ()
let nhddebug _ _ _ = ()

(*******************************************************************
 ** Interactive debugging
 *******************************************************************)

(** display choices and return a range *)

let display_choices msg (pr_choice : 'a -> string) (choices : 'a list) : string
  =
  let all_choices =
    choices
    |> List.mapi ~f:(fun idx c ->
           " [" ^ string_of_int (idx + 1) ^ "]. " ^ pr_choice c)
    |> String.concat ~sep:"\n" in
  let _ = print_endline (msg ^ "\n" ^ all_choices) in
  let range =
    let num_choices = List.length choices in
    if num_choices = 1 then "1" else "1" ^ ".." ^ string_of_int num_choices
  in
  range
;;

(** answer choices can be in the form [s1; s2; "i..j"], where s1, s2 are
    some strings, and i, j are the lower and upper bound integer of a range *)

let rec ask_decision question (answer_choices : string list) : string =
  let all_choices = "[" ^ String.concat ~sep:"/" answer_choices ^ "]" in
  let msg = question ^ " " ^ all_choices ^ ": " in
  let _ = print_string ("\n$$$>>> " ^ msg) in
  (* let _ = Core.flush_all () in *)
  let answer = String.strip In_channel.(input_line_exn stdin) in
  let is_valid_choice =
    List.exists
      ~f:(fun str ->
        if String.equal answer str
        then true
        else (
          try
            let index_answer = int_of_string answer in
            let regexp = Str.regexp "\\([0-9]+\\)\\.\\.\\([0-9]+\\)" in
            if Str.string_match regexp str 0
            then (
              let index_begin = int_of_string (Str.matched_group 1 str) in
              let index_end = int_of_string (Str.matched_group 2 str) in
              index_begin <= index_answer && index_answer <= index_end)
            else false
          with _ -> false))
      answer_choices in
  if not is_valid_choice
  then (
    let _ = print_endline "\n>>> Choose again!" in
    ask_decision question answer_choices)
  else answer
;;

let nask_decision _ _ = ()
