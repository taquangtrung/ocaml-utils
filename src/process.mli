(********************************************************************
 * This file is part of ocaml-utils, an extended library of the
 * OCaml Core standard library with useful utility functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

type process =
  { proc_exe : string;
    proc_cmd : string list;
    proc_pid : int;
    proc_in_channel : Core.In_channel.t;
    proc_out_channel : Core.Out_channel.t;
    proc_err_channel : Core.In_channel.t
  }

(*** Handle input/output *)

val read_output : process -> string
val read_error : process -> string
val send_input : process -> string -> unit

(*** Start, stop processes ***)

val open_process
  :  string list ->
  Core.In_channel.t * Core.Out_channel.t * Core.In_channel.t * int

val start_process : string list -> process
val close_process : process -> unit
val restart_process : process -> process

(*** Run commands ***)

val run_command : string list -> (unit, string) result
val run_command_get_output : string list -> (string, string) result
val run_command_output_to_file : string list -> string -> (unit, string) result
