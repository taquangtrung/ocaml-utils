(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

open Core

(*******************************************************************
 * Extending library Sys with new functionalities
 *******************************************************************)

module Sys = struct
  (*--------------------------------
   * New functions
   *-------------------------------*)

  let track_runtime ~(f : unit -> 'a) : 'a * float =
    let time_begin = Unix.gettimeofday () in
    let res = f () in
    let time_end = Unix.gettimeofday () in
    let time = time_end -. time_begin in
    res, time
  ;;

  let print_runtime ~(msg : string) ~(f : unit -> 'a) : 'a =
    let res =
      if String.is_empty msg
      then f ()
      else (
        let time_begin = Unix.gettimeofday () in
        let res = f () in
        let time_end = Unix.gettimeofday () in
        let time = time_end -. time_begin in
        let _ = print_endline (msg ^ ": " ^ sprintf "%.3fs" time) in
        res) in
    res
  ;;

  let record_runtime ~(f : unit -> 'a) (time : float ref) : 'a =
    let time_begin = Unix.gettimeofday () in
    let res = f () in
    let time_end = Unix.gettimeofday () in
    time := !time +. (time_end -. time_begin);
    res
  ;;

  let is_os_unix () : bool = String.equal Sys.os_type "Unix"

  let remove_dir (filename : string) : unit =
    if is_os_unix ()
    then ignore (Sys.command ("rm -rf " ^ filename))
    else print_endline ("TODO: remove_dir: need to support " ^ Sys.os_type)
  ;;

  let remove_file (filename : string) : unit =
    if is_os_unix ()
    then ignore (Sys.command ("rm -f " ^ filename))
    else print_endline ("TODO: remove_file: need to support " ^ Sys.os_type)
  ;;

  let make_dir (dirname : string) : unit =
    match Sys.file_exists dirname with
    | `No -> ignore (Sys.command ("mkdir -p " ^ dirname))
    | _ ->
      (match Sys.is_directory dirname with
      | `No ->
        failwith
          ("Failed to make dir: " ^ dirname ^ "."
         ^ "A regular file of the same name already exists.")
      | _ -> ())
  ;;

  type os_type =
    | Linux
    | MacOS
    | Win32
    | Cygwin
    | UnkownOS

  let pr_os_type (os : os_type) =
    match os with
    | Linux -> "Linux"
    | MacOS -> "MacOS"
    | Win32 -> "Windows 32bit"
    | Cygwin -> "Cygwin"
    | UnkownOS -> "Uknown OS"
  ;;

  let get_os_type () =
    if String.equal Sys.os_type "Win32"
    then Win32
    else if String.equal Sys.os_type "Cygwin"
    then Cygwin
    else if String.equal Sys.os_type "Unix"
    then (
      let ic = Unix.open_process_in "uname" in
      let uname = input_line ic in
      let _ = close_in ic in
      if String.equal uname "Linux"
      then Linux
      else if String.equal uname "Darwin"
      then MacOS
      else UnkownOS)
    else UnkownOS
  ;;

  (*--------------------------------------
   * Include the existing Sys library
   *-------------------------------------*)

  include Sys
end
