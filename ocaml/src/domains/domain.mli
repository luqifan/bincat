(** Signature of abstract domains *)

module type T = 
    sig
		
      (** type of abstract values *)
      type t 
      
      (** returns the initial value *)
      val init: unit -> t

      (** bottom value *)
      val bot: t

      (** make all computed dimensions to top *)
      val forget: t -> t
		      
      (** comparison to bottom *)
      val is_bot: t -> bool
		 
      (** returns true whenever the concretization of the first argument is included in the concretization of the second argument *)
      (** false otherwise *)
      val subset: t -> t -> bool
 	       
      (** remove the given register from the given abstract value *)	
      val remove_register: Register.t -> t -> t

      (** forget the value of the given lvalue (ie set to top) *)
      val forget_lval: Asm.lval -> t -> t
				       
      (** add the given register to the given abstract value *)
      val add_register: Register.t -> t -> t
					     
      (** string conversion *)
      val to_string: t -> string list
				     
      (** int conversion of the given register *)
      (** may raise an exception if this kind of operation is not a singleton or is undefined for the given domain *)
      val value_of_register: t -> Register.t -> Z.t

      (** int conversion of the given expression *)
      (** may raise an exception if this kind of operation is not a singleton or is undefined for the given domain *)
      val value_of_exp: t -> Asm.exp -> Z.t
						 
      (** assignment into the given left value of the given expression *)
      (** returns true whenever one left value of the source expression is tainted *)
      val set: Asm.lval -> Asm.exp -> t -> t * bool
									  
      (** joins the two abstract values *)
      val join: t -> t -> t

      (** meets the two abstract values *)
      val meet: t -> t -> t

      (** widens the two abstract values *)
      val widen: t -> t -> t

      (** [set_memory_from_config a c nb m] update the abstract value in _m_ with the value configuration _c_ (pair content * tainting value ) for the memory location _a_ *)
      (** the integer _nb_ is the number of consecutive configurations _c_ to set *)
      val set_memory_from_config: Data.Address.t -> Data.Address.region -> Config.cvalue * (Config.tvalue option) -> int -> t -> t

      (** [set_register_from_config r c nb m] update the abstract value _m_ with the value configuration (pair content * tainting value) for register _r_ *)
      (** the integer _nb_ is the number of consecutive configuration _t_ to set *)
      val set_register_from_config: Register.t -> Data.Address.region -> Config.cvalue * (Config.tvalue option) -> t -> t
     
      (** apply the given taint mask to the given register *)
      val taint_register_mask: Register.t -> Config.tvalue -> t -> t

      (** apply the given taint mask to the given memory address *)
      val taint_address_mask: Data.Address.t -> Config.tvalue -> t -> t

      (** comparison *)
      val compare: t -> Asm.exp -> Asm.cmp -> Asm.exp -> t * bool

      (** returns the set of addresses pointed by the given expression *)
      (** may raise an exception *)
      (** the returned boolean is true whenever the pointer is tainted *)
      val mem_to_addresses: t -> Asm.exp -> Data.Address.Set.t * bool
	
      val is_tainted: Asm.exp -> t -> bool

      (** [set_type lv t m] type the left value lv with type t *)
      val set_type: Asm.lval -> Types.t -> t -> t


      (** [get_address_of addr terminator upper_bound sz m] scans memory to get *)
      (** the lowest offset o <= upper_bound from address addr such that (sz)[addr+o] cmp terminator is true *)
      (** may raise an exception if not found or memory too much imprecise *)
      val get_offset_from: Asm.exp -> Asm.cmp -> Asm.exp -> int -> int -> t -> int
	
      (** [get_bytes e cmp terminator length_bound d] *)
      (** return the byte sequence b1...bn from address e such that *)
      (** n is the minimal index <= length_bound with M[e+i] cmp *)
      (** terminator is true in d *)
      (** size of terminator is 8-bit width *)
      (** raise Not_found if no such sequence exists *)
      (** the return integer is the length of the return string wrt to the given terminator *)
      val get_bytes: Asm.exp -> Asm.cmp -> Asm.exp -> int -> t -> int * Bytes.t

      (** [copy d dst arg sz] copy the first sz bits of arg into dst. May raise an exception if dst is undefined in d *)
      val copy: t -> Asm.lval -> Asm.exp -> int -> t

    (** [copy_until d dst arg term bound] copy the bits of dst into address [arg] until the first occurence of term is found into dst. This occurence may be at most at address [arg+bound] raise an exception if the upper bound is exceeded of dst is undefined in d 
	it returns also the number of copied bits *)
      val copy_until: t -> Asm.lval -> Asm.exp -> Asm.exp -> int -> int * t
    end
      
