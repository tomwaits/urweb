(* Copyright (c) 2008, 2013, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *)

structure CoreUntangle :> CORE_UNTANGLE = struct

open Core

structure U = CoreUtil
structure E = CoreEnv

structure IS = IntBinarySet
structure IM = IntBinaryMap

fun default (k, s) = s

fun exp thisGroup (e, s) =
    let
        fun try n =
            if IS.member (thisGroup, n) then
                IS.add (s, n)
            else
                s
    in
        case e of
            ENamed n => try n
          | EClosure (n, _) => try n
          | EServerCall (n, _, _, _) => try n
          | _ => s
    end

fun untangle file =
    let
        fun expUsed thisGroup = U.Exp.fold {con = default,
                                            kind = default,
                                            exp = exp thisGroup} IS.empty

        fun decl (dAll as (d, loc)) =
            case d of
                DValRec vis =>
                let
                    val thisGroup = foldl (fn ((_, n, _, _, _), thisGroup) =>
                                              IS.add (thisGroup, n)) IS.empty vis

                    (* Direct dependency graph: each node's set of the group's names it
                     * uses directly. *)
                    val edefs = foldl (fn ((_, n, _, e, _), edefs) =>
                                         IM.insert (edefs, n, expUsed thisGroup e))
                                     IM.empty vis

                    fun succs n =
                        case IM.find (edefs, n) of
                            SOME s => s
                          | NONE => IS.empty

                    (* Tarjan's strongly-connected-components algorithm, run directly on the
                     * direct dependency graph.  It yields the SCCs -- and, via the order in
                     * which their roots finish, a topological order -- in a single O(V + E)
                     * DFS.
                     *
                     * This replaces an earlier approach that first materialized the FULL
                     * reachability closure (an iterative transitive closure) and then derived
                     * SCCs and a topological sort from it.  That was O(V^4) in the size of the
                     * 'val rec' group and pathologically slow on the large mutually-recursive
                     * groups that functor elaboration (e.g. the Crud functor) produces --
                     * enough to stall compilation for minutes.  Tarjan needs no closure. *)
                    val nextIndex = ref 0
                    val idxOf : int IM.map ref = ref IM.empty   (* DFS discovery index *)
                    val lowOf : int IM.map ref = ref IM.empty   (* lowlink *)
                    val onStack = ref IS.empty
                    val stack = ref ([] : int list)
                    val sccsRev = ref ([] : IS.set list)        (* SCCs, most-recently-finished first *)

                    fun getIdx n = valOf (IM.find (!idxOf, n))
                    fun getLow n = valOf (IM.find (!lowOf, n))
                    fun setLow (n, v) = lowOf := IM.insert (!lowOf, n, v)

                    fun strongconnect v =
                        let
                            val () = idxOf := IM.insert (!idxOf, v, !nextIndex)
                            val () = lowOf := IM.insert (!lowOf, v, !nextIndex)
                            val () = nextIndex := !nextIndex + 1
                            val () = stack := v :: !stack
                            val () = onStack := IS.add (!onStack, v)

                            val () = IS.app
                                         (fn w =>
                                             case IM.find (!idxOf, w) of
                                                 NONE =>
                                                 (* w not yet visited: recurse, then relax *)
                                                 (strongconnect w;
                                                  setLow (v, Int.min (getLow v, getLow w)))
                                               | SOME iw =>
                                                 (* w already visited: it constrains v's
                                                  * lowlink only if it is still on the stack
                                                  * (i.e. in the current SCC candidate) *)
                                                 if IS.member (!onStack, w) then
                                                     setLow (v, Int.min (getLow v, iw))
                                                 else
                                                     ())
                                         (succs v)
                        in
                            (* v roots an SCC iff its lowlink never escaped its own index. *)
                            if getLow v = getIdx v then
                                let
                                    fun pop scc =
                                        case !stack of
                                            [] => scc
                                          | w :: rest =>
                                            (stack := rest;
                                             onStack := IS.delete (!onStack, w);
                                             let val scc = IS.add (scc, w)
                                             in if w = v then scc else pop scc
                                             end)
                                in
                                    sccsRev := pop IS.empty :: !sccsRev
                                end
                            else
                                ()
                        end

                    val () = IS.app (fn v =>
                                        case IM.find (!idxOf, v) of
                                            NONE => strongconnect v
                                          | SOME _ => ())
                                    thisGroup

                    (* An SCC's root finishes only after everything it reaches (its
                     * dependencies) has finished, so completion order is dependencies-first.
                     * sccsRev holds them most-recent-first, so reversing recovers that order
                     * -- a definition precedes its uses, exactly as the previous
                     * implementation emitted. *)
                    val sccs = rev (!sccsRev)

                    fun isNonrec nodes =
                        case IS.find (fn _ => true) nodes of
                            NONE => NONE
                          | SOME node =>
                            if IS.numItems nodes = 1 then
                                (* Singleton SCC: recursive only if it refers to itself. *)
                                if IS.member (succs node, node) then
                                    NONE
                                else
                                    SOME node
                            else
                                NONE

                    val ds = map (fn nodes =>
                                     case isNonrec nodes of
                                         SOME node =>
                                         let
                                             val vi = valOf (List.find (fn (_, n, _, _, _) => n = node) vis)
                                         in
                                             (DVal vi, loc)
                                         end
                                       | NONE =>
                                         (DValRec (List.filter (fn (_, n, _, _, _) => IS.member (nodes, n)) vis), loc))
                                 sccs
                in
                    ds
                end
              | _ => [dAll]
    in
        ListUtil.mapConcat decl file
    end

end
