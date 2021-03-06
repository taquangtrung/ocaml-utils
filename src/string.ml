(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

open Core

(*******************************************************************
 * Extending library String with new functionalities
 *******************************************************************)

module String = struct
  (*--------------------------------
   * New functions handling string
   *-------------------------------*)

  let not_empty (str : string) : bool = not (String.is_empty str)

  let is_infix ~(infix : string) (str : string) : bool =
    let idxs = String.substr_index_all ~may_overlap:false ~pattern:infix str in
    let len, sublen = String.length str, String.length infix in
    List.exists
      ~f:(fun idx -> Int.( > ) idx 0 && Int.( < ) idx (len - sublen))
      idxs
  ;;

  let strip_newline (str : string) : string =
    String.strip ~drop:(fun c -> Char.( = ) c '\n') str
  ;;

  let prefix_if_not_empty (s : string) ~(prefix : string) : string =
    if String.is_empty s then s else prefix ^ s
  ;;

  let suffix_if_not_empty (s : string) ~(suffix : string) : string =
    if String.is_empty s then s else s ^ suffix
  ;;

  let surround_if_not_empty (s : string) ~prefix ~suffix : string =
    if String.is_empty s then s else prefix ^ s ^ suffix
  ;;

  let replace_if_empty (s : string) ~(replacer : string) : string =
    if String.is_empty s then replacer else s
  ;;

  let concat_if_not_empty (strs : string list) ~(sep : string) : string =
    let strs = List.filter ~f:not_empty strs in
    String.concat ~sep strs
  ;;

  (** Slice from a string pattern (pattern is included) *)
  let slice_from ~(pattern : string) (s : string) : string option =
    match String.substr_index s ~pattern with
    | Some idx -> Some (String.slice s idx (String.length s))
    | None -> None
  ;;

  (** Slice to a string pattern (pattern is not included) *)
  let slice_to ~(pattern : string) (s : string) : string option =
    match String.substr_index s ~pattern with
    | Some idx -> Some (String.slice s 0 idx)
    | None -> None
  ;;

  let find_line_contain ~(pattern : string) (s : string) : string option =
    let lines = String.split_lines s in
    List.find ~f:(String.is_substring ~substring:pattern) lines
  ;;

  (*-----------------------
   * Formatting string
   *----------------------*)

  let count_indent (str : string) : int =
    let str = String.lstrip ~drop:(fun c -> Char.equal c '\n') str in
    let idx = String.lfindi ~f:(fun _ c -> Char.( <> ) c ' ') str in
    match idx with
    | None -> 0
    | Some i -> i
  ;;

  let mk_indent (indent : int) : string =
    let rec mk_whitespace (i : int) : string =
      if i <= 0 then "" else " " ^ mk_whitespace (i - 1) in
    mk_whitespace indent
  ;;

  (** format a message by insert an indentation to each line *)

  let indent ?(skipfirst = false) (indent : int) (msg : string) : string =
    let sindent = mk_indent indent in
    msg |> String.split ~on:'\n'
    |> List.mapi ~f:(fun i s -> if i = 0 && skipfirst then s else sindent ^ s)
    |> String.concat ~sep:"\n"
  ;;

  (** high-order insert an indentation to each line of a message *)
  let hindent ?(skipfirst = false) (i : int) (f : 'a -> string) (v : 'a)
      : string
    =
    indent ~skipfirst i (f v)
  ;;

  (** auto-insert indentation to align_line with the prefix string *)
  let align_line (prefix : string) (msg : string) : string =
    let prefix = String.strip ~drop:(fun c -> Char.( = ) c '\n') prefix in
    let indentation = String.length prefix in
    let skipfirst = not (String.is_suffix ~suffix:"\n" prefix) in
    prefix ^ indent ~skipfirst indentation msg
  ;;

  (** high-order auto-insert indentation to align_line with the prefix string *)
  let halign_line prefix (f : 'a -> string) (v : 'a) : string =
    align_line prefix (f v)
  ;;

  (** insert a prefix to each line of a string *)
  let prefix_line ~(prefix : string) (msg : string) : string =
    msg |> String.split_lines
    |> List.map ~f:(fun s -> prefix ^ s)
    |> String.concat ~sep:"\n"
  ;;

  (*--------------------------------------
   * Include the existing String library
   *-------------------------------------*)

  include Core.String
end
