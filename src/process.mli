(********************************************************************
 * This file is part of ocaml-extcore, an extended library of the
 * OCaml Core standard library with additionally useful functions.
 *
 * Copyright (c) 2021 Ta Quang Trung.
 ********************************************************************)

type process =
  { proc_exe : string;
    proc_cmd : string list;
    proc_pid : int;
    proc_in_channel : in_channel;
    proc_out_channel : out_channel;
    proc_err_channel : in_channel
  }

val pid_dummy : int
val mk_proc_dummy : string list -> process

(*** Handle input/output *)

val read_output : process -> string
val read_error : process -> string
val send_input : process -> string -> unit

(*** Start, stop processes ***)

val open_process : string list -> in_channel * out_channel * in_channel * int
val start_process : string list -> process
val close_process : process -> unit
val restart_process : process -> process

(*** Run commands ***)

val run_command : string list -> unit
val run_command_get_output : string list -> (string, string) result
