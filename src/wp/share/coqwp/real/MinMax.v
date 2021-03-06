(**************************************************************************)
(*                                                                        *)
(*  The Why3 Verification Platform   /   The Why3 Development Team        *)
(*  Copyright 2010-2013   --   INRIA - CNRS - Paris-Sud University        *)
(*                                                                        *)
(*  This software is distributed under the terms of the GNU Lesser        *)
(*  General Public License version 2.1, with the special exception        *)
(*  on linking described in file LICENSE.                                 *)
(**************************************************************************)

(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require real.Real.

Require Import Rbasic_fun.

(* Why3 goal *)
Definition min: R -> R -> R.
exact Rmin.
Defined.

(* Why3 goal *)
Definition max: R -> R -> R.
exact Rmax.
Defined.

(* Why3 goal *)
Lemma Max_is_ge : forall (x:R) (y:R), (x <= (max x y))%R /\ (y <= (max x
  y))%R.
split.
apply Rmax_l.
apply Rmax_r.
Qed.

(* Why3 goal *)
Lemma Max_is_some : forall (x:R) (y:R), ((max x y) = x) \/ ((max x y) = y).
intros x y.
destruct (Rle_or_lt x y) as [H|H].
right.
now apply Rmax_right.
left.
apply Rmax_left.
now apply Rlt_le.
Qed.

(* Why3 goal *)
Lemma Min_is_le : forall (x:R) (y:R), ((min x y) <= x)%R /\ ((min x
  y) <= y)%R.
split.
apply Rmin_l.
apply Rmin_r.
Qed.

(* Why3 goal *)
Lemma Min_is_some : forall (x:R) (y:R), ((min x y) = x) \/ ((min x y) = y).
intros x y.
destruct (Rle_or_lt x y) as [H|H].
left.
now apply Rmin_left.
right.
apply Rmin_right.
now apply Rlt_le.
Qed.

