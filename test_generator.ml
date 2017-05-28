type rel = Eq | Neq


let print_rel fmt rel =
  Format.fprintf fmt "%s" (match rel with
                            | Eq -> "="
                            | Neq -> "<>")
let print_atom fmt atom =
  let (rel, v1, v2) = atom in
  Format.fprintf fmt "%d%a%d" (v1+1) print_rel rel (v2+1)
let print_clause fmt clause =
  Printer.print_list print_atom " " fmt clause
let print_formula fmt f =
  Printer.print_list print_clause "\n" fmt f


(* Mandatory arguments *)
let nb_cl   = ref 0
let nb_var  = ref 0
(* Optional arguments *)
let nb_func = ref 0
let sat     = ref true


let random_bool () =
  Random.int 2 = 0

let choose a =
  a.(Random.int (Array.length a))

let choose2 a =
  let n = Array.length a in
  if n = 1 then (a.(0), a.(0)) else
    let i = Random.int n in
    let j = if i = n - 1 then Random.int i else i + 1 + Random.int (n - i - 1) in
    (a.(i), a.(j))

let random_list random n =
  Array.to_list (Array.init n (fun _ -> random ()))

let random_classes () =
  let classes = Array.make !nb_var [] in
  for v = 0 to !nb_var - 1 do
    let v_class = Random.int !nb_var in
    classes.(v_class) <- v :: classes.(v_class)
  done;
  Array.of_list (List.map Array.of_list (List.filter ((<>) []) (Array.to_list classes)))

let random_atom classes () =
  if random_bool () then
    (* Equality atom *)
    let (v1, v2) = choose2 (choose classes) in
    (Eq, v1, v2)
  else
    (* Inequality atom *)
    let (cl1, cl2) = choose2 classes in
    (Neq, choose cl1, choose cl2)

let random_clause classes () =
    random_list (random_atom classes) (1 + Random.int (!nb_var - 1))

let random_formula classes () =
  random_list (random_clause classes) !nb_cl

let random_sat () =
  random_formula (random_classes ())()


let random_unsat () =
  failwith "Unsupported yet"


let generate name =
  if !nb_cl <= 0 then
    failwith "Incorrect or unspecified number of clauses";
  if !nb_var <= 0 then
    failwith "Incorrect or unspecified number of variables";
  if !nb_func < 0 then
    failwith "Incorrect number of functions";

  let filename = Format.sprintf "test/%s.cnfuf" name in
  let ch = open_out filename in
  let fmt = Format.formatter_of_out_channel ch in
  Format.fprintf fmt "c Auto-generated by generate\n";
  Format.fprintf fmt "c %s\n" (if !sat then "Satisfiable" else "Unsatisfiable");
  Format.fprintf fmt "p cnf %d %d\n" !nb_var !nb_cl;
  Random.self_init ();
  print_formula fmt (if !sat then random_sat () else random_unsat ());
  Format.pp_flush_formatter fmt

let () =
  Arg.parse
    [("-cl",    Arg.Set_int nb_cl,   "Number of clauses in the generated CNF (mandatory argument)");
     ("-var",   Arg.Set_int nb_var,  "Number of variables in the generated CNF (mandatory argument)");
     ("-func",  Arg.Set_int nb_func, "Number of functions in the generated CNF (optional argument)");
     ("-sat",   Arg.Unit (fun () -> sat := true),  "The CNF should be satisfiable (optional, default)");
     ("-unsat", Arg.Unit (fun () -> sat := false), "The CNF should be unsatisfiable (optional, not default)")]
    generate
    "\
Usage: generate -cl <number of clauses> -var <number of variables>
                [-func <number of functions>] [-sat | -unsat]
                <test name>"