(** The types of the CNF formula used by the SAT solver *)

type var     = int          (** A boolean variable *)
type clause  = var    list  (** Represents a disjunction *)
type formula = clause list  (** Represents a conjunction *)
type cnf = {
  nb_var : int;             (** Variables in the formula range from 0 to nb_vars - 1 *)
  nb_cl  : int;             (** The number of clauses in the formula *)
  f      : formula;
}

type model = bool array     (** An assignment of all variables *)


(** This function solves the given CNF, returning a model if satisfiable or None otherwise *)
val solve : cnf -> model option