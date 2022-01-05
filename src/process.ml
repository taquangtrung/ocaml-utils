(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

open Core
open Outils__String

type process =
  { proc_exe : string;
    proc_cmd : string list;
    proc_pid : int;
    proc_in_channel : In_channel.t;
    proc_out_channel : Out_channel.t;
    proc_err_channel : In_channel.t
  }

let mk_process (cmd : string list) pid inchn outchn errchn : process =
  { proc_exe = (try List.hd_exn cmd with _ -> "");
    proc_cmd = cmd;
    proc_pid = pid;
    proc_in_channel = inchn;
    proc_out_channel = outchn;
    proc_err_channel = errchn
  }
;;

let open_process (cmd : string list) : (process, string) result =
  (* In_channel.t * Out_channel.t * In_channel.t * int = *)
  let in_read, in_write = Unix.pipe () in
  let out_read, out_write = Unix.pipe () in
  let err_read, err_write = Unix.pipe () in
  let in_channel = Unix.in_channel_of_descr in_read in
  let out_channel = Unix.out_channel_of_descr out_write in
  let err_channel = Unix.in_channel_of_descr err_read in
  let pid =
    match Unix.fork () with
    | `In_the_child ->
      (* NOTE: the flag "close_on_exec" might affect reading output/error *)
      Unix.dup2 ~src:out_read ~dst:Unix.stdin ~close_on_exec:false ();
      Unix.dup2 ~src:in_write ~dst:Unix.stdout ~close_on_exec:false ();
      Unix.dup2 ~src:err_write ~dst:Unix.stderr ~close_on_exec:false ();
      (match List.hd cmd with
      | Some prog ->
        (try
           let _ = Unix.exec ~prog ~argv:cmd () in
           Ok 0
         with e ->
           let _ = Out_channel.flush stdout in
           let _ = Out_channel.flush stderr in
           let error_log =
             ("Failed to open process: " ^ String.concat ~sep:" " cmd ^ "\n")
             ^ "Exception: " ^ Exn.to_string e in
           Error error_log)
      | None ->
        Error ("Failed to open process: " ^ String.concat ~sep:" " cmd ^ "\n"))
    | `In_the_parent id -> Ok (Pid.to_int id) in
  let _ = Unix.close out_read in
  let _ = Unix.close in_write in
  let _ = Unix.close err_write in
  match pid with
  | Ok pid -> Ok (mk_process cmd pid in_channel out_channel err_channel)
  | Error log -> Error log
;;

let close_process proc : unit =
  try
    let _ = Unix.close (Unix.descr_of_out_channel proc.proc_out_channel) in
    let _ = Unix.close (Unix.descr_of_in_channel proc.proc_err_channel) in
    Signal.send_exn Signal.kill (`Pid (Pid.of_int proc.proc_pid))
  with _ ->
    (try Unix.close (Unix.descr_of_in_channel proc.proc_in_channel)
     with _ -> ())
;;

let read_output proc : string =
  (*In_channel.input_all proc.proc_in_channel*)
  let rec read acc =
    match In_channel.input_line proc.proc_in_channel with
    | Some output -> read (output :: acc)
    | None -> acc in
  let res = String.concat ~sep:"\n" (List.rev (read [])) in
  res
;;

let read_error proc : string =
  (*In_channel.input_all proc.proc_err_channel*)
  let rec read acc =
    match In_channel.input_line proc.proc_err_channel with
    | Some output -> read (output :: acc)
    | None -> acc in
  let res = String.concat ~sep:"\n" (List.rev (read [])) in
  res
;;

let send_input proc input =
  let _ = Out_channel.output_string proc.proc_out_channel input in
  Out_channel.flush proc.proc_out_channel
;;

let restart_process proc : (process, string) result =
  let _ = close_process proc in
  open_process proc.proc_cmd
;;

let run_command (cmd : string list) : (unit, string) result =
  match open_process cmd with
  | Ok proc ->
    (match Unix.waitpid (Pid.of_int proc.proc_pid) with
    | Ok _ ->
      let _ = close_process proc in
      Ok ()
    | Error e ->
      let output = read_output proc in
      let error = read_error proc in
      let exn = string_of_sexp (Unix.Exit_or_signal.sexp_of_error e) in
      let log = String.concat_if_not_empty ~sep:"\n" [ output; error; exn ] in
      let _ = close_process proc in
      Error log)
  | Error log -> Error log
;;

(** Run a command and get output. The output can be:
    - (Ok string_output)
    - (Error error_message) *)

let run_command_get_output (cmd : string list) : (string, string) result =
  match open_process cmd with
  | Ok proc ->
    (match Unix.waitpid (Pid.of_int proc.proc_pid) with
    | Ok _ ->
      let output = read_output proc ^ read_error proc in
      let _ = close_process proc in
      Ok output
    | Error _ ->
      let msg = read_error proc in
      let _ = close_process proc in
      Error msg)
  | Error log -> Error log
;;

let run_command_output_to_file (cmd : string list) (file : string)
    : (unit, string) result
  =
  let out_read, _ = Unix.pipe () in
  let file_ds = Unix.openfile ~mode:[ Unix.O_CREAT; Unix.O_WRONLY ] file in
  let pid =
    match Unix.fork () with
    | `In_the_child ->
      (* NOTE: the flag "close_on_exec" might affect reading output/error *)
      let _ = Unix.dup2 ~src:out_read ~dst:Unix.stdin ~close_on_exec:false () in
      let _ = Unix.dup2 ~src:file_ds ~dst:Unix.stdout ~close_on_exec:false () in
      let _ = Unix.dup2 ~src:file_ds ~dst:Unix.stderr ~close_on_exec:false () in
      (* if not cloexec then List.iter Unix.close toclose; *)
      let prog = List.hd_exn cmd in
      let _ = Unix.exec ~prog ~argv:cmd () in
      Pid.of_int 0
    | `In_the_parent id -> id in
  let _ = Unix.close out_read in
  match Unix.waitpid pid with
  | Ok _ -> Ok ()
  | Error e ->
    let err = string_of_sexp (Unix.Exit_or_signal.sexp_of_error e) in
    Error err
;;
