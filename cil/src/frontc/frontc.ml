(****************************************************************************)
(*                                                                          *)
(*  Copyright (C) 2001-2003                                                 *)
(*   George C. Necula    <necula@cs.berkeley.edu>                           *)
(*   Scott McPeak        <smcpeak@cs.berkeley.edu>                          *)
(*   Wes Weimer          <weimer@cs.berkeley.edu>                           *)
(*   Ben Liblit          <liblit@cs.berkeley.edu>                           *)
(*  All rights reserved.                                                    *)
(*                                                                          *)
(*  Redistribution and use in source and binary forms, with or without      *)
(*  modification, are permitted provided that the following conditions      *)
(*  are met:                                                                *)
(*                                                                          *)
(*  1. Redistributions of source code must retain the above copyright       *)
(*  notice, this list of conditions and the following disclaimer.           *)
(*                                                                          *)
(*  2. Redistributions in binary form must reproduce the above copyright    *)
(*  notice, this list of conditions and the following disclaimer in the     *)
(*  documentation and/or other materials provided with the distribution.    *)
(*                                                                          *)
(*  3. The names of the contributors may not be used to endorse or          *)
(*  promote products derived from this software without specific prior      *)
(*  written permission.                                                     *)
(*                                                                          *)
(*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS     *)
(*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT       *)
(*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       *)
(*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE          *)
(*  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,     *)
(*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,    *)
(*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;        *)
(*  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER        *)
(*  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT      *)
(*  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN       *)
(*  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         *)
(*  POSSIBILITY OF SUCH DAMAGE.                                             *)
(*                                                                          *)
(*  File modified by CEA (Commissariat à l'énergie atomique et aux          *)
(*                        énergies alternatives)                            *)
(*               and INRIA (Institut National de Recherche en Informatique  *)
(*                          et Automatique).                                *)
(****************************************************************************)

(* Output management *)
let out : out_channel option ref = ref None
let close_me = ref false

let close_output _ =
  match !out with
    None -> ()
  | Some o -> begin
      flush o;
      if !close_me then close_out o else ();
      close_me := false
  end

   (* Signal that we are in MS VC mode *)
let setMSVCMode () =
  Cprint.msvcMode := true

let printNotice = ref false

(*
** Argument definition
let args : (string * Arg.spec * string) list =
[
  "--cabsonly", Arg.String set_output, "<fname>: CABS output file name";
  "--printComments", Arg.Unit (fun _ -> Cprint.printComments := true),
             ": print cabs tree structure in comments in cabs output";
  "--patchFile", Arg.String (fun pf -> patchFileName := pf),
             "<fname>: name the file containing patching transformations";
  "--printPatched", Arg.Unit (fun _ -> printPatchedFiles := true),
             ": print patched CABS files after patching, to *.patched";
  "--printProtos", Arg.Unit (fun _ -> doPrintProtos := true),
             ": print prototypes to safec.proto.h after parsing";
  "--printNotice", Arg.Set printNotice,
             ": include a comment saying printed by FrontC";
]
 *)

exception CabsOnly

(* parse *)
let rec parse_to_cabs fname =
  (* now parse the file we came here to parse *)
  let cabs = parse_to_cabs_inner fname in
  if Cilmsg.had_errors () then begin
    Kernel.debug "There were parsing errors in %s" fname ;
    raise Parsing.Parse_error
  end;
  (* print it ... *)
  (match !out with
  | None -> ();
  | Some o -> begin
    if !printNotice then output_string o ("/* Generated by Frontc */\n");
    Cprint.printFile (Format.formatter_of_out_channel o) cabs;
    close_output ();
    raise CabsOnly
  end);
  if Cilmsg.had_errors () then raise Parsing.Parse_error;
  (* and return the patched source *)
  cabs

(* just parse *)
and parse_to_cabs_inner (fname : string) =
  try
    Kernel.feedback ~level:2 "Parsing %s" fname ;
    Cilmsg.clear_errors () ;
    let lexbuf = Clexer.init fname in
    let cabs = Cparser.file Clexer.initial lexbuf in
    (* Cprint.print_defs cabs;*)
    Clexer.finish ();
    (*TODO: explore deeper why to overwrite fname ?!
      let fname = match !E.first_filename_encountered with
      | None -> fname
      | Some f -> f
      in*)
    (fname, cabs)
  with
  | Sys_error msg ->
    Clexer.finish () ;
    close_output () ;
    Kernel.abort "Cannot open %s : %s" fname msg ;
  | Parsing.Parse_error ->
    Clexer.finish ();
    close_output ();
    raise Parsing.Parse_error ;
  (*| e -> begin
      ignore (E.log "Caught %s while parsing\n" (Printexc.to_string e));
      Clexer.finish ();
      raise e
  end
  *)

module Syntactic_transformations = Hook.Fold(struct type t = Cabs.file end)
let add_syntactic_transformation = Syntactic_transformations.extend

let parse fname =
  Kernel.feedback ~level:2 "Parsing %s to Cabs" fname ;
  let cabs = parse_to_cabs fname in
  let cabs = Syntactic_transformations.apply cabs in
  (*Cprint.printFile stdout cabs;*)
  (* Now (return a function that will) convert to CIL *)
  fun _ ->
    Kernel.feedback ~level:2 "Converting %s from Cabs to CIL" fname ;
    let cil = Cabs2cil.convFile cabs in
    (*if !doPrintProtos then (printPrototypes cabs);*)
    (*Cil.dumpFile Cil.defaultCilPrinter stdout "behue" cil;*)
    cil,cabs
